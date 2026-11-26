import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class RatingMatchHeader extends StatelessWidget {
  const RatingMatchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.sports_esports_outlined, color: AppColors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'ПОСЛЕДНИЙ МАТЧ',
                style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mirage', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(
                    'Победа',
                    style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('13 : 9', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text('K/D 1.42', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
