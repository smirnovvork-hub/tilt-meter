import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/match_rating.dart';

class LocalMatchStore {
  late final _preferences = SharedPreferencesAsync();

  static const _nicknameKey = 'faceit.nickname';

  Future<String?> readNickname() => _preferences.getString(_nicknameKey);

  Future<void> saveNickname(String nickname) => _preferences.setString(_nicknameKey, nickname);

  Future<MatchRating?> readRating(String playerId, String matchId) async {
    final data = await _preferences.getString(_ratingKey(playerId, matchId));
    if (data == null) return null;

    try {
      if (jsonDecode(data) case {
        'anger': final int anger,
        'fatigue': final int fatigue,
        'concentration': final int concentration,
        'satisfaction': final int satisfaction,
        'motivation': final int motivation,
        'comment': final String? comment,
        'created_at': final String createdAt,
      }) {
        return MatchRating(
          matchId: matchId,
          anger: anger,
          fatigue: fatigue,
          concentration: concentration,
          satisfaction: satisfaction,
          motivation: motivation,
          comment: comment,
          createdAt: DateTime.parse(createdAt),
        );
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  Future<void> saveRating(String playerId, MatchRating rating) => _preferences.setString(
    _ratingKey(playerId, rating.matchId),
    jsonEncode({
      'anger': rating.anger,
      'fatigue': rating.fatigue,
      'concentration': rating.concentration,
      'satisfaction': rating.satisfaction,
      'motivation': rating.motivation,
      'comment': rating.comment,
      'created_at': rating.createdAt.toIso8601String(),
    }),
  );

  String _ratingKey(String playerId, String matchId) =>
      'faceit.rating.${Uri.encodeComponent(playerId)}.${Uri.encodeComponent(matchId)}';
}
