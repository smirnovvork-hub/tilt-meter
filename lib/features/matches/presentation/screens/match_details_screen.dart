import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/section_heading.dart';
import '../../domain/models/game_match.dart';
import '../../domain/models/match_map_stats.dart';
import '../widgets/match_card.dart';

class MatchDetailsScreen extends StatefulWidget {
  const MatchDetailsScreen({super.key, required this.match});

  final GameMatch match;

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  int _mapIndex = 0;

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final maps = match.maps;
    final map = maps.isEmpty ? null : maps[_mapIndex];
    final player = map?.selectedPlayer;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Статистика матча')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                MatchCard(match: match),
                if (maps.length > 1) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: _mapIndex,
                    decoration: const InputDecoration(labelText: 'Карта'),
                    isExpanded: true,
                    items: [
                      for (final (index, item) in maps.indexed) DropdownMenuItem(value: index, child: Text(item.map)),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _mapIndex = value);
                    },
                  ),
                ],
                if (map == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Составы и статистика недоступны. Обнови список матчей на главной.'),
                  )
                else ...[
                  if (player != null) ...[
                    const SizedBox(height: 14),
                    const SectionHeading('Твой результат'),
                    const SizedBox(height: 10),
                    _PlayerSummary(player: player),
                  ],
                  const SizedBox(height: 18),
                  _TeamCard(team: map.teams[0], title: 'Твоя команда'),
                  const SizedBox(height: 12),
                  _TeamCard(team: map.teams[1], title: 'Соперники'),
                  if (player != null && player.stats.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const SectionHeading('Все показатели игрока'),
                    const SizedBox(height: 10),
                    DecoratedBox(
                      decoration: AppTheme.panel(),
                      child: Column(
                        children: [
                          for (final metric in player.stats.entries)
                            ListTile(
                              dense: true,
                              title: Text(_metricLabels[metric.key] ?? metric.key),
                              trailing: Text(metric.value, style: textTheme.titleSmall),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _metricLabels = {
  'Kills': 'Убийства',
  'Assists': 'Помощь',
  'Deaths': 'Смерти',
  'Damage': 'Нанесённый урон',
  'Headshot %': 'Хедшоты, %',
  'Headshots %': 'Хедшоты, %',
  'Headshots': 'Хедшоты',
  'K/D Ratio': 'K/D',
  'K/R Ratio': 'Убийств за раунд',
  'MVPs': 'MVP',
  'ADR': 'Средний урон за раунд · ADR',
};

class _PlayerSummary extends StatelessWidget {
  const _PlayerSummary({required this.player});

  final MatchPlayerStats player;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: AppTheme.panel(),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(player.nickname, style: textTheme.titleMedium?.copyWith(color: AppColors.orange)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 18,
            runSpacing: 10,
            children: [
              for (final key in ['Kills', 'Assists', 'Deaths', 'ADR', 'K/D Ratio'])
                if (player.stats[key] case final value?)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(value, style: textTheme.titleLarge),
                      Text(key == 'ADR' ? key : _metricLabels[key]!, style: textTheme.bodySmall),
                    ],
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({required this.team, required this.title});

  final MatchTeamStats team;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    const columns = {'K': 'Kills', 'A': 'Assists', 'D': 'Deaths'};
    final bold = theme.bodySmall?.copyWith(color: AppColors.text, fontWeight: FontWeight.w700);

    return Container(
      decoration: AppTheme.panel(),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: theme.titleMedium)),
              Text('${team.score}', style: theme.titleLarge),
            ],
          ),
          if (team.name.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(team.name, style: theme.bodySmall),
            ),
          const SizedBox(height: 8),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(),
              2: FlexColumnWidth(),
              3: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  Text('Игрок', style: theme.bodySmall),
                  for (final label in columns.keys) Text(label, textAlign: TextAlign.center, style: theme.bodySmall),
                ],
              ),
              for (final player in team.players)
                TableRow(
                  decoration: player.selected
                      ? BoxDecoration(
                          color: AppColors.orange.withValues(alpha: .13),
                          borderRadius: BorderRadius.circular(5),
                        )
                      : null,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Text(
                        player.nickname,
                        style: player.selected ? bold?.copyWith(color: AppColors.orange) : bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    for (final metric in columns.values)
                      Text(player.stats[metric] ?? '—', textAlign: TextAlign.center, style: bold),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
