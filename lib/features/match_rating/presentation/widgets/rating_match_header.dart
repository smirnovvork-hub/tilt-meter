import 'package:flutter/material.dart';

import '../../../../core/widgets/section_heading.dart';
import '../../../matches/domain/models/game_match.dart';
import '../../../matches/presentation/widgets/match_card.dart';

class RatingMatchHeader extends StatelessWidget {
  const RatingMatchHeader({super.key, required this.match});

  final GameMatch match;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeading('Матч CS2'),
        const SizedBox(height: 9),
        MatchCard(match: match),
      ],
    );
  }
}
