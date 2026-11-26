import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../matches/domain/models/game_match.dart';

class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key, required this.matches});

  final List<GameMatch> matches;

  @override
  Widget build(BuildContext context) {
    final losses = matches.where((match) => match.isLoss).length;
    final totalKd = matches.fold(0.0, (sum, match) => sum + match.kd);
    final averageKd = matches.isEmpty ? '—' : (totalKd / matches.length).toStringAsFixed(2);

    return DecoratedBox(
      decoration: AppTheme.panel(),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _StatCell(value: '${matches.length}', title: 'Матчи'),
            const VerticalDivider(width: 1, color: AppColors.border, indent: 12, endIndent: 12),
            _StatCell(value: '$losses', title: 'Поражения'),
            const VerticalDivider(width: 1, color: AppColors.border, indent: 12, endIndent: 12),
            _StatCell(value: averageKd, title: 'Средний K/D'),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.title});

  final String value;
  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: textTheme.titleLarge),
            const SizedBox(height: 2),
            Text(title, textAlign: TextAlign.center, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
