import 'game_match.dart';

class FaceitProfile {
  const FaceitProfile({required this.id, required this.nickname, required this.matches});

  final String id;
  final String nickname;
  final List<GameMatch> matches;
}
