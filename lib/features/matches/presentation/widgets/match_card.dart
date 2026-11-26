import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/game_match.dart';

class MatchCard extends StatelessWidget {
  const MatchCard({super.key, required this.match, this.footer, this.onTap});

  final GameMatch match;
  final Widget? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (result, resultColor) = switch ((match.isWin, match.isLoss)) {
      (true, _) => ('Победа', AppColors.win),
      (_, true) => ('Поражение', AppColors.loss),
      _ => ('Ничья', AppColors.muted),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: AppTheme.panel(),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: ColoredBox(color: resultColor, child: const SizedBox(width: 3)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
            child: Column(
              children: [
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(7),
                    child: Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(color: AppColors.raised, borderRadius: BorderRadius.circular(7)),
                          child: const SizedBox(
                            width: 38,
                            height: 38,
                            child: Icon(Icons.map_outlined, color: AppColors.muted, size: 18),
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(match.map, style: textTheme.titleMedium),
                              Text(
                                result,
                                style: textTheme.bodySmall?.copyWith(color: resultColor, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(match.score, style: textTheme.titleLarge),
                            Text('K/D ${match.formattedKd}', style: textTheme.bodySmall),
                          ],
                        ),
                        if (onTap != null) ...[
                          const SizedBox(width: 5),
                          const Icon(Icons.chevron_right, size: 20, color: AppColors.muted),
                        ],
                      ],
                    ),
                  ),
                ),
                if (footer case final widget?) ...[
                  const SizedBox(height: 9),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 5),
                  widget,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
