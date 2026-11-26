import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class MatchCard extends StatelessWidget {
  final String map;
  final String score;
  final String kd;
  final bool isWin;

  const MatchCard({super.key, required this.map, required this.score, required this.kd, required this.isWin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(map, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(
                isWin ? 'Победа' : 'Поражение',
                style: TextStyle(color: isWin ? Colors.greenAccent : Colors.redAccent),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(score, style: const TextStyle(fontSize: 17)),
              const SizedBox(height: 5),
              Text('K/D $kd', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
