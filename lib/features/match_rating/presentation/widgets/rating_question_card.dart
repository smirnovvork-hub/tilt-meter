import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.orange, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
              if (value != null)
                Text(
                  '$value/5',
                  style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
          const SizedBox(height: 20),
          Row(
            children: List.generate(5, (index) {
              final rating = index + 1;
              final isSelected = value == rating;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 4 ? 0 : 8),
                  child: Material(
                    color: isSelected ? AppColors.orange : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => onChanged(rating),
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 48,
                        child: Center(
                          child: Text(
                            '$rating',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.grey,
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
              Flexible(
                child: Text(lowLabel, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  highLabel,
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
