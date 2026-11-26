import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/player_avatar.dart';
import '../../../../core/widgets/section_heading.dart';
import '../../../match_rating/data/local_match_store.dart';
import '../../../match_rating/domain/models/match_rating.dart';
import '../../../match_rating/domain/services/tilt_score_calculator.dart';
import '../../../match_rating/presentation/screens/match_rating_screen.dart';
import '../../../matches/data/faceit_api.dart';
import '../../../matches/domain/models/faceit_profile.dart';
import '../../../matches/domain/models/game_match.dart';
import '../../../matches/presentation/screens/match_details_screen.dart';
import '../../../matches/presentation/widgets/match_card.dart';
import '../widgets/tilt_card.dart';
import '../widgets/statistics_section.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = FaceitApi();
  final _store = LocalMatchStore();

  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _isSavingRating = false;
  FaceitProfile? _profile;
  String? _requestedNickname;
  String? _loadError;
  Map<String, MatchRating> _ratings = {};

  List<GameMatch> get _matches => _profile?.matches ?? const [];
  MatchRating? get _lastRating => _matches.isEmpty ? null : _ratings[_matches.first.id];

  int? _score(MatchRating? rating) => rating == null ? null : TiltScoreCalculator.calculate(rating);

  @override
  void initState() {
    super.initState();
    _restoreProfile();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  Future<void> _restoreProfile() async {
    try {
      final nickname = await _store.readNickname();
      if (!mounted) return;
      if (nickname != null) {
        await _refresh(nickname);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Не удалось прочитать сохранённый профиль.';
      });
    }
  }

  Future<void> _refresh(String nickname) async {
    setState(() {
      _requestedNickname = nickname;
      _isLoading = true;
      _loadError = null;
    });
    try {
      final profile = await _api.fetchProfile(nickname);
      if (mounted) await _applyProfile(profile);
    } on FaceitException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = error.message;
      });
    }
  }

  Future<void> _applyProfile(FaceitProfile profile) async {
    final ratings = <String, MatchRating>{};
    String? storageError;
    try {
      final saved = await Future.wait(profile.matches.map((match) => _store.readRating(profile.id, match.id)));
      for (final rating in saved.whereType<MatchRating>()) {
        ratings[rating.matchId] = rating;
      }
      await _store.saveNickname(profile.nickname);
    } catch (_) {
      storageError = 'Не удалось загрузить оценки или сохранить профиль на устройстве.';
    }
    if (!mounted) return;

    setState(() {
      if (storageError == null || _profile?.id != profile.id) {
        _ratings = ratings;
      }
      _profile = profile;
      _requestedNickname = profile.nickname;
      _loadError = storageError;
      _isLoading = false;
    });
  }

  Future<void> _openMatchRating(GameMatch match) async {
    final profile = _profile;
    if (profile == null || _isSavingRating || _isLoading) return;

    final result = await Navigator.of(context).push<MatchRating>(
      MaterialPageRoute(
        builder: (context) => MatchRatingScreen(match: match, initialRating: _ratings[match.id]),
      ),
    );
    if (!mounted || result == null) return;

    setState(() => _isSavingRating = true);
    try {
      await _store.saveRating(profile.id, result);
      if (!mounted) return;
      setState(() => _ratings[result.matchId] = result);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Оценка матча сохранена')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось сохранить оценку.')));
    } finally {
      if (mounted) setState(() => _isSavingRating = false);
    }
  }

  Future<void> _openProfile() async {
    final profile = await Navigator.of(context).push<FaceitProfile>(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          playerName: _profile?.nickname,
          initialNickname: _requestedNickname,
          onConnect: _api.fetchProfile,
        ),
      ),
    );
    if (!mounted || profile == null) return;

    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    await _applyProfile(profile);
  }

  Widget? _matchStatus() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(semanticsLabel: 'Загрузка матчей FACEIT'),
      );
    }
    final error = _loadError;
    final nickname = _requestedNickname;
    if (error != null && nickname != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(error, style: const TextStyle(color: AppColors.loss)),
          OutlinedButton(onPressed: () => _refresh(nickname), child: const Text('Повторить загрузку')),
        ],
      );
    }
    if (_profile == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (error != null) Text(error, style: const TextStyle(color: AppColors.loss)),
          const Text('Подключи профиль FACEIT, чтобы увидеть последние матчи CS2.'),
          const SizedBox(height: 10),
          FilledButton(onPressed: _openProfile, child: const Text('Подключить FACEIT')),
        ],
      );
    }
    if (_matches.isEmpty) return const Text('В истории FACEIT пока нет матчей CS2.');
    return null;
  }

  Widget _matchCard(GameMatch match) {
    final rating = _ratings[match.id];
    return MatchCard(
      key: ValueKey(match.id),
      match: match,
      onTap: () =>
          Navigator.of(context).push<void>(MaterialPageRoute(builder: (context) => MatchDetailsScreen(match: match))),
      footer: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: _isLoading || _isSavingRating ? null : () => _openMatchRating(match),
          icon: const Icon(Icons.edit_note_rounded, size: 20),
          label: Text(rating == null ? 'Оценить матч' : 'Изменить оценку · ${_score(rating)}/100'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: switch (_selectedIndex) {
          1 => const Text('Статистика'),
          2 => const Text('История'),
          _ => const Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(color: AppColors.orange, borderRadius: BorderRadius.all(Radius.circular(7))),
                child: SizedBox.square(
                  dimension: 31,
                  child: Icon(Icons.bolt_rounded, color: AppColors.onOrange, size: 23),
                ),
              ),
              SizedBox(width: 9),
              Flexible(
                child: Text(
                  'TILT METER',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.3),
                ),
              ),
            ],
          ),
        },
        actions: [
          IconButton(
            onPressed: _isLoading || _isSavingRating ? null : _openProfile,
            tooltip: 'Профиль',
            icon: const PlayerAvatar(),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: IndexedStack(
            index: _selectedIndex,
            sizing: StackFit.expand,
            children: [
              _buildHomeContent(),
              StatisticsScreen(matches: _matches, tiltScore: _score(_lastRating), status: _matchStatus()),
              HistoryScreen(cards: _matches.map(_matchCard).toList(), status: _matchStatus()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 1),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Главная'),
              NavigationDestination(icon: Icon(Icons.bar_chart_outlined), label: 'Статистика'),
              NavigationDestination(icon: Icon(Icons.history), label: 'История'),
            ],
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    final latest = _matches.firstOrNull;
    final status = _matchStatus();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _profile == null ? 'Привет!' : 'Привет, ${_profile!.nickname}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 14),
          TiltCard(score: _score(_lastRating), canRate: latest != null),
          if (latest != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isLoading || _isSavingRating ? null : () => _openMatchRating(latest),
                icon: const Icon(Icons.edit_note_rounded),
                label: Text(_lastRating == null ? 'Оценить последний матч' : 'Изменить оценку последнего матча'),
              ),
            ),
          ],
          const SizedBox(height: 22),
          SectionHeading(
            'Последние матчи CS2',
            trailing: _profile != null && !_isLoading
                ? IconButton(
                    tooltip: 'Обновить матчи',
                    onPressed: _isSavingRating ? null : () => _refresh(_profile!.nickname),
                    icon: const Icon(Icons.refresh),
                  )
                : null,
          ),
          const SizedBox(height: 10),
          if (status != null) ...[status, const SizedBox(height: 10)],
          if (_matches.isNotEmpty) ...[
            StatisticsSection(matches: _matches),
            const SizedBox(height: 10),
            for (final match in _matches) _matchCard(match),
          ],
          if (_lastRating case final rating?) ...[const SizedBox(height: 12), _buildRatingSummary(rating)],
        ],
      ),
    );
  }

  Widget _buildRatingSummary(MatchRating rating) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.panel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.win),
              SizedBox(width: 10),
              Expanded(
                child: Text('Твоя последняя оценка', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _ratingRow('Раздражение', rating.anger),
          _ratingRow('Усталость', rating.fatigue),
          _ratingRow('Концентрация', rating.concentration),
          _ratingRow('Удовлетворённость', rating.satisfaction),
          _ratingRow('Желание продолжать', rating.motivation),

          const SizedBox(height: 12),

          Text(
            'Tilt Score: ${TiltScoreCalculator.calculate(rating)}/100',
            style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _ratingRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          Text('$value/5', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
