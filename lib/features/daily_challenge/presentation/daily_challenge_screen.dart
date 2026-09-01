import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../services/sound_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/button_label.dart';
import '../../../widgets/fit_or_scroll.dart';
import '../../../widgets/ornate_frame.dart';
import '../../../widgets/question_card.dart';
import '../../../widgets/share_capture.dart';

class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() =>
      _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen> {
  int _index = 0;
  int _score = 0;
  int? _selected;
  bool? _lastCorrect;
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final poolAsync = ref.watch(questionPoolProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dailyChallenge)),
      body: SafeArea(
        child: poolAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text(l10n.genericError)),
          data: (pool) {
            final service = ref.read(dailyChallengeServiceProvider);
            final questions = service.challengeFor(
              date: DateTime.now(),
              pool: pool,
            );
            if (questions.isEmpty) {
              return Center(child: Text(l10n.genericError));
            }
            if (_completed) {
              return _Summary(score: _score, total: questions.length);
            }
            final question = questions[_index];
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value:
                        (_index + (_selected != null ? 1 : 0)) /
                        questions.length,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: QuestionCard(
                        question: question,
                        selectedIndex: _selected,
                        isCorrect: _lastCorrect,
                        onSelect: (i) => _answer(question.isCorrect(i), i),
                        onContinue: () => _next(questions.length),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _answer(bool correct, int index) {
    // Same beat as the board game: the child hears the verdict before
    // reading it.
    ref.read(soundServiceProvider).play(correct ? Sfx.correct : Sfx.wrong);
    if (correct) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
    setState(() {
      _selected = index;
      _lastCorrect = correct;
      if (correct) _score++;
    });
  }

  void _next(int total) {
    if (_index + 1 >= total) {
      ref.read(progressServiceProvider).recordDailyChallengeCompletion();
      // A clean sweep earns the flourish; anything else the warm streak
      // chime — the child finished, that is the win.
      ref
          .read(soundServiceProvider)
          .play(_score == total ? Sfx.victory : Sfx.streak);
      setState(() => _completed = true);
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _lastCorrect = null;
    });
  }
}

/// The day's score card, framed like the board plate so the picture a
/// parent shares looks like the game. Under it: share, then home.
class _Summary extends ConsumerStatefulWidget {
  const _Summary({required this.score, required this.total});

  final int score;
  final int total;

  @override
  ConsumerState<_Summary> createState() => _SummaryState();
}

class _SummaryState extends ConsumerState<_Summary> {
  final _cardKey = GlobalKey();
  final _shareKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share(AppLocalizations l10n) async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final image = await captureBoundaryPng(_cardKey);
      if (!mounted) return;
      final text = l10n.shareDailyText(widget.score, widget.total);
      final shown = await ref
          .read(shareServiceProvider)
          .shareScore(
            text: text,
            subject: l10n.appName,
            image: image,
            imageName: 'iqraquest_daily.png',
            origin: shareOriginOf(_shareKey),
          );
      if (!shown && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(text)));
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final perfect = widget.score == widget.total;

    final card = RepaintBoundary(
      key: _cardKey,
      child: OrnateFrame(
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF14484C),
            OrnatePalette.ground,
            OrnatePalette.groundDeep,
          ],
        ),
        // Air inside the frame: the card is the picture that gets shared,
        // and a score pressed against the gold rule reads as cramped.
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                perfect ? Icons.emoji_events : Icons.auto_awesome,
                size: 64,
                color: OrnatePalette.gold,
                shadows: const [
                  Shadow(
                    color: Color(0x88000000),
                    blurRadius: 12,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.dailyChallengeDone,
                textAlign: TextAlign.center,
                style: text.titleLarge?.copyWith(
                  color: OrnatePalette.gold,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.score} / ${widget.total}',
                textAlign: TextAlign.center,
                style: text.displayMedium?.copyWith(
                  color: OrnatePalette.ivory,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.dailyChallengeScore(widget.score, widget.total),
                textAlign: TextAlign.center,
                style: text.bodyLarge?.copyWith(color: OrnatePalette.ivory),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.dailyChallengeComeBack,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: OrnatePalette.ivoryDim),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.appName.toUpperCase(),
                textAlign: TextAlign.center,
                style: text.labelSmall?.copyWith(
                  color: OrnatePalette.goldDeep,
                  letterSpacing: 2.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return FitOrScroll(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: AppMotion.of(context, AppMotion.reward),
            curve: AppMotion.settle,
            builder: (context, t, child) => Transform.scale(
              scale: 0.9 + 0.1 * t.clamp(0.0, 1.0),
              child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: card,
              ),
            ),
          ),
          const Spacer(),
          const SizedBox(height: 16),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  KeyedSubtree(
                    key: _shareKey,
                    child: FilledButton.icon(
                      key: const Key('share-score'),
                      onPressed: _sharing ? null : () => _share(l10n),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.ios_share, size: 20),
                      label: ButtonLabel(l10n.shareScore),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.go('/home'),
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: ButtonLabel(l10n.backToHome),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
