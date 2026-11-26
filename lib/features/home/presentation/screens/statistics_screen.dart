import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/section_heading.dart';
import '../../../matches/domain/models/game_match.dart';
import '../widgets/statistics_section.dart';
import '../widgets/tilt_card.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key, required this.matches, required this.tiltScore, this.status});

  final List<GameMatch> matches;
  final int? tiltScore;
  final Widget? status;

  @override
  Widget build(BuildContext context) {
    final wins = matches.where((match) => match.isWin).length;
    final winRatio = matches.isEmpty ? null : wins / matches.length;
    final winRate = winRatio == null ? '—' : '${(winRatio * 100).round()}%';
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      primary: false,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        const SectionHeading('Результаты матчей'),
        const SizedBox(height: 4),
        Text('Последние матчи CS2 в FACEIT', style: textTheme.bodySmall),
        const SizedBox(height: 14),
        if (status case final message?) ...[message, const SizedBox(height: 10)],
        if (matches.isNotEmpty) ...[
          StatisticsSection(matches: matches),
          const SizedBox(height: 10),
          Container(
            decoration: AppTheme.panel(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Доля побед', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(winRate, style: textTheme.headlineMedium?.copyWith(color: AppColors.win)),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: winRatio ?? 0,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(3),
                  color: AppColors.win,
                  backgroundColor: AppColors.border,
                  semanticsLabel: 'Доля побед',
                ),
                const SizedBox(height: 9),
                Text('Побед: $wins из ${matches.length}', style: textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TiltCard(score: tiltScore),
        ],
      ],
    );
  }
}
