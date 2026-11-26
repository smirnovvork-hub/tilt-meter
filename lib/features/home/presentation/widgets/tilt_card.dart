import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class TiltCard extends StatelessWidget {
  const TiltCard({super.key, required this.score, this.canRate = true});

  final int? score;
  final bool canRate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (status, color, recommendation) = switch (score) {
      null when !canRate => ('Нет оценки', AppColors.muted, 'Tilt Score появится после оценки матча CS2.'),
      null => ('Нет оценки', AppColors.muted, 'Оцени последний матч, чтобы узнать свой уровень тильта.'),
      < 30 => ('Низкий уровень', AppColors.win, 'По твоим ответам признаки тильта выражены слабо.'),
      < 60 => ('Умеренный уровень', AppColors.amber, 'Есть признаки напряжения. Обрати внимание на своё состояние.'),
      _ => (
        'Высокий уровень',
        AppColors.loss,
        'Ты отметил несколько признаков тильта. Возможно, стоит сделать перерыв.',
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppTheme.panelRadius,
        border: Border.all(color: AppColors.border),
        gradient: const LinearGradient(
          colors: [Color(0xFF2D201A), AppColors.card, AppColors.card],
          stops: [0, .56, 1],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: ClipRRect(
        borderRadius: AppTheme.panelRadius,
        child: Stack(
          children: [
            const Positioned.fill(child: CustomPaint(painter: _TiltCardPattern())),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.monitor_heart_outlined, color: AppColors.orange, size: 19),
                      const SizedBox(width: 8),
                      Expanded(child: Text('TILT SCORE', style: textTheme.titleMedium?.copyWith(letterSpacing: 1.2))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: SizedBox(
                      width: 164,
                      height: 124,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: (score ?? 0) / 100),
                              duration: const Duration(milliseconds: 650),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) => CustomPaint(
                                painter: _GaugePainter(value: value, color: color),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: SizedBox(
                              width: 106,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  score == null ? '—' : '$score%',
                                  style: const TextStyle(
                                    fontSize: 44,
                                    height: 1,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .1),
                        border: Border.all(color: color.withValues(alpha: .24)),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        child: Text(
                          status,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  Text(recommendation, textAlign: TextAlign.center, style: textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const tickCount = 33;
    final center = Offset(size.width / 2, size.height * .65);
    final radius = size.width * .46;
    final activeTicks = (value * tickCount).round();
    final paint = Paint()..strokeWidth = 2.6;

    for (var index = 0; index < tickCount; index++) {
      final angle = (150 + 240 * index / (tickCount - 1)) * math.pi / 180;
      final direction = Offset(math.cos(angle), math.sin(angle));
      final tickLength = index % 4 == 0 ? 15.0 : 9.0;
      paint.color = index < activeTicks ? color : const Color(0xFF454247);
      canvas.drawLine(center + direction * (radius - tickLength), center + direction * radius, paint);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) => value != oldDelegate.value || color != oldDelegate.color;
}

class _TiltCardPattern extends CustomPainter {
  const _TiltCardPattern();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.orange.withValues(alpha: .10);
    for (var index = 0; index < 9; index++) {
      final x = size.width - index * 10;
      canvas.drawLine(Offset(x, 0), Offset(x - 69, 76), paint);
    }
  }

  @override
  bool shouldRepaint(_TiltCardPattern oldDelegate) => false;
}
