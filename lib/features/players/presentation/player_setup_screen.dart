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
  bool _starting = false;

  int get _humanCount => widget.args.mode == GameMode.solo ? 1 : widget.args.humanPlayerCount;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _humanCount,
      (i) => TextEditingController(text: 'Player ${i + 1}'),
    );
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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addPlayer)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            for (var i = 0; i < _humanCount; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    HorseToken(
                      coat: _coats[i],
                      team: _teams[i],
                      size: 48,
                      showSaddle: true,
                      color: _teams[i].color(context.colors),
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
                        color: _teams[_humanCount + i].color(context.colors),
                      ),
                      const SizedBox(width: 12),
                      Text('AI ${i + 1} (${widget.args.aiDifficulty.name})'),
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

  Future<void> _start() async {
    setState(() => _starting = true);
    final args = widget.args;
    final players = <Player>[];

    for (var i = 0; i < _humanCount; i++) {
      players.add(
        Player(
          id: 'human_$i',
          name: _controllers[i].text.trim().isEmpty
              ? 'Player ${i + 1}'
              : _controllers[i].text.trim(),
          team: _teams[i],
          pawns: List.generate(args.variant.pawnsPerPlayer, (_) => const HomePosition()),
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
            pawns: List.generate(args.variant.pawnsPerPlayer, (_) => const HomePosition()),
          ),
        );
      }
    }

    final pool = await ref.read(questionPoolProvider.future);
    final isPremium = ref.read(premiumControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    controller.configure(pool: pool, isPremium: isPremium);
    controller.startNewGame(mode: args.mode, variant: args.variant, players: players);

    if (mounted) context.go('/game');
  }
}
