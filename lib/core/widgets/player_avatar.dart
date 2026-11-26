import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.raised,
        border: Border.all(color: AppColors.orange.withValues(alpha: .45)),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/player_avatar.png',
        fit: BoxFit.cover,
        excludeFromSemantics: true,
      ),
    );
  }
}
