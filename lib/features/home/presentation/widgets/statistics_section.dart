import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _StatCard(value: '3', title: 'Матча подряд'),
        SizedBox(width: 8),
        _StatCard(value: '2', title: 'Поражения'),
        SizedBox(width: 8),
        _StatCard(value: '0.84', title: 'Средний K/D'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String title;

  const _StatCard({required this.value, required this.title});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
