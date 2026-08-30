import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../models/game_mode.dart';
import '../../../theme/app_theme.dart';
import '../../../models/player.dart' show AiDifficulty;
import '../../players/presentation/player_setup_args.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key, required this.mode});

  final String mode; // 'solo' | 'family'

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  GameVariant _variant = GameVariant.classic;
  int _aiCount = 1;
  AiDifficulty _difficulty = AiDifficulty.medium;
  int _humanCount = 2;

  bool get _isSolo => widget.mode == 'solo';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_isSolo ? l10n.soloMode : l10n.familyMode)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(l10n.chooseDifficulty, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _VariantPicker(
              value: _variant,
              onChanged: (v) => setState(() => _variant = v),
              quickLabel: l10n.quickGame,
              classicLabel: l10n.classicGame,
            ),
            const SizedBox(height: 24),
            if (_isSolo) ...[
              Text(l10n.chooseDifficulty, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              _DifficultyPicker(
                value: _difficulty,
                onChanged: (d) => setState(() => _difficulty = d),
                l10n: l10n,
              ),
              const SizedBox(height: 24),
              Text('AI opponents', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _CountStepper(
                value: _aiCount,
                min: 1,
                max: 3,
                onChanged: (v) => setState(() => _aiCount = v),
              ),
            ] else ...[
              Text('Players', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _CountStepper(
                value: _humanCount,
                min: 2,
                max: 4,
                onChanged: (v) => setState(() => _humanCount = v),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.push(
                  '/player-setup',
                  extra: PlayerSetupArgs(
                    mode: _isSolo ? GameMode.solo : GameMode.family,
                    variant: _variant,
                    aiOpponentCount: _aiCount,
                    aiDifficulty: _difficulty,
                    humanPlayerCount: _humanCount,
                  ),
                );
              },
              child: Text(MaterialLocalizations.of(context).continueButtonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _VariantPicker extends StatelessWidget {
  const _VariantPicker({
    required this.value,
    required this.onChanged,
    required this.quickLabel,
    required this.classicLabel,
  });

  final GameVariant value;
  final ValueChanged<GameVariant> onChanged;
  final String quickLabel;
  final String classicLabel;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<GameVariant>(
      segments: [
        ButtonSegment(value: GameVariant.quick, label: Text(quickLabel)),
        ButtonSegment(value: GameVariant.classic, label: Text(classicLabel)),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _DifficultyPicker extends StatelessWidget {
  const _DifficultyPicker({required this.value, required this.onChanged, required this.l10n});

  final AiDifficulty value;
  final ValueChanged<AiDifficulty> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AiDifficulty>(
      segments: [
        ButtonSegment(value: AiDifficulty.easy, label: Text(l10n.difficultyEasy)),
        ButtonSegment(value: AiDifficulty.medium, label: Text(l10n.difficultyMedium)),
        ButtonSegment(value: AiDifficulty.hard, label: Text(l10n.difficultyHard)),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _CountStepper extends StatelessWidget {
  const _CountStepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        IconButton(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text(
          '$value',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: colors.primary),
        ),
        IconButton(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}
