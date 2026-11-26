class MatchMapStats {
  const MatchMapStats({required this.map, required this.teams});

  final String map;
  final List<MatchTeamStats> teams;

  MatchPlayerStats? get selectedPlayer => teams.first.players.where((player) => player.selected).firstOrNull;

  factory MatchMapStats.fromJson(Object? json) {
    if (json case {'map': final String map, 'teams': final List<Object?> teams} when teams.length == 2) {
      return MatchMapStats(map: map, teams: List.unmodifiable(teams.map(MatchTeamStats.fromJson)));
    }
    throw const FormatException('Invalid map stats');
  }
}

class MatchTeamStats {
  const MatchTeamStats({required this.name, required this.score, required this.players});

  final String name;
  final int score;
  final List<MatchPlayerStats> players;

  factory MatchTeamStats.fromJson(Object? json) {
    if (json case {'name': final String name, 'score': final int score, 'players': final List<Object?> players}) {
      return MatchTeamStats(
        name: name,
        score: score,
        players: List.unmodifiable(players.map(MatchPlayerStats.fromJson)),
      );
    }
    throw const FormatException('Invalid team stats');
  }
}

class MatchPlayerStats {
  const MatchPlayerStats({required this.nickname, required this.selected, required this.stats});

  final String nickname;
  final bool selected;
  final Map<String, String> stats;

  factory MatchPlayerStats.fromJson(Object? json) {
    if (json case {
      'nickname': final String name,
      'selected': final bool selected,
      'stats': final Map<String, Object?> stats,
    } when stats.values.every((value) => value is String)) {
      return MatchPlayerStats(
        nickname: name.isEmpty ? 'Игрок' : name,
        selected: selected,
        stats: Map.unmodifiable(stats.cast<String, String>()),
      );
    }
    throw const FormatException('Invalid player stats');
  }
}
