import 'package:flutter/material.dart';

import '../../../../core/widgets/section_heading.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.cards, this.status});

  final List<Widget> cards;
  final Widget? status;

  @override
  Widget build(BuildContext context) {
    return ListView(
      primary: false,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        const SectionHeading('Последние матчи CS2'),
        const SizedBox(height: 14),
        if (status case final message?) ...[message, const SizedBox(height: 10)],
        ...cards,
      ],
    );
  }
}
