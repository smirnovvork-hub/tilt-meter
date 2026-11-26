import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/models/faceit_profile.dart';
import '../domain/models/game_match.dart';
import '../domain/models/match_map_stats.dart';

class FaceitApi {
  FaceitApi({http.Client? client}) : _client = client ?? http.Client();

  static const _backendUrl = String.fromEnvironment('FACEIT_BACKEND_URL', defaultValue: 'http://127.0.0.1:8787');
  final http.Client _client;

  Future<FaceitProfile> fetchProfile(String nickname) async {
    final uri = Uri.parse('$_backendUrl/api/faceit/profile').replace(queryParameters: {'nickname': nickname});
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 28));
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode != 200) {
        final code = switch (json) {
          {'error': final String code} => code,
          _ => null,
        };
        throw FaceitException(switch (code) {
          'invalid_nickname' => 'Проверь никнейм FACEIT.',
          'player_not_found' => 'Игрок с таким никнеймом не найден.',
          'faceit_auth' => 'FACEIT отклонил ключ локального сервера.',
          'faceit_rate_limit' => 'Достигнут лимит запросов FACEIT. Попробуй чуть позже.',
          'faceit_invalid_data' => 'FACEIT вернул неполные данные матча. Попробуй обновить историю.',
          _ => 'FACEIT сейчас недоступен. Попробуй ещё раз.',
        });
      }

      if (json case {
        'player_id': final String id,
        'nickname': final String name,
        'matches': final List<dynamic> matches,
      } when id.isNotEmpty && name.isNotEmpty) {
        return FaceitProfile(id: id, nickname: name, matches: List.unmodifiable(matches.map(_parseMatch)));
      }
      throw const FormatException('Invalid profile response');
    } on TimeoutException {
      throw const FaceitException('Истекло время ожидания. Попробуй ещё раз.');
    } on http.ClientException {
      throw FaceitException(
        'Нет соединения с сервером ${uri.authority}. Запусти backend на Mac и повтори подключение.',
      );
    } on FormatException {
      throw const FaceitException('Локальный сервер вернул данные в неожиданном формате.');
    }
  }

  GameMatch _parseMatch(Object? data) {
    if (data case {
      'match_id': final String id,
      'map': final String map,
      'rounds_won': final int own,
      'rounds_lost': final int opponent,
      'kd': final num kd,
    } when id.isNotEmpty && map.isNotEmpty && own >= 0 && opponent >= 0 && kd.isFinite && kd >= 0) {
      final details = (data as Map)['maps'];
      return GameMatch(
        id: id,
        map: map,
        roundsWon: own,
        roundsLost: opponent,
        kd: kd.toDouble(),
        maps: switch (details) {
          null => const [],
          List<Object?> maps => List.unmodifiable(maps.map(MatchMapStats.fromJson)),
          _ => throw const FormatException('Invalid match details'),
        },
      );
    }
    throw const FormatException('Invalid match response');
  }

  void close() => _client.close();
}

class FaceitException implements Exception {
  const FaceitException(this.message);

  final String message;
}
