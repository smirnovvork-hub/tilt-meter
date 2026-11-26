import '../models/match_rating.dart';

abstract final class TiltScoreCalculator {
  static int calculate(MatchRating rating) {
    // Все значения от 1 до 5 преобразуем в 0..100.
    double normalize(int value) {
      return (value - 1) / 4 * 100;
    }

    final anger = normalize(rating.anger);
    final fatigue = normalize(rating.fatigue);

    // Чем выше концентрация, тем меньше
    // её вклад в показатель тильта.
    final lackOfFocus = 100 - normalize(rating.concentration);

    // Аналогично для удовлетворённости.
    final dissatisfaction = 100 - normalize(rating.satisfaction);

    final score = anger * 0.40 + fatigue * 0.20 + lackOfFocus * 0.25 + dissatisfaction * 0.15;

    return score.round().clamp(0, 100);
  }
}
