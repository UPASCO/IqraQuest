import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../models/circuit.dart';
import '../../../models/game_mode.dart';
import '../../../services/board_effect_service.dart';
import '../../../models/player.dart' show AiDifficulty;
import '../../../theme/app_theme.dart';
import '../../../widgets/content_width.dart';
import '../../../widgets/illustration.dart';
import '../../players/presentation/player_setup_args.dart';
import '../../../widgets/button_label.dart';

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
  bool _bonuses = true;

  bool get _isSolo => widget.mode == 'solo';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_isSolo ? l10n.soloMode : l10n.familyMode)),
      body: SafeArea(
        child: ListView(
          padding: pagePadding(context, top: 20, bottom: 20),
          children: [
            // The world the player is about to ride into, up front —
            // the choice below is "where do we ride", not a settings form.
            const ArtPanel(asset: AppArt.worldBand, height: 128, radius: 20),
            const SizedBox(height: 18),
            Text(
              l10n.chooseCircuit,
              style: Theme.of(context).textTheme.titleLarge,
            ),
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
            Text(
              l10n.chooseFormat,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            // Three formats, and the ONE thing that separates them is
            // written on each card in horses: a segmented button of
            // three names ("rapide", "classique", "famille") told the
            // player nothing, and two of those names played the same
            // race.
            for (final variant in GameVariantX.choosable)
              _FormatCard(
                key: ValueKey('format-${variant.name}'),
                variant: variant,
                selected: _variant == variant,
                onTap: () => setState(() => _variant = variant),
                l10n: l10n,
              ),
            const SizedBox(height: 16),
            // Some tables want the pure classic ride. Asked here, before
            // the race, because it changes the whole parcours.
            _BonusSwitch(
              key: const Key('bonus-switch'),
              value: _bonuses,
              onChanged: (v) => setState(() => _bonuses = v),
              l10n: l10n,
            ),
            const SizedBox(height: 24),
            if (_isSolo) ...[
              Text(
                l10n.chooseDifficulty,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SegmentedButton<AiDifficulty>(
                showSelectedIcon: false,
                style: const ButtonStyle(
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 8),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                segments: [
                  ButtonSegment(
                    value: AiDifficulty.easy,
                    label: ButtonLabel(l10n.difficultyEasy),
                  ),
                  ButtonSegment(
                    value: AiDifficulty.medium,
                    label: ButtonLabel(l10n.difficultyMedium),
                  ),
                  ButtonSegment(
                    value: AiDifficulty.hard,
                    label: ButtonLabel(l10n.difficultyHard),
                  ),
                ],
                selected: {_difficulty},
                onSelectionChanged: (s) =>
                    setState(() => _difficulty = s.first),
              ),
              const SizedBox(height: 20),
              _CountStepper(
                label: l10n.aiOpponentsLabel,
                value: _aiCount,
                min: 1,
                max: 3,
                onChanged: (v) => setState(() => _aiCount = v),
              ),
            ] else
              _CountStepper(
                label: l10n.playersLabel,
                value: _humanCount,
                min: 2,
                max: 4,
                onChanged: (v) => setState(() => _humanCount = v),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      // Pinned, not at the end of the list: on a phone the list is taller
      // than the screen, and a child who has picked a course must not
      // have to hunt for the way forward below the fold.
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: ContentWidth(
            child: ElevatedButton(
              onPressed: _continue,
              child: ButtonLabel(
                MaterialLocalizations.of(context).continueButtonLabel,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _continue() {
    context.push(
      '/player-setup',
      extra: PlayerSetupArgs(
        mode: _isSolo ? GameMode.solo : GameMode.family,
        variant: _variant,
        circuitId: _circuit,
        aiOpponentCount: _aiCount,
        aiDifficulty: _difficulty,
        humanPlayerCount: _humanCount,
        bonusesEnabled: _bonuses,
      ),
    );
  }
}


/// One format, told in horses. The card leads with the only thing a
/// format actually changes — how many of your four have to reach Mecca —
/// and shows it as four horses, the required ones lit.
class _FormatCard extends StatelessWidget {
  const _FormatCard({
    super.key,
    required this.variant,
    required this.selected,
    required this.onTap,
    required this.l10n,
  });

  final GameVariant variant;
  final bool selected;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final wanted = variant.horsesToWin;
    final (name, hint) = switch (variant) {
      GameVariant.quick => (l10n.quickGame, l10n.formatQuickHint),
      GameVariant.duo => (l10n.duoGame, l10n.formatDuoHint),
      _ => (l10n.classicGame, l10n.formatClassicHint),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: selected
              ? colors.primary.withValues(alpha: 0.12)
              : colors.surfaceElevated,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? colors.primary : colors.divider,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  _HorsePips(wanted: wanted),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.horsesToMecca(wanted),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$name — $hint',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check_circle, color: colors.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Four horses in a stable, the ones this format asks for lit and the
/// rest left in the shade — the win condition read without a word.
class _HorsePips extends StatelessWidget {
  const _HorsePips({required this.wanted});

  final int wanted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      child: Wrap(
        spacing: 2,
        runSpacing: 2,
        children: [
          for (var i = 0; i < 4; i++)
            Opacity(
              opacity: i < wanted ? 1 : 0.22,
              child: Image.asset(
                'assets/board/horses/horse_emerald.webp',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, _, _) => const SizedBox(width: 24, height: 24),
              ),
            ),
        ],
      ),
    );
  }
}

/// The one rule of the parcours a table may switch off before the race.
class _BonusSwitch extends StatelessWidget {
  const _BonusSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.l10n,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surfaceElevated,
      borderRadius: BorderRadius.circular(18),
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: colors.divider),
        ),
        title: Text(
          l10n.bonusSquaresOption,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          value ? l10n.bonusSquaresOn : l10n.bonusSquaresOff,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: colors.textSecondary),
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
      CircuitId.oasisRoute => (
        l10n.circuitOasisRoute,
        l10n.circuitOasisRouteDescription,
      ),
      CircuitId.caravanTrail => (
        l10n.circuitCaravanTrail,
        l10n.circuitCaravanTrailDescription,
      ),
      CircuitId.greatRide => (
        l10n.circuitGreatRide,
        l10n.circuitGreatRideDescription,
      ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: selected
            ? colors.primary.withValues(alpha: 0.12)
            : colors.surfaceElevated,
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
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.circuitSpecialSquares(_actingSquares(circuit)),
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: colors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      // Which squares, not just how many: "20 special
                      // squares" says nothing about how a course rides.
                      // Named, the difference between the three boards
                      // is legible before the first card is drawn.
                      //
                      // Only the squares that actually do something this
                      // release are named or counted: Duel and Relais
                      // ride as plain squares until their flows ship
                      // (BoardEffectService.isAvailableFor), and a card
                      // promising them would be a card that lies.
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final effect in circuit.quadrantEffects.values
                              .where(_effectActs)
                              .toSet())
                            _EffectChip(
                              label: _effectName(effect, l10n),
                              count: circuit.quadrantEffects.values
                                  .where((e) => e == effect)
                                  .length * 4,
                            ),
                        ],
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


/// One kind of special square on a circuit card, with how many of them
/// the whole course carries.
class _EffectChip extends StatelessWidget {
  const _EffectChip({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.divider),
      ),
      child: Text(
        '$label ×$count',
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: colors.textSecondary),
      ),
    );
  }
}

/// Whether this square does anything a player would notice, in this
/// release. Duel and Relais are held back — the engine knows them, the
/// board plays them as plain squares — so they are never advertised.
bool _effectActs(CellEffect effect) => const BoardEffectService()
    .isAvailableFor(effect, playerCount: 4, horseCount: 4);

/// How many squares of a circuit actually act, which is the number worth
/// telling the player.
int _actingSquares(Circuit circuit) =>
    circuit.quadrantEffects.values.where(_effectActs).length * 4;

String _effectName(CellEffect effect, AppLocalizations l10n) => switch (effect) {
  CellEffect.oasis => l10n.cellOasis,
  CellEffect.knowledge => l10n.cellKnowledge,
  CellEffect.challenge => l10n.cellChallenge,
  CellEffect.shortcut => l10n.cellShortcut,
  CellEffect.duel => l10n.cellDuel,
  CellEffect.wisdom => l10n.cellWisdom,
  CellEffect.relay => l10n.cellRelay,
  CellEffect.plain => '',
};

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
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
        IconButton(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          tooltip: '−1',
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text(
          '$value',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(color: colors.primary),
        ),
        IconButton(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          tooltip: '+1',
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}
