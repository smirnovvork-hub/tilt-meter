import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.label, {super.key, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 17, color: AppColors.orange),
        const SizedBox(width: 9),
        Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
        if (trailing case final widget?) ...[const SizedBox(width: 8), widget],
      ],
    );
  }
}
