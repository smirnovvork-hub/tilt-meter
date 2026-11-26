import json
import threading
import unittest
from http.server import ThreadingHTTPServer
from io import BytesIO
from unittest.mock import patch
from urllib.error import HTTPError
from urllib.request import urlopen

from backend.server import ApiError, ApiHandler, FaceitClient, normalize_match


def match_stats(match_id, map_id="de_mirage"):
    return {
        "rounds": [{
            "match_id": match_id,
            "round_stats": {"Map": map_id, "Score": "8 / 13", "Winner": "ours"},
            "teams": [
                {"team_id": "other", "team_stats": {"Final Score": "8"}, "players": [
                    {"player_id": "opponent", "nickname": "Opponent", "player_stats": {"Kills": "11", "K/D Ratio": "0.52"}},
                ]},
                {"team_id": "ours", "team_stats": {"Final Score": "13"}, "players": [
                    {"player_id": "teammate", "player_stats": {"K/D Ratio": "0.90"}},
                    {
                        "player_id": "player-1", "nickname": "ThenWhyUHere",
                        "player_stats": {"K/D Ratio": "1.42", "Kills": "17", "Deaths": "12", "ADR": "81.7"},
                    },
                ]},
            ],
        }],
    }


class FakeFaceit:
    def __init__(self, *, empty=False, failure=None, invalid_stats=False):
        self.empty = empty
        self.failure = failure
        self.invalid_stats = invalid_stats

    def get(self, path, query=None):
        if path == "/players":
            if self.failure:
                raise self.failure
            assert query == {"nickname": "ThenWhyUHere"}
            return {"player_id": "player-1", "nickname": "ThenWhyUHere"}
        if path == "/players/player-1/history":
            assert query == {"game": "cs2", "limit": 5}
            return {"items": [] if self.empty else [
                {"match_id": f"match-{i}", "finished_at": i, "status": "FINISHED"}
                for i in [2, 5, 1, 3, 4]
            ]}
        if path.startswith("/matches/") and path.endswith("/stats"):
            return {"rounds": []} if self.invalid_stats else match_stats(path.split("/")[2])
        raise AssertionError(path)


class QuietHandler(ApiHandler):
    def log_message(self, format, *args):
        pass


class FaceitClientTest(unittest.TestCase):
    def test_distinguishes_rejected_token_from_other_http_400_errors(self):
        for body, expected in [
            (b'{"error":"invalid_token"}', "faceit_auth"),
            (b'{"error":"invalid_nickname"}', "faceit_unavailable"),
            (b'Bad Request', "faceit_unavailable"),
        ]:
            with self.subTest(expected=expected), patch("backend.server.build_opener") as opener:
                opener.return_value.open.side_effect = HTTPError(
                    "https://open.faceit.com/data/v4/players", 400, "Bad Request", {}, BytesIO(body),
                )
                with self.assertLogs("backend.server", level="WARNING") as logs:
                    with self.assertRaises(ApiError) as result:
                        FaceitClient("test-key").get("/players", {"nickname": "ThenWhyUHere"})
                self.assertEqual(result.exception.code, expected)
                self.assertIn("/players returned HTTP 400", logs.output[0])
                self.assertNotIn("test-key", logs.output[0])


class ProfileEndpointTest(unittest.TestCase):
    def call_backend(self, client, query="nickname=ThenWhyUHere"):
        with ThreadingHTTPServer(("127.0.0.1", 0), QuietHandler) as server:
            server.faceit = client
            thread = threading.Thread(target=server.serve_forever, kwargs={"poll_interval": 0.01})
            thread.start()
            try:
                url = f"http://127.0.0.1:{server.server_port}/api/faceit/profile?{query}"
                try:
                    response = urlopen(url, timeout=3)
                except HTTPError as error:
                    response = error
                with response:
                    return response.status, json.load(response)
            finally:
                server.shutdown()
                thread.join(timeout=3)

    def test_five_latest_matches_use_selected_players_team_and_kd(self):
        status, result = self.call_backend(FakeFaceit())
        self.assertEqual(status, 200)
        self.assertEqual(result["player_id"], "player-1")
        self.assertEqual(result["nickname"], "ThenWhyUHere")
        self.assertEqual([match["match_id"] for match in result["matches"]], [
            "match-5", "match-4", "match-3", "match-2", "match-1",
        ])
        match = result["matches"][0]
        self.assertEqual({key: value for key, value in match.items() if key != "maps"}, {
            "match_id": "match-5", "map": "Mirage", "rounds_won": 13, "rounds_lost": 8, "kd": 1.42,
        })
        own, opposing = match["maps"][0]["teams"]
        self.assertEqual((own["score"], opposing["score"]), (13, 8))
        selected = [player for player in own["players"] if player["selected"]]
        self.assertEqual(len(selected), 1)
        self.assertEqual(selected[0]["nickname"], "ThenWhyUHere")
        self.assertEqual(selected[0]["stats"]["ADR"], "81.7")
        self.assertEqual(opposing["players"][0]["stats"], {"Kills": "11"})

    def test_empty_history(self):
        status, result = self.call_backend(FakeFaceit(empty=True))
        self.assertEqual(status, 200)
        self.assertEqual(result["matches"], [])

    def test_user_and_upstream_errors(self):
        for expected in [
            (404, "player_not_found"), (502, "faceit_auth"),
            (429, "faceit_rate_limit"), (502, "faceit_unavailable"),
        ]:
            with self.subTest(expected=expected):
                status, result = self.call_backend(FakeFaceit(failure=ApiError(*expected)))
                self.assertEqual((status, result["error"]), expected)

    def test_bad_nickname_and_missing_match_stats(self):
        self.assertEqual(self.call_backend(FakeFaceit(), ""), (400, {"error": "invalid_nickname"}))
        self.assertEqual(
            self.call_backend(FakeFaceit(invalid_stats=True)),
            (502, {"error": "faceit_invalid_data"}),
        )

    def test_score_fallback_does_not_depend_on_score_order(self):
        data = match_stats("match-1", "de_dust2")
        round_data = data["rounds"][0]
        round_data["round_stats"]["Score"] = "13 / 8"
        for team in round_data["teams"]:
            del team["team_stats"]["Final Score"]
        stats = round_data["teams"][1]["players"][1]["player_stats"]
        del stats["K/D Ratio"]
        match = normalize_match({"match_id": "match-1"}, data, "player-1")
        self.assertEqual((match["map"], match["rounds_won"], match["rounds_lost"]), ("Dust 2", 13, 8))
        self.assertAlmostEqual(match["kd"], 17 / 12)


if __name__ == "__main__":
    unittest.main()
