import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/models.dart';
import '../../../theme/app_team.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/board/bonus_tile_painter.dart';
import '../../../widgets/board/board_environment.dart';
import '../../../widgets/button_label.dart';
import '../../../widgets/knight_sprite.dart';
import '../../../widgets/ornate_frame.dart';
import '../../game/application/game_controller.dart';
import 'player_setup_args.dart';

const _teams = kBoardSeats;

/// The riders take their places: the last screen before the board, so
/// it is set on the board's own table — the dawn over the Hijaz behind,
/// every rider on a framed plate in the plate's own teal and gold, and
/// the three bonus medallions of the race shown before the first card,
/// so the strategy is known before it is needed. One gold button starts
/// the race.
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

  int get _humanCount =>
      widget.args.mode == GameMode.solo ? 1 : widget.args.humanPlayerCount;

  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_humanCount, (_) => TextEditingController());
    // Each rider picks the level of every question they will get — the
    // card only ever decides the distance — so a child and an adult can
    // share one board fairly (spec §14).
    _profiles = List.generate(_humanCount, (_) => PlayerProfile.intermediate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Default names come from l10n, so they are seeded once the locale
    // is available rather than in initState.
    if (!_prefilled) {
      _prefilled = true;
      final l10n = AppLocalizations.of(context);
      for (var i = 0; i < _controllers.length; i++) {
        _controllers[i].text = l10n.defaultPlayerName(i + 1);
      }
    }
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0A3327),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: CustomPaint(
              painter: BoardEnvironmentPainter(horizon: 0.26),
            ),
          ),
          // A soft dark veil so the framed panels and the ivory text
          // read against the dawn.
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x3306231A), Color(0xB306231A), Color(0xE606231A)],
                  stops: [0, 0.35, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: Row(
                    children: [
                      _GlassBackButton(onTap: () => context.pop()),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.ridersTitle,
                              style: textTheme.headlineSmall?.copyWith(
                                color: OrnatePalette.ivory,
                                fontWeight: FontWeight.w800,
                                shadows: const [
                                  Shadow(color: Color(0x99000000), blurRadius: 10),
                                ],
                              ),
                            ),
                            Text(
                              l10n.ridersSubtitle,
                              style: textTheme.bodySmall?.copyWith(
                                color: OrnatePalette.ivoryDim,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    children: [
                      for (var i = 0; i < _humanCount; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _RiderPanel(
                            key: Key('rider-$i'),
                            team: _teams[i],
                            controller: _controllers[i],
                            profile: _profiles[i],
                            onProfile: (p) => setState(() => _profiles[i] = p),
                            l10n: l10n,
                          ),
                        ),
                      if (widget.args.mode == GameMode.solo)
                        for (var i = 0; i < widget.args.aiOpponentCount; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _OpponentPanel(
                              team: _teams[_humanCount + i],
                              name: l10n.aiPlayerName(i + 1),
                              level: _aiLabel(widget.args.aiDifficulty, l10n),
                            ),
                          ),
                      const SizedBox(height: 4),
                      _BonusTeaser(text: l10n.bonusSquaresTeaser, colors: colors),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Pinned under the list, never at the end of it: with four riders
      // and their levels the list outgrows a phone, and the one button
      // that starts the race must never be below the fold.
      bottomNavigationBar: ColoredBox(
        color: const Color(0xE606231A),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: ElevatedButton(
              key: const Key('start-game'),
              onPressed: _starting ? null : _start,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE9C25E),
                foregroundColor: const Color(0xFF3A2A08),
                disabledBackgroundColor: const Color(0x80E9C25E),
                elevation: 6,
                shadowColor: const Color(0x99DBA83E),
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFFFF0C2), width: 1.2),
                ),
                textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              child: _starting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : ButtonLabel(l10n.startGame),
            ),
          ),
        ),
      ),
    );
  }

  String _aiLabel(AiDifficulty difficulty, AppLocalizations l10n) =>
      switch (difficulty) {
        AiDifficulty.easy => l10n.difficultyEasy,
        AiDifficulty.medium => l10n.difficultyMedium,
        AiDifficulty.hard => l10n.difficultyHard,
      };

  Future<void> _start() async {
    setState(() => _starting = true);
    final args = widget.args;
    final horseCount = args.variant.horsesPerPlayer;
    final players = <Player>[];

    final l10n = AppLocalizations.of(context);
    for (var i = 0; i < _humanCount; i++) {
      players.add(
        Player(
          id: 'human_$i',
          name: _controllers[i].text.trim().isEmpty
              ? l10n.defaultPlayerName(i + 1)
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
            name: l10n.aiPlayerName(i + 1),
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

class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).backButtonTooltip,
      child: Material(
        color: const Color(0xB3122E22),
        shape: CircleBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.arrow_back, size: 20, color: OrnatePalette.ivory),
          ),
        ),
      ),
    );
  }
}

/// One rider: the knight of their colour, their name, their level — on
/// a framed plate in the board's own teal and gold.
class _RiderPanel extends StatelessWidget {
  const _RiderPanel({
    super.key,
    required this.team,
    required this.controller,
    required this.profile,
    required this.onProfile,
    required this.l10n,
  });

  final AppTeam team;
  final TextEditingController controller;
  final PlayerProfile profile;
  final ValueChanged<PlayerProfile> onProfile;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final teamColor = team.color(colors);
    return OrnateFrame(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 4),
      inset: 8,
      radius: 10,
      starSize: 11,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF14484C), OrnatePalette.groundDeep],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // The knight on its coloured pad, as on the board.
              Container(
                width: 68,
                height: 68,
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      teamColor.withValues(alpha: 0.55),
                      teamColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: KnightSprite(team: team, height: 60),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  // Bounded on purpose: the name is shown in the turn
                  // banner and written into the save, and an unbounded
                  // one only ever arrives there truncated. 16 fits
                  // every first name.
                  maxLength: 16,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  style: textTheme.titleMedium?.copyWith(
                    color: OrnatePalette.ivory,
                    fontWeight: FontWeight.w700,
                  ),
                  cursorColor: OrnatePalette.gold,
                  decoration: InputDecoration(
                    labelText: l10n.playerName,
                    // The theme fills inputs with parchment; on the teal
                    // plate the name is ivory on the plate itself.
                    filled: false,
                    labelStyle: const TextStyle(color: OrnatePalette.ivoryDim),
                    floatingLabelStyle: const TextStyle(color: OrnatePalette.gold),
                    counterText: '',
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: OrnatePalette.goldDeep),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: OrnatePalette.gold, width: 1.6),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l10n.playerProfile,
            style: textTheme.labelMedium?.copyWith(
              color: OrnatePalette.ivoryDim,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final p in PlayerProfile.values)
                _LevelChip(
                  label: _profileLabel(p, l10n),
                  selected: profile == p,
                  onTap: () => onProfile(p),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _profileLabel(PlayerProfile profile, AppLocalizations l10n) =>
      switch (profile) {
        PlayerProfile.easy => l10n.levelEasy,
        PlayerProfile.intermediate => l10n.levelIntermediate,
        PlayerProfile.expert => l10n.levelExpert,
      };
}

/// A level, as a gold chip: filled when chosen, outlined otherwise.
class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? const Color(0xFFE9C25E) : Colors.white.withValues(alpha: 0.06),
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? const Color(0xFFFFF0C2) : OrnatePalette.goldDeep,
            width: selected ? 1.4 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? const Color(0xFF3A2A08) : OrnatePalette.ivory,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An opponent: the knight of its colour and its level, read-only.
class _OpponentPanel extends StatelessWidget {
  const _OpponentPanel({required this.team, required this.name, required this.level});

  final AppTeam team;
  final String name;
  final String level;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final teamColor = team.color(colors);
    return OrnateFrame(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      inset: 8,
      radius: 10,
      starSize: 11,
      fill: OrnatePalette.groundDeep,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [teamColor.withValues(alpha: 0.5), teamColor.withValues(alpha: 0)],
              ),
            ),
            child: KnightSprite(team: team, height: 50),
          ),
          const SizedBox(width: 12),
          // Bounded: at the large text size the name and its level wrap
          // rather than run off the small phone.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: OrnatePalette.ivory,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  level,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(color: OrnatePalette.ivoryDim),
                ),
              ],
            ),
          ),
          const Icon(Icons.smart_toy_outlined, color: OrnatePalette.goldDeep, size: 22),
        ],
      ),
    );
  }
}

/// The three bonus medallions the race will hold, with what they do.
class _BonusTeaser extends StatelessWidget {
  const _BonusTeaser({required this.text, required this.colors});

  final String text;
  final AppSemanticColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xB3122E22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OrnatePalette.goldDeep.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          for (final v in BonusTile.values)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 6),
              child: BonusMedallion(value: v, size: 44),
            ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: OrnatePalette.ivory,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
