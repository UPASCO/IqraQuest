import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/models.dart';
import '../../../theme/app_team.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/horse_painter.dart';
import '../../game/application/game_controller.dart';
import 'player_setup_args.dart';

const _teams = [AppTeam.emerald, AppTeam.saphir, AppTeam.grenat, AppTeam.safran];
const _coats = [HorseCoat.grayWhite, HorseCoat.bay, HorseCoat.chestnut, HorseCoat.black];

class PlayerSetupScreen extends ConsumerStatefulWidget {
  const PlayerSetupScreen({super.key, required this.args});

  final PlayerSetupArgs args;

  @override
  ConsumerState<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends ConsumerState<PlayerSetupScreen> {
  late final List<TextEditingController> _controllers;
  late final List<PlayerProfile> _profiles;
  bool _starting = false;

  int get _humanCount => widget.args.mode == GameMode.solo ? 1 : widget.args.humanPlayerCount;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _humanCount,
      (i) => TextEditingController(text: 'Player ${i + 1}'),
    );
    // Each player carries their own level, so a child and an adult can
    // share one board fairly (spec §14).
    _profiles = List.generate(_humanCount, (_) => PlayerProfile.intermediate);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addPlayer)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            for (var i = 0; i < _humanCount; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        HorseToken(
                          coat: _coats[i],
                          team: _teams[i],
                          size: 48,
                          color: _teams[i].color(colors),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _controllers[i],
                            decoration: InputDecoration(labelText: l10n.playerName),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.playerProfile,
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final profile in PlayerProfile.values)
                          ChoiceChip(
                            label: Text(_profileLabel(profile, l10n)),
                            selected: _profiles[i] == profile,
                            onSelected: (_) => setState(() => _profiles[i] = profile),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            if (widget.args.mode == GameMode.solo)
              for (var i = 0; i < widget.args.aiOpponentCount; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      HorseToken(
                        coat: _coats[_humanCount + i],
                        team: _teams[_humanCount + i],
                        size: 48,
                        color: _teams[_humanCount + i].color(colors),
                      ),
                      const SizedBox(width: 12),
                      Text('AI ${i + 1} · ${_aiLabel(widget.args.aiDifficulty, l10n)}'),
                    ],
                  ),
                ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _starting ? null : _start,
              child: _starting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.startGame),
            ),
          ],
        ),
      ),
    );
  }

  String _profileLabel(PlayerProfile profile, AppLocalizations l10n) => switch (profile) {
    PlayerProfile.child => l10n.profileChild,
    PlayerProfile.discovery => l10n.profileDiscovery,
    PlayerProfile.intermediate => l10n.profileIntermediate,
    PlayerProfile.advanced => l10n.profileAdvanced,
  };

  String _aiLabel(AiDifficulty difficulty, AppLocalizations l10n) => switch (difficulty) {
    AiDifficulty.easy => l10n.difficultyEasy,
    AiDifficulty.medium => l10n.difficultyMedium,
    AiDifficulty.hard => l10n.difficultyHard,
  };

  Future<void> _start() async {
    setState(() => _starting = true);
    final args = widget.args;
    final horseCount = args.variant.horsesPerPlayer;
    final players = <Player>[];

    for (var i = 0; i < _humanCount; i++) {
      players.add(
        Player(
          id: 'human_$i',
          name: _controllers[i].text.trim().isEmpty
              ? 'Player ${i + 1}'
              : _controllers[i].text.trim(),
          team: _teams[i],
          profile: _profiles[i],
          horses: List.generate(horseCount, (_) => const HorseState()),
        ),
      );
    }
    if (args.mode == GameMode.solo) {
      for (var i = 0; i < args.aiOpponentCount; i++) {
        players.add(
          Player(
            id: 'ai_$i',
            name: 'AI ${i + 1}',
            team: _teams[_humanCount + i],
            aiDifficulty: args.aiDifficulty,
            horses: List.generate(horseCount, (_) => const HorseState()),
          ),
        );
      }
    }

    final pool = await ref.read(questionPoolProvider.future);
    final isPremium = ref.read(premiumControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    controller.configure(pool: pool, isPremium: isPremium);
    controller.startNewGame(
      mode: args.mode,
      variant: args.variant,
      circuitId: args.circuitId,
      players: players,
    );

    if (mounted) context.go('/game');
  }
}
