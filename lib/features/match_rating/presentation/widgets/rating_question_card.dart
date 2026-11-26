import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class RatingQuestionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final int? value;
  final ValueChanged<int> onChanged;
  final String lowLabel;
  final String highLabel;

  const RatingQuestionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.lowLabel,
    required this.highLabel,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.panel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.orange, size: 22),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: textTheme.titleMedium)),
              if (value != null) ...[
                const SizedBox(width: 8),
                Text(
                  '$value/5',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.orange, fontWeight: FontWeight.w800),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: textTheme.bodySmall),
          const SizedBox(height: 14),
          Row(
            children: List.generate(5, (index) {
              final rating = index + 1;
              final isSelected = value == rating;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 4 ? 0 : 6),
                  child: Semantics(
                    selected: isSelected,
                    button: true,
                    child: Material(
                      color: isSelected ? AppColors.orange : AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                        side: BorderSide(color: isSelected ? AppColors.orange : AppColors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => onChanged(rating),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 48),
                          child: Center(
                            child: Text(
                              '$rating',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? AppColors.onOrange : AppColors.text,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(lowLabel, style: textTheme.bodySmall)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(highLabel, textAlign: TextAlign.end, style: textTheme.bodySmall),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
