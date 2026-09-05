import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../models/circuit.dart';
import '../../../models/game_mode.dart';
import '../../../models/player.dart' show AiDifficulty;
import '../../../services/board_effect_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/button_label.dart';
import '../../../widgets/content_width.dart';
import '../../../widgets/fit_or_scroll.dart';
import '../../../widgets/illustration.dart';
import '../../players/presentation/player_setup_args.dart';

/// The race is set up on one screen, and nothing on it is below the
/// fold: who plays, how long the race is, which course it rides, and
/// whether the bonus squares are in.
///
/// Every choice is a tile, not a list row, because a table decides these
/// four things by pointing: four squares for the players, three for the
/// length of the race, three for the course. The first version stacked
/// cards a screen and a half tall, with the number of players on a
/// stepper at the very bottom — the one setting a family changes every
/// game was the one they had to scroll to.
///
/// The choices are made once here and carried to the riders' screen in
/// [PlayerSetupArgs]; the tiles never talk to the game directly.
class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key, required this.mode});

  /// Which home button brought the player here — 'solo' or 'family'. It
  /// only preselects the player tile: the tile is the actual choice, and
  /// a table can change its mind here without going back.
  final String mode;

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  /// Humans at the table, 1 to 4. One human is the solo game: the other
  /// riders are the computer's.
  late int _players = widget.mode == 'solo' ? 1 : 2;
  int _aiCount = 1;
  AiDifficulty _difficulty = AiDifficulty.medium;

  // The full game is the default: it is the jeu des petits chevaux as
  // everyone knows it, and a table that wants a shorter evening can see
  // the two shorter tiles right beside it.
  GameVariant _variant = GameVariant.classic;
  CircuitId _circuit = CircuitId.oasisRoute;
  bool _bonuses = true;

  bool get _isSolo => _players == 1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.newGameTitle)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // The floor phone leaves about 430 points between the app
            // bar and the button; the comfortable layout wants 530.
            // Rather than scroll there, every gap and tile tightens a
            // notch and the course note steps aside — the choices
            // themselves never shrink below a thumb.
            final compact = constraints.maxHeight < 560;
            // And the other way on a tablet: with twice the height to
            // spare, the tiles grow and the whole block floats a third
            // of the way down rather than huddling under the app bar.
            final roomy = constraints.maxHeight > 900 && constraints.maxWidth >= 600;
            final gap = compact ? 10.0 : (roomy ? 22.0 : 12.0);
            return FitOrScroll(
              padding: pagePadding(context, top: compact ? 8 : 12, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (roomy) const Spacer(),
                  _Eyebrow(l10n.setupWhoPlays),
                  _PlayerTiles(
                    selected: _players,
                    onChanged: (n) => setState(() => _players = n),
                    l10n: l10n,
                  ),
                  if (_isSolo) ...[
                    SizedBox(height: gap),
                    _SoloOptions(
                      aiCount: _aiCount,
                      onAiCount: (n) => setState(() => _aiCount = n),
                      difficulty: _difficulty,
                      onDifficulty: (d) => setState(() => _difficulty = d),
                      l10n: l10n,
                    ),
                  ],
                  SizedBox(height: gap),
                  _Eyebrow(l10n.setupRaceLength),
                  _LengthTiles(
                    selected: _variant,
                    onChanged: (v) => setState(() => _variant = v),
                    compact: compact,
                    roomy: roomy,
                    l10n: l10n,
                  ),
                  SizedBox(height: gap),
                  _Eyebrow(l10n.setupCourse),
                  _CircuitTiles(
                    selected: _circuit,
                    onChanged: (id) => setState(() => _circuit = id),
                    compact: compact,
                    roomy: roomy,
                    l10n: l10n,
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 8),
                    _CircuitNote(
                      circuit: Circuit.all.firstWhere((c) => c.id == _circuit),
                      l10n: l10n,
                    ),
                  ],
                  SizedBox(height: gap),
                  _BonusSwitch(
                    key: const Key('bonus-switch'),
                    value: _bonuses,
                    onChanged: (v) => setState(() => _bonuses = v),
                    l10n: l10n,
                  ),
                  Spacer(flex: roomy ? 2 : 1),
                ],
              ),
            );
          },
        ),
      ),
      // Pinned under the choices, never at the end of them: the way
      // forward is in the same place whatever the table picked.
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
        humanPlayerCount: _players,
        bonusesEnabled: _bonuses,
      ),
    );
  }
}

/// A section's name, small and set apart, so the eye reads the tiles
/// under it as one question.
class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: context.colors.textSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// Four squares, 1 to 4, as big as the row allows. The number is sized
/// from the tile, not from the type scale, so a tablet's tiles carry a
/// number a table can read from across it.
class _PlayerTiles extends StatelessWidget {
  const _PlayerTiles({
    required this.selected,
    required this.onChanged,
    required this.l10n,
  });

  final int selected;
  final ValueChanged<int> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var n = 1; n <= 4; n++) ...[
          if (n > 1) const SizedBox(width: 10),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: _NumberTile(
                key: Key('players-$n'),
                number: n,
                caption: n == 1 ? l10n.soloTileCaption : l10n.playersLabel,
                selected: selected == n,
                onTap: () => onChanged(n),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// A square with a number on it: the player-count tiles.
class _NumberTile extends StatelessWidget {
  const _NumberTile({
    super.key,
    required this.number,
    required this.caption,
    required this.selected,
    required this.onTap,
  });

  final int number;
  final String caption;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = selected ? Colors.white : colors.primary;
    final fgDim = selected
        ? Colors.white.withValues(alpha: 0.88)
        : colors.textSecondary;
    return _FilledTile(
      selected: selected,
      onTap: onTap,
      semanticsLabel: '$number, $caption',
      child: Column(
        children: [
          // The number takes whatever height the caption leaves, scaled
          // to fit — so it is the tile's own size, not the type scale's,
          // and a tablet's tile carries a number readable across a
          // table. (A FittedBox rather than a LayoutBuilder: the screen
          // measures its own height, and a LayoutBuilder cannot answer
          // an intrinsic-size question.)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  '$number',
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                    color: fg,
                  ),
                ),
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              caption,
              maxLines: 1,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: fgDim,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A tile that fills with the primary colour when chosen — the strongest
/// selected state the palette has, because these are the choices a
/// child makes by pointing.
class _FilledTile extends StatelessWidget {
  const _FilledTile({
    required this.selected,
    required this.onTap,
    required this.semanticsLabel,
    required this.child,
    this.padding = const EdgeInsets.all(6),
  });

  final bool selected;
  final VoidCallback onTap;
  final String semanticsLabel;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Material(
        color: selected ? colors.primary : colors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected ? colors.primary : colors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// What the solo game still has to decide: how many computer riders, and
/// how well they play. Two labelled chip rows that sit side by side on a
/// tablet and one under the other on a phone.
class _SoloOptions extends StatelessWidget {
  const _SoloOptions({
    required this.aiCount,
    required this.onAiCount,
    required this.difficulty,
    required this.onDifficulty,
    required this.l10n,
  });

  final int aiCount;
  final ValueChanged<int> onAiCount;
  final AiDifficulty difficulty;
  final ValueChanged<AiDifficulty> onDifficulty;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 18,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _ChipGroup(
          label: l10n.aiOpponentsLabel,
          chips: [
            for (var n = 1; n <= 3; n++)
              _Chip(
                key: Key('opponents-$n'),
                label: '$n',
                semanticsLabel: '$n ${l10n.aiOpponentsLabel}',
                selected: aiCount == n,
                minWidth: 44,
                onTap: () => onAiCount(n),
              ),
          ],
        ),
        _ChipGroup(
          label: l10n.computerLevelLabel,
          chips: [
            for (final d in AiDifficulty.values)
              _Chip(
                key: Key('ai-${d.name}'),
                label: switch (d) {
                  AiDifficulty.easy => l10n.difficultyEasy,
                  AiDifficulty.medium => l10n.difficultyMedium,
                  AiDifficulty.hard => l10n.difficultyHard,
                },
                selected: difficulty == d,
                onTap: () => onDifficulty(d),
              ),
          ],
        ),
      ],
    );
  }
}

/// A label and its chips. A Wrap, not a Row: at the large text size on
/// the narrow phone the label and the chips fold rather than overflow.
class _ChipGroup extends StatelessWidget {
  const _ChipGroup({required this.label, required this.chips});

  final String label;
  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    // The chips are one item of the outer wrap, so they move to the next
    // line together: a label followed by two chips and a third one
    // stranded underneath read as a broken row.
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        Wrap(spacing: 6, runSpacing: 6, children: chips),
      ],
    );
  }
}

/// A stadium chip: filled when chosen, outlined otherwise.
class _Chip extends StatelessWidget {
  const _Chip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.semanticsLabel,
    this.minWidth = 0,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? semanticsLabel;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel ?? label,
      excludeSemantics: true,
      child: Material(
        color: selected ? colors.primary : colors.surfaceElevated,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? colors.primary : colors.divider,
            width: selected ? 1.6 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minWidth, minHeight: 36),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? Colors.white : colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Three tiles for the length of the race, each named for what it is —
/// short, medium, full — with the one thing that actually differs said
/// under the name in horses: how many of the four must reach Mecca.
class _LengthTiles extends StatelessWidget {
  const _LengthTiles({
    required this.selected,
    required this.onChanged,
    required this.compact,
    required this.roomy,
    required this.l10n,
  });

  final GameVariant selected;
  final ValueChanged<GameVariant> onChanged;
  final bool compact;
  final bool roomy;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // The tiles stand as tall as the tallest name needs and never less
    // than a comfortable square-ish block: a fixed height overflowed the
    // moment the text size went up, and a table that needs large text
    // is exactly the table these tiles are for.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final variant in GameVariantX.choosable) ...[
            if (variant != GameVariantX.choosable.first)
              const SizedBox(width: 10),
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: compact ? 92 : (roomy ? 136 : 104),
                ),
                child: _LengthTile(
                  key: ValueKey('format-${variant.name}'),
                  variant: variant,
                  selected: selected == variant,
                  pipSize: compact ? 15 : (roomy ? 24 : 17),
                  onTap: () => onChanged(variant),
                  l10n: l10n,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LengthTile extends StatelessWidget {
  const _LengthTile({
    super.key,
    required this.variant,
    required this.selected,
    required this.pipSize,
    required this.onTap,
    required this.l10n,
  });

  final GameVariant variant;
  final bool selected;
  final double pipSize;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final wanted = variant.horsesToWin;
    final name = switch (variant) {
      GameVariant.quick => l10n.raceLengthShort,
      GameVariant.duo => l10n.raceLengthMedium,
      _ => l10n.raceLengthFull,
    };
    final horses = l10n.horsesToMecca(wanted);
    final fg = selected ? Colors.white : colors.textPrimary;
    final fgDim = selected
        ? Colors.white.withValues(alpha: 0.88)
        : colors.textSecondary;
    final textTheme = Theme.of(context).textTheme;
    return _FilledTile(
      selected: selected,
      onTap: onTap,
      semanticsLabel: '$name, $horses',
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _HorsePips(wanted: wanted, size: pipSize, dimmed: selected),
          const SizedBox(height: 6),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            horses,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(color: fgDim, height: 1.15),
          ),
        ],
      ),
    );
  }
}

/// Four horses in a row, the ones this format asks for lit and the rest
/// left in the shade — the win condition read without a word.
class _HorsePips extends StatelessWidget {
  const _HorsePips({
    required this.wanted,
    required this.size,
    required this.dimmed,
  });

  final int wanted;
  final double size;

  /// On the filled tile the unlit horses fade toward white, not black.
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 4; i++)
          Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 2),
            child: Opacity(
              opacity: i < wanted ? 1 : (dimmed ? 0.35 : 0.22),
              child: Image.asset(
                'assets/board/horses/horse_emerald.webp',
                width: size,
                height: size,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, _, _) => SizedBox(width: size, height: size),
              ),
            ),
          ),
      ],
    );
  }
}

/// Three courses, each a picture of the region it rides through with its
/// name under it. The layout of every course is fixed and shown up front,
/// so the choice is strategic rather than a surprise (spec §6); what
/// each course carries is said in the note under the row.
class _CircuitTiles extends StatelessWidget {
  const _CircuitTiles({
    required this.selected,
    required this.onChanged,
    required this.compact,
    required this.roomy,
    required this.l10n,
  });

  final CircuitId selected;
  final ValueChanged<CircuitId> onChanged;
  final bool compact;
  final bool roomy;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight so the three tiles stand equally tall whatever
    // their names wrap to — and because a stretching Row needs a bounded
    // height, which a Column never hands its children.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final circuit in Circuit.all) ...[
            if (circuit != Circuit.all.first) const SizedBox(width: 10),
            Expanded(
              child: _CircuitTile(
                key: Key('circuit-${circuit.id.name}'),
                circuit: circuit,
                selected: selected == circuit.id,
                artHeight: compact ? 46 : (roomy ? 104 : 54),
                onTap: () => onChanged(circuit.id),
                l10n: l10n,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CircuitTile extends StatelessWidget {
  const _CircuitTile({
    super.key,
    required this.circuit,
    required this.selected,
    required this.artHeight,
    required this.onTap,
    required this.l10n,
  });

  final Circuit circuit;
  final bool selected;
  final double artHeight;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final name = _circuitName(circuit.id, l10n);
    // The word a child reads first. The three courses differ in one
    // thing — how much happens on the way — so that is what the tile
    // says, in a word; the course's own name is the note's business.
    final mood = _circuitMood(circuit.id, l10n);
    final acting = _actingEffects(circuit);
    return Semantics(
      button: true,
      selected: selected,
      label: '$mood, $name',
      excludeSemantics: true,
      child: Material(
        color: selected
            ? colors.primary.withValues(alpha: 0.12)
            : colors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected ? colors.primary : colors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    ArtPanel(
                      asset: AppArt.forCircuit(circuit.id),
                      height: artHeight,
                      radius: 12,
                      glow: selected,
                    ),
                    if (selected)
                      const Positioned(
                        top: 4,
                        right: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            size: 18,
                            color: Color(0xFF1B7A5A),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  mood,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                // One glyph per kind of square the course carries: two,
                // three or four, so the ladder is visible before a word
                // is read. What each does is written under the row.
                // A Wrap, not a Row: five glyphs are wider than a phone's
                // tile, and a second line is the honest answer, never a
                // clipped one.
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 5,
                  runSpacing: 3,
                  children: [
                    for (final effect in acting)
                      Icon(_effectIcon(effect), size: 16, color: colors.primary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// What the chosen course carries, square by square, in one short line
/// each — the glyph on the tile, then what it does to a horse. Only the
/// squares that actually act this release are listed
/// (BoardEffectService.isAvailableFor): Duel, Relais and Sagesse ride as
/// plain squares until their flows ship, and a note promising them
/// would be a note that lies.
class _CircuitNote extends StatelessWidget {
  const _CircuitNote({required this.circuit, required this.l10n});

  final Circuit circuit;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final line = textTheme.labelSmall?.copyWith(
      color: colors.textPrimary,
      height: 1.2,
    );
    return Container(
      key: const Key('circuit-note'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_circuitName(circuit.id, l10n)} · '
            '${l10n.circuitSpecialSquares(_actingSquares(circuit))}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          for (final effect in _actingEffects(circuit)) ...[
            const SizedBox(height: 3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(_effectIcon(effect), size: 13, color: colors.primary),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _effectBlurb(effect, l10n),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: line,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// The one rule of the parcours a table may switch off before the race.
///
/// Laid out by hand rather than as a SwitchListTile: a list tile reports
/// its intrinsic height with the title measured at the full width, then
/// lays the title out beside the switch — one line taller — and this
/// screen, which measures itself to avoid scrolling, would overflow by
/// exactly that line.
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
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      toggled: value,
      label: l10n.bonusSquaresOption,
      child: Material(
        color: colors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: colors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.bonusSquaresOption,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value ? l10n.bonusSquaresOn : l10n.bonusSquaresOff,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ExcludeSemantics(
                  child: Switch.adaptive(value: value, onChanged: onChanged),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _circuitName(CircuitId id, AppLocalizations l10n) => switch (id) {
  CircuitId.oasisRoute => l10n.circuitOasisRoute,
  CircuitId.caravanTrail => l10n.circuitCaravanTrail,
  CircuitId.greatRide => l10n.circuitGreatRide,
};

/// The one word a course is told by: how much happens on the way.
String _circuitMood(CircuitId id, AppLocalizations l10n) => switch (id) {
  CircuitId.oasisRoute => l10n.courseCalm,
  CircuitId.caravanTrail => l10n.courseLively,
  CircuitId.greatRide => l10n.courseIntense,
};

/// Whether this square does anything a player would notice, in this
/// release. Duel and Relais are held back — the engine knows them, the
/// board plays them as plain squares — so they are never advertised.
bool _effectActs(CellEffect effect) => const BoardEffectService()
    .isAvailableFor(effect, playerCount: 4, horseCount: 4);

/// The kinds of square a course carries that actually act, in the order
/// they first appear around the quadrant, without repeats.
List<CellEffect> _actingEffects(Circuit circuit) {
  final seen = <CellEffect>[];
  final offsets = circuit.quadrantEffects.keys.toList()..sort();
  for (final offset in offsets) {
    final effect = circuit.quadrantEffects[offset]!;
    if (_effectActs(effect) && !seen.contains(effect)) seen.add(effect);
  }
  return seen;
}

/// How many squares of a circuit actually act, which is the number worth
/// telling the player.
int _actingSquares(Circuit circuit) =>
    circuit.quadrantEffects.values.where(_effectActs).length * 4;

IconData _effectIcon(CellEffect effect) => switch (effect) {
  CellEffect.oasis => Icons.shield_outlined,
  CellEffect.knowledge => Icons.auto_awesome,
  CellEffect.challenge => Icons.bolt,
  CellEffect.shortcut => Icons.fast_forward,
  CellEffect.duel => Icons.sports_martial_arts,
  CellEffect.wisdom => Icons.menu_book,
  CellEffect.relay => Icons.swap_horiz,
  CellEffect.plain => Icons.circle_outlined,
};

/// What a square does, in words a child understands; the bare name for
/// the kinds that never act.
String _effectBlurb(CellEffect effect, AppLocalizations l10n) => switch (effect) {
  CellEffect.oasis => l10n.courseSquareOasis,
  CellEffect.knowledge => l10n.courseSquareKnowledge,
  CellEffect.challenge => l10n.courseSquareChallenge,
  CellEffect.shortcut => l10n.courseSquareShortcut,
  CellEffect.duel => l10n.cellDuel,
  CellEffect.wisdom => l10n.courseSquareWisdom,
  CellEffect.relay => l10n.cellRelay,
  CellEffect.plain => '',
};
