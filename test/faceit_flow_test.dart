import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:tilt_meter/app/tilt_meter_app.dart';
import 'package:tilt_meter/features/match_rating/presentation/screens/match_rating_screen.dart';
import 'package:tilt_meter/features/match_rating/presentation/widgets/rating_question_card.dart';

http.Response profile({bool empty = false}) => http.Response(
  jsonEncode({
    'player_id': 'player-id',
    'nickname': 'ThenWhyUHere',
    'matches': empty
        ? []
        : [
            for (final (id, map, own, opponent, kd) in [
              ('match-1', 'Mirage', 13, 8, 1.42),
              ('match-2', 'Ancient', 8, 13, .75),
              ('match-3', 'Dust 2', 13, 10, 1.25),
              ('match-4', 'Nuke', 11, 13, .8),
              ('match-5', 'Anubis', 13, 4, 2.0),
            ])
              {
                'match_id': id,
                'map': map,
                'rounds_won': own,
                'rounds_lost': opponent,
                'kd': kd,
                if (id == 'match-2')
                  'maps': [
                    {
                      'map': map,
                      'teams': [
                        {
                          'name': 'Team Alpha',
                          'score': own,
                          'players': [
                            {
                              'nickname': 'ThenWhyUHere',
                              'selected': true,
                              'stats': {'Kills': '12', 'Deaths': '16', 'ADR': '72.4', 'Utility Damage': '117'},
                            },
                            {
                              'nickname': 'Teammate',
                              'selected': false,
                              'stats': {'Kills': '19'},
                            },
                          ],
                        },
                        {
                          'name': 'Team Bravo',
                          'score': opponent,
                          'players': [
                            {
                              'nickname': 'Rival',
                              'selected': false,
                              'stats': {'Kills': '21'},
                            },
                          ],
                        },
                      ],
                    },
                  ],
              },
          ],
  }),
  200,
);

void main() {
  setUp(() => SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty());

  testWidgets('opens the home screen when the preferences plugin is unavailable', (tester) async {
    SharedPreferencesAsyncPlatform.instance = null;

    await tester.pumpWidget(const TiltMeterApp());
    await tester.pumpAndSettle();

    expect(find.text('Не удалось прочитать сохранённый профиль.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Подключить FACEIT'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  Future<void> submit(WidgetTester tester) async {
    await tester.enterText(find.byType(TextFormField), 'ThenWhyUHere');
    await tester.tap(find.text('Подключить профиль'));
    await tester.pump();
  }

  Future<void> start(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const TiltMeterApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Профиль'));
    await tester.pumpAndSettle();
  }

  testWidgets('loads five matches, rates an older match, and restores rating by ID', (tester) async {
    final response = Completer<http.Response>();
    final client = MockClient((request) {
      expect(request.url.queryParameters, {'nickname': 'ThenWhyUHere'});
      expect(request.headers.containsKey('Authorization'), isFalse);
      return response.future;
    });
    await http.runWithClient(() async {
      await start(tester);
      await submit(tester);
      expect(find.text('Загружаем матчи…'), findsOneWidget);
      response.complete(profile());
      await tester.pumpAndSettle();

      expect(find.text('Привет, ThenWhyUHere'), findsOneWidget);
      expect(find.text('Mirage'), findsOneWidget);
      expect(find.text('Anubis'), findsOneWidget);
      final card = find.byKey(const ValueKey('match-2'));
      final map = find.descendant(of: card, matching: find.text('Ancient'));
      await tester.ensureVisible(map);
      await tester.tap(map);
      await tester.pumpAndSettle();
      expect(find.text('Статистика матча'), findsOneWidget);
      expect(find.text('Твоя команда'), findsOneWidget);
      expect(find.text('Teammate'), findsOneWidget);
      expect(find.text('Rival'), findsOneWidget);
      expect(find.text('72.4'), findsWidgets);
      await tester.scrollUntilVisible(find.text('Utility Damage'), 200);
      expect(find.text('117'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      final action = find.descendant(of: card, matching: find.text('Оценить матч'));
      await tester.ensureVisible(action);
      await tester.tap(action);
      await tester.pumpAndSettle();
      expect(find.text('Ancient'), findsOneWidget);
      expect(find.text('8:13'), findsOneWidget);
      expect(find.text('K/D 0.75'), findsOneWidget);
      expect(find.text('Поражение'), findsOneWidget);

      final form = find.byType(MatchRatingScreen);
      final scrollable = find.descendant(of: form, matching: find.byType(Scrollable)).first;
      for (final title in ['Раздражение', 'Усталость', 'Концентрация', 'Удовлетворённость', 'Желание продолжать']) {
        final question = find.widgetWithText(RatingQuestionCard, title);
        await tester.scrollUntilVisible(question, 120, scrollable: scrollable);
        final answer = find.descendant(of: question, matching: find.text('3'));
        await tester.ensureVisible(answer);
        await tester.tap(answer);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Сохранить оценку'));
      await tester.pumpAndSettle();

      Future<void> verifyRatings() async {
        final edit = find.descendant(of: card, matching: find.text('Изменить оценку · 50/100'));
        expect(edit, findsOneWidget);
        expect(find.text('Оценить последний матч'), findsOneWidget);
        await tester.ensureVisible(edit);
        await tester.tap(edit);
        await tester.pumpAndSettle();
        expect(find.text('5 из 5'), findsOneWidget);
        expect(find.text('Ancient'), findsOneWidget);
      }

      await verifyRatings();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pumpWidget(const TiltMeterApp());
      await tester.pumpAndSettle();
      await verifyRatings();
    }, () => client);
  });

  testWidgets('shows not found, then allows retry and shows empty CS2 history', (tester) async {
    var calls = 0;
    final client = MockClient(
      (_) async => calls++ == 0 ? http.Response('{"error":"player_not_found"}', 404) : profile(empty: true),
    );
    await http.runWithClient(() async {
      await start(tester);
      await submit(tester);
      await tester.pumpAndSettle();
      expect(find.text('Игрок с таким никнеймом не найден.'), findsOneWidget);
      await tester.tap(find.text('Подключить профиль'));
      await tester.pumpAndSettle();
      expect(find.text('В истории FACEIT пока нет матчей CS2.'), findsOneWidget);
      expect(find.text('Оценить последний матч'), findsNothing);
    }, () => client);
  });

  testWidgets('saved nickname survives backend failure and can be retried', (tester) async {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.withData({
      'faceit.nickname': 'ThenWhyUHere',
    });
    var calls = 0;
    final client = MockClient((request) async {
      if (calls++ == 0) throw http.ClientException('Offline', request.url);
      return profile();
    });
    await http.runWithClient(() async {
      await tester.pumpWidget(const TiltMeterApp());
      await tester.pumpAndSettle();
      expect(find.textContaining('Запусти backend на Mac и повтори подключение.'), findsOneWidget);
      final retry = find.text('Повторить загрузку');
      await tester.ensureVisible(retry);
      await tester.tap(retry);
      await tester.pumpAndSettle();
      expect(find.text('Привет, ThenWhyUHere'), findsOneWidget);
    }, () => client);
  });
}
