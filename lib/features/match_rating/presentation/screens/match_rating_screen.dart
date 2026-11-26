import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/match_rating.dart';
import '../widgets/rating_match_header.dart';
import '../widgets/rating_question_card.dart';

class MatchRatingScreen extends StatefulWidget {
  final MatchRating? initialRating;

  const MatchRatingScreen({super.key, this.initialRating});

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
    final answered = [
      _anger,
      _fatigue,
      _concentration,
      _satisfaction,
      _motivation,
    ].where((value) => value != null).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialRating == null ? 'Оценка матча' : 'Изменить оценку',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const RatingMatchHeader(),
                  const SizedBox(height: 28),

                  const Text('Как прошёл матч?', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'Оцени своё состояние. Это поможет '
                    'отслеживать изменения эмоций '
                    'во время игры.',
                    style: TextStyle(color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ТВОЯ ОЦЕНКА',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$answered из 5',
                        style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  LinearProgressIndicator(
                    value: answered / 5,
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.orange,
                    backgroundColor: AppColors.border,
                  ),
                  const SizedBox(height: 24),

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

                  const Text(
                    'Комментарий (необязательно)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: 'Что повлияло на твоё состояние?',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: _canSave ? _saveRating : null,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Сохранить оценку', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
