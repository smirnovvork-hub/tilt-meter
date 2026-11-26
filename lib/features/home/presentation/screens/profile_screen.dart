import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/player_avatar.dart';
import '../../../matches/data/faceit_api.dart';
import '../../../matches/domain/models/faceit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.playerName, this.initialNickname, required this.onConnect});

  final String? playerName;
  final String? initialNickname;
  final Future<FaceitProfile> Function(String nickname) onConnect;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nickname = TextEditingController(text: widget.initialNickname);
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final profile = await widget.onConnect(_nickname.text.trim());
      if (mounted) Navigator.of(context).pop(profile);
    } on FaceitException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.panel(),
                    child: Row(
                      children: [
                        const PlayerAvatar(size: 52),
                        const SizedBox(width: 14),
                        Expanded(child: Text(widget.playerName ?? 'Профиль FACEIT', style: textTheme.titleLarge)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nickname,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(labelText: 'Никнейм FACEIT'),
                    maxLength: 32,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _connect(),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введи никнейм';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  if (_error case final error?) ...[
                    Text(error, style: const TextStyle(color: AppColors.loss)),
                    const SizedBox(height: 10),
                  ],
                  FilledButton.icon(
                    onPressed: _isLoading ? null : _connect,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(_isLoading ? 'Загружаем матчи…' : 'Подключить профиль'),
                  ),
                  if (_isLoading) ...[
                    const SizedBox(height: 10),
                    const LinearProgressIndicator(semanticsLabel: 'Загрузка профиля FACEIT'),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
