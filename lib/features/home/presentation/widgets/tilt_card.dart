import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class TiltCard extends StatelessWidget {
  final int? score;

  const TiltCard({super.key, required this.score});

  Color get statusColor {
    if (score == null) return Colors.grey;
    if (score! < 30) return Colors.greenAccent;
    if (score! < 60) return Colors.amber;
    return Colors.redAccent;
  }

  String get status {
    if (score == null) return 'Нет оценки';
    if (score! < 30) return 'Низкий уровень';
    if (score! < 60) return 'Умеренный уровень';
    return 'Высокий уровень';
  }

  String get recommendation {
    if (score == null) {
      return 'Оцени последний матч, чтобы '
          'увидеть свой уровень тильта.';
    }

    if (score! < 30) {
      return 'По твоим ответам признаки '
          'тильта выражены слабо.';
    }

    if (score! < 60) {
      return 'Есть признаки напряжения. '
          'Обрати внимание на своё состояние.';
    }

    return 'Ты отметил несколько признаков '
        'тильта. Возможно, стоит сделать перерыв.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          const Text('Текущий уровень тильта', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          SizedBox(
            width: 170,
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: (score ?? 0) / 100),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 14,
                        strokeCap: StrokeCap.round,
                        backgroundColor: AppColors.border,
                        color: statusColor,
                      );
                    },
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      score == null ? '—' : '$score%',
                      style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                    ),
                    Text(status, style: TextStyle(color: statusColor, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.warningBackground, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: statusColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(recommendation, style: const TextStyle(color: AppColors.warningText)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
