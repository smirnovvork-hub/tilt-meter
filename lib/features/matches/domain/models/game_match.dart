import 'match_map_stats.dart';

class GameMatch {
  const GameMatch({
    required this.id,
    required this.map,
    required this.roundsWon,
    required this.roundsLost,
    required this.kd,
    this.maps = const [],
  });

  final String id;
  final String map;
  final int roundsWon;
  final int roundsLost;
  final double kd;
  final List<MatchMapStats> maps;

  bool get isWin => roundsWon > roundsLost;
  bool get isLoss => roundsWon < roundsLost;
  String get score => '$roundsWon:$roundsLost';
  String get formattedKd => kd.toStringAsFixed(2);
}
