"""Local Tilt Meter adapter for the FACEIT Data API v4."""

import json
import logging
import math
import os
import re
from concurrent.futures import ThreadPoolExecutor
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.error import HTTPError, URLError
from urllib.parse import parse_qs, quote, urlencode, urlsplit
from urllib.request import HTTPRedirectHandler, Request, build_opener

FACEIT_URL = "https://open.faceit.com/data/v4"
LOGGER = logging.getLogger(__name__)
PROFILE_PATH = "/api/faceit/profile"
MATCH_LIMIT = 5
MAP_NAMES = {
    "dust2": "Dust 2",
    "anubis": "Anubis",
    "inferno": "Inferno",
    "mirage": "Mirage",
    "ancient": "Ancient",
    "nuke": "Nuke",
    "overpass": "Overpass",
    "vertigo": "Vertigo",
    "train": "Train",
    "cache": "Cache",
}


class ApiError(Exception):
    def __init__(self, status, code):
        super().__init__(code)
        self.status = status
        self.code = code


class NoRedirects(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


class FaceitClient:
    def __init__(self, key):
        self.key = key

    def get(self, path, query=None):
        url = FACEIT_URL + path
        if query:
            url += "?" + urlencode(query)
        request = Request(url, headers={
            "Authorization": "Bearer " + self.key,
            "Accept": "application/json",
        })
        try:
            with build_opener(NoRedirects()).open(request, timeout=8) as response:
                return json.load(response)
        except HTTPError as error:
            with error:
                invalid_token = error.code == 400 and self._is_invalid_token(error)
            LOGGER.warning("FACEIT GET %s returned HTTP %s", path, error.code)
            if path == "/players" and error.code == 404:
                raise ApiError(404, "player_not_found") from error
            if invalid_token or error.code in (401, 403):
                raise ApiError(502, "faceit_auth") from error
            if error.code == 429:
                raise ApiError(429, "faceit_rate_limit") from error
            raise ApiError(502, "faceit_unavailable") from error
        except (URLError, TimeoutError, OSError) as error:
            LOGGER.warning("FACEIT GET %s failed: %s", path, type(getattr(error, "reason", error)).__name__)
            raise ApiError(502, "faceit_unavailable") from error
        except ValueError as error:
            raise ApiError(502, "faceit_invalid_data") from error

    @staticmethod
    def _is_invalid_token(response):
        try:
            data = json.loads(response.read(4096))
        except (OSError, ValueError):
            return False
        return isinstance(data, dict) and data.get("error") == "invalid_token"


def required_text(value):
    if not isinstance(value, str) or not value.strip():
        raise ValueError("Expected text")
    return value.strip()


def non_negative_int(value):
    if type(value) is int and value >= 0:
        return value
    if isinstance(value, str) and re.fullmatch(r"[0-9]+", value.strip()):
        return int(value)
    raise ValueError("Expected a non-negative integer")


def map_name(value):
    name = required_text(value)
    original = name.lower()
    token = original.removeprefix("de_").removeprefix("cs_")
    return MAP_NAMES.get(token, name if original == token else token.replace("_", " ").title())


def find_player(teams, player_id):
    for team_index, team in enumerate(teams):
        for player in team["players"]:
            if player["player_id"] == player_id:
                return team_index, player["player_stats"]
    raise ValueError("FACEIT player is absent from match stats")


def round_score(round_data, player_team):
    teams = round_data["teams"]
    if len(teams) != 2:
        raise ValueError("Expected two teams")
    try:
        return tuple(non_negative_int(team["team_stats"]["Final Score"]) for team in teams)
    except (KeyError, ValueError, TypeError):
        score = required_text(round_data["round_stats"]["Score"])
        values = re.fullmatch(r"([0-9]+)\s*[/:-]\s*([0-9]+)", score)
        if values is None:
            raise ValueError("Invalid map score")
        first, second = map(int, values.groups())
        winner = round_data["round_stats"].get("Winner")
        if first != second and winner and winner in [team.get("team_id") for team in teams]:
            high, low = max(first, second), min(first, second)
            return (high, low) if winner == teams[0].get("team_id") else (low, high)
        if first != second:
            team_win = str(teams[player_team].get("team_stats", {}).get("Team Win", ""))
            if team_win in ("0", "1"):
                own, opponent = sorted((first, second), reverse=team_win == "1")
                return (own, opponent) if player_team == 0 else (opponent, own)
        return first, second


def player_kd(stats):
    ratio = stats.get("K/D Ratio")
    if ratio not in (None, ""):
        result = float(ratio)
    else:
        result = non_negative_int(stats["Kills"]) / max(1, non_negative_int(stats["Deaths"]))
    if not math.isfinite(result) or result < 0:
        raise ValueError("Invalid K/D")
    return result


def map_details(name, teams, player_id, side, score):
    rosters = []
    for index in (side, 1 - side):
        team = teams[index]
        players = []
        for player in team["players"]:
            selected = player["player_id"] == player_id
            stats = player.get("player_stats") or {}
            players.append({
                "nickname": player.get("nickname") or "",
                "selected": selected,
                "stats": {
                    key: str(value)
                    for key, value in stats.items()
                    if type(value) in (str, int, float)
                    and (selected or key in ("Kills", "Assists", "Deaths"))
                },
            })
        rosters.append({
            "name": (team.get("team_stats") or {}).get("Team") or "",
            "score": score[index],
            "players": players,
        })
    return {"map": name, "teams": rosters}


def normalize_match(item, stats, player_id):
    match_id = required_text(item["match_id"])
    maps = []
    scores = []
    player_stats = []
    details = []
    for round_data in stats["rounds"]:
        if round_data.get("match_id") not in (None, match_id):
            raise ValueError("Stats are for another match")
        teams = round_data["teams"]
        side, player = find_player(teams, player_id)
        score = round_score(round_data, side)
        scores.append((score[side], score[1 - side]))
        name = map_name(round_data["round_stats"]["Map"])
        maps.append(name)
        player_stats.append(player)
        details.append(map_details(name, teams, player_id, side, score))
    if not maps:
        raise ValueError("Match has no completed maps")

    if len(maps) == 1:
        own, opponent = scores[0]
        kd = player_kd(player_stats[0])
    else:
        own = sum(ours > theirs for ours, theirs in scores)
        opponent = sum(theirs > ours for ours, theirs in scores)
        kills = sum(non_negative_int(stats["Kills"]) for stats in player_stats)
        deaths = sum(non_negative_int(stats["Deaths"]) for stats in player_stats)
        kd = kills / max(1, deaths)

    return {
        "match_id": match_id,
        "map": " / ".join(maps),
        "rounds_won": own,
        "rounds_lost": opponent,
        "kd": kd,
        "maps": details,
    }


def load_profile(client, nickname):
    player = client.get("/players", {"nickname": nickname})
    player_id = required_text(player["player_id"])
    player_name = required_text(player["nickname"])
    history = client.get(
        "/players/" + quote(player_id, safe="") + "/history",
        {"game": "cs2", "limit": MATCH_LIMIT},
    )
    items = history["items"]
    if not isinstance(items, list):
        raise ValueError("Expected a list of matches")
    recent = sorted(items, key=lambda item: non_negative_int(item.get("finished_at") or 0), reverse=True)
    matches_by_id = {}
    for item in recent:
        if str(item.get("status") or "FINISHED").upper() == "FINISHED":
            matches_by_id.setdefault(required_text(item["match_id"]), item)

    def load_match(item):
        path = "/matches/" + quote(item["match_id"], safe="") + "/stats"
        return normalize_match(item, client.get(path), player_id)

    with ThreadPoolExecutor(max_workers=MATCH_LIMIT) as pool:
        matches = list(pool.map(load_match, list(matches_by_id.values())[:MATCH_LIMIT]))
    return {"player_id": player_id, "nickname": player_name, "matches": matches}


class ApiHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        origin = self.headers.get("Origin")
        if origin and not re.fullmatch(r"http://(?:localhost|127\.0\.0\.1)(?::[0-9]+)?", origin):
            self.send_json(403, {"error": "origin_forbidden"})
            return
        url = urlsplit(self.path)
        if url.path != PROFILE_PATH:
            self.send_json(404, {"error": "route_not_found"})
            return
        nickname = parse_qs(url.query).get("nickname", [""])[0].strip()
        if not nickname or len(nickname) > 32:
            self.send_json(400, {"error": "invalid_nickname"})
            return
        try:
            profile = load_profile(self.server.faceit, nickname)
        except ApiError as error:
            self.send_json(error.status, {"error": error.code})
        except (AttributeError, KeyError, TypeError, ValueError):
            self.send_json(502, {"error": "faceit_invalid_data"})
        else:
            self.send_json(200, profile)

    def send_json(self, status, payload):
        body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        origin = self.headers.get("Origin")
        if origin and status != 403:
            self.send_header("Access-Control-Allow-Origin", origin)
            self.send_header("Vary", "Origin")
        self.end_headers()
        self.wfile.write(body)


def main():
    key = os.environ.get("FACEIT_API_KEY", "").strip()
    if not key:
        raise SystemExit("Set FACEIT_API_KEY before starting the local server.")
    with ThreadingHTTPServer(("127.0.0.1", 8787), ApiHandler) as server:
        server.faceit = FaceitClient(key)
        print("Tilt Meter backend listening on http://127.0.0.1:8787", flush=True)
        server.serve_forever()


if __name__ == "__main__":
    main()
