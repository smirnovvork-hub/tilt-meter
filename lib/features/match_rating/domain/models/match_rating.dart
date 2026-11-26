class MatchRating {
  final int anger;
  final int fatigue;
  final int concentration;
  final int satisfaction;
  final int motivation;
  final String? comment;
  final DateTime createdAt;

  const MatchRating({
    required this.anger,
    required this.fatigue,
    required this.concentration,
    required this.satisfaction,
    required this.motivation,
    required this.comment,
    required this.createdAt,
  });
}
