import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/section_heading.dart';
import '../../../matches/domain/models/game_match.dart';
import '../../domain/models/match_rating.dart';
import '../widgets/rating_match_header.dart';
import '../widgets/rating_question_card.dart';

class MatchRatingScreen extends StatefulWidget {
  final GameMatch match;
  final MatchRating? initialRating;

  const MatchRatingScreen({super.key, required this.match, this.initialRating});

  @override
  State<MatchRatingScreen> createState() => _MatchRatingScreenState();
}

class _MatchRatingScreenState extends State<MatchRatingScreen> {
  int? _anger;
  int? _fatigue;
  int? _concentration;
  int? _satisfaction;
  int? _motivation;

  final _commentController = TextEditingController();

  bool get _canSave =>
      _anger != null && _fatigue != null && _concentration != null && _satisfaction != null && _motivation != null;

  @override
  void initState() {
    super.initState();

    final rating = widget.initialRating;
    if (rating == null) return;

    _anger = rating.anger;
    _fatigue = rating.fatigue;
    _concentration = rating.concentration;
    _satisfaction = rating.satisfaction;
    _motivation = rating.motivation;
    _commentController.text = rating.comment ?? '';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _saveRating() {
    if (!_canSave) return;

    final comment = _commentController.text.trim();

    final rating = MatchRating(
      matchId: widget.match.id,
      anger: _anger!,
      fatigue: _fatigue!,
      concentration: _concentration!,
      satisfaction: _satisfaction!,
      motivation: _motivation!,
      comment: comment.isEmpty ? null : comment,
      createdAt: widget.initialRating?.createdAt ?? DateTime.now(),
    );

    Navigator.of(context).pop(rating);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final answered = [
      _anger,
      _fatigue,
      _concentration,
      _satisfaction,
      _motivation,
    ].where((value) => value != null).length;

    return Scaffold(
      appBar: AppBar(title: Text(widget.initialRating == null ? 'Оценка матча' : 'Изменить оценку')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                children: [
                  RatingMatchHeader(match: widget.match),
                  const SizedBox(height: 16),
                  SectionHeading(
                    'Как прошёл матч?',
                    trailing: Text(
                      '$answered из 5',
                      style: textTheme.bodySmall?.copyWith(color: AppColors.orange, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: answered / 5,
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(3),
                    color: AppColors.orange,
                    backgroundColor: AppColors.border,
                    semanticsLabel: 'Заполнено вопросов',
                  ),
                  const SizedBox(height: 16),

                  RatingQuestionCard(
                    title: 'Раздражение',
                    subtitle:
                        'Насколько сильно ты злился '
                        'во время матча?',
                    icon: Icons.local_fire_department_outlined,
                    value: _anger,
                    lowLabel: 'Совсем не злился',
                    highLabel: 'Очень сильно',
                    onChanged: (value) {
                      setState(() => _anger = value);
                    },
                  ),
                  const SizedBox(height: 12),

                  RatingQuestionCard(
                    title: 'Усталость',
                    subtitle:
                        'Насколько сильно ты устал '
                        'после матча?',
                    icon: Icons.battery_2_bar_outlined,
                    value: _fatigue,
                    lowLabel: 'Полон сил',
                    highLabel: 'Очень устал',
                    onChanged: (value) {
                      setState(() => _fatigue = value);
                    },
                  ),
                  const SizedBox(height: 12),

                  RatingQuestionCard(
                    title: 'Концентрация',
                    subtitle:
                        'Насколько хорошо тебе удавалось '
                        'сосредоточиться на игре?',
                    icon: Icons.center_focus_strong_outlined,
                    value: _concentration,
                    lowLabel: 'Не мог сосредоточиться',
                    highLabel: 'Полный фокус',
                    onChanged: (value) {
                      setState(() => _concentration = value);
                    },
                  ),
                  const SizedBox(height: 12),

                  RatingQuestionCard(
                    title: 'Удовлетворённость',
                    subtitle:
                        'Насколько ты доволен '
                        'своей игрой?',
                    icon: Icons.emoji_events_outlined,
                    value: _satisfaction,
                    lowLabel: 'Совсем не доволен',
                    highLabel: 'Очень доволен',
                    onChanged: (value) {
                      setState(() => _satisfaction = value);
                    },
                  ),
                  const SizedBox(height: 12),

                  RatingQuestionCard(
                    title: 'Желание продолжать',
                    subtitle:
                        'Насколько сильно тебе хочется '
                        'сыграть ещё один матч?',
                    icon: Icons.sports_esports_outlined,
                    value: _motivation,
                    lowLabel: 'Хочу закончить',
                    highLabel: 'Хочу играть дальше',
                    onChanged: (value) {
                      setState(() => _motivation = value);
                    },
                  ),
                  const SizedBox(height: 24),

                  const SectionHeading('Комментарий (необязательно)'),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: const InputDecoration(hintText: 'Что повлияло на твоё состояние?'),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _canSave ? _saveRating : null,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Сохранить оценку'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
