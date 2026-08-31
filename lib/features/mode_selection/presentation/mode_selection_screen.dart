import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../models/circuit.dart';
import '../../../models/game_mode.dart';
import '../../../models/player.dart' show AiDifficulty;
import '../../../theme/app_theme.dart';
import '../../../widgets/illustration.dart';
import '../../players/presentation/player_setup_args.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key, required this.mode});

  final String mode; // 'solo' | 'family'

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  GameVariant _variant = GameVariant.quick;
  CircuitId _circuit = CircuitId.oasisRoute;
  int _aiCount = 1;
  AiDifficulty _difficulty = AiDifficulty.medium;
  int _humanCount = 2;

  bool get _isSolo => widget.mode == 'solo';

  @override
  void initState() {
    super.initState();
    if (!_isSolo) _variant = GameVariant.family;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_isSolo ? l10n.soloMode : l10n.familyMode)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // The world the player is about to ride into, up front —
            // the choice below is "where do we ride", not a settings form.
            const ArtPanel(asset: AppArt.worldBand, height: 128, radius: 20),
            const SizedBox(height: 18),
            Text(l10n.chooseCircuit, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            // The layout of every course is fixed and shown up front, so
            // the choice is strategic rather than a surprise (spec §6).
            for (final circuit in Circuit.all)
              _CircuitCard(
                circuit: circuit,
                selected: _circuit == circuit.id,
                onTap: () => setState(() => _circuit = circuit.id),
                l10n: l10n,
              ),
            const SizedBox(height: 24),
            Text(l10n.chooseFormat, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SegmentedButton<GameVariant>(
              style: const ButtonStyle(
                padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8)),
                visualDensity: VisualDensity.compact,
              ),
              segments: [
                ButtonSegment(value: GameVariant.quick, label: Text(l10n.quickGame)),
                ButtonSegment(value: GameVariant.classic, label: Text(l10n.classicGame)),
                if (!_isSolo)
                  ButtonSegment(value: GameVariant.family, label: Text(l10n.familyMode)),
              ],
              selected: {_variant},
              onSelectionChanged: (s) => setState(() => _variant = s.first),
            ),
            const SizedBox(height: 24),
            if (_isSolo) ...[
              Text(l10n.chooseDifficulty, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SegmentedButton<AiDifficulty>(
                style: const ButtonStyle(
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8)),
                  visualDensity: VisualDensity.compact,
                ),
                segments: [
                  ButtonSegment(value: AiDifficulty.easy, label: Text(l10n.difficultyEasy)),
                  ButtonSegment(value: AiDifficulty.medium, label: Text(l10n.difficultyMedium)),
                  ButtonSegment(value: AiDifficulty.hard, label: Text(l10n.difficultyHard)),
                ],
                selected: {_difficulty},
                onSelectionChanged: (s) => setState(() => _difficulty = s.first),
              ),
              const SizedBox(height: 20),
              _CountStepper(
                label: l10n.soloMode,
                value: _aiCount,
                min: 1,
                max: 3,
                onChanged: (v) => setState(() => _aiCount = v),
              ),
            ] else
              _CountStepper(
                label: l10n.addPlayer,
                value: _humanCount,
                min: 2,
                max: 4,
                onChanged: (v) => setState(() => _humanCount = v),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.push(
                  '/player-setup',
                  extra: PlayerSetupArgs(
                    mode: _isSolo ? GameMode.solo : GameMode.family,
                    variant: _variant,
                    circuitId: _circuit,
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

class _CircuitCard extends StatelessWidget {
  const _CircuitCard({
    required this.circuit,
    required this.selected,
    required this.onTap,
    required this.l10n,
  });

  final Circuit circuit;
  final bool selected;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (name, description) = switch (circuit.id) {
      CircuitId.oasisRoute => (l10n.circuitOasisRoute, l10n.circuitOasisRouteDescription),
      CircuitId.caravanTrail => (l10n.circuitCaravanTrail, l10n.circuitCaravanTrailDescription),
      CircuitId.greatRide => (l10n.circuitGreatRide, l10n.circuitGreatRideDescription),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: selected ? colors.primary.withValues(alpha: 0.12) : colors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? colors.primary : colors.divider,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // The region this circuit actually rides through.
                ArtPanel(
                  asset: AppArt.forCircuit(circuit.id),
                  width: 76,
                  height: 68,
                  radius: 14,
                  glow: selected,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.gaitSquares(circuit.trackLength),
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (selected) Icon(Icons.check_circle, color: colors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CountStepper extends StatelessWidget {
  const _CountStepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
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
