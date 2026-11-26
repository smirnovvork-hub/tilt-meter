import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../match_rating/domain/models/match_rating.dart';
import '../../../match_rating/domain/services/tilt_score_calculator.dart';
import '../../../match_rating/presentation/screens/match_rating_screen.dart';
import '../widgets/tilt_card.dart';
import '../widgets/statistics_section.dart';
import '../widgets/match_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MatchRating? _lastRating;

  int? get _tiltScore {
    final rating = _lastRating;
    if (rating == null) return null;

    return TiltScoreCalculator.calculate(rating);
  }

  Future<void> _openMatchRating() async {
    final result = await Navigator.of(
      context,
    ).push<MatchRating>(MaterialPageRoute(builder: (context) => MatchRatingScreen(initialRating: _lastRating)));

    if (!mounted || result == null) return;

    setState(() {
      _lastRating = result;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Оценка матча сохранена'), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TILT METER / FACEIT', style: TextStyle(fontSize: 11, color: Colors.grey, letterSpacing: 2)),
            SizedBox(height: 4),
            Text('Привет, PlayerOne 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const CircleAvatar(
              backgroundColor: AppColors.card,
              child: Icon(Icons.person_outline, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TiltCard(score: _tiltScore),
            const SizedBox(height: 24),

            const StatisticsSection(),
            const SizedBox(height: 24),

            const Text('Последние матчи', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            const MatchCard(map: 'Mirage', score: '13:9', kd: '1.42', isWin: true),
            const MatchCard(map: 'Dust 2', score: '8:13', kd: '0.78', isWin: false),
            const MatchCard(map: 'Ancient', score: '11:13', kd: '0.92', isWin: false),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _openMatchRating,
                icon: const Icon(Icons.edit_note),
                label: Text(_lastRating == null ? 'Оценить последний матч' : 'Изменить оценку матча'),
              ),
            ),

            if (_lastRating != null) ...[const SizedBox(height: 16), _buildRatingSummary(_lastRating!)],
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Главная'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), label: 'Статистика'),
          NavigationDestination(icon: Icon(Icons.history), label: 'История'),
        ],
        onDestinationSelected: (index) {},
      ),
    );
  }

  Widget _buildRatingSummary(MatchRating rating) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.greenAccent),
              SizedBox(width: 10),
              Text('Твоя последняя оценка', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            'Tilt Score: ${_tiltScore ?? 0}/100',
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
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text('$value/5', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
