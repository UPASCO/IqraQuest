import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/question_card.dart';

class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
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
            final questions = service.challengeFor(date: DateTime.now(), pool: pool);
            if (questions.isEmpty) {
              return Center(child: Text(l10n.genericError));
            }
            if (_completed) {
              return _Summary(score: _score, total: questions.length, l10n: l10n);
            }
            final question = questions[_index];
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: (_index + (_selected != null ? 1 : 0)) / questions.length,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: QuestionCard(
                        question: question,
                        selectedIndex: _selected,
                        isCorrect: _lastCorrect,
                        onSelect: (i) => setState(() {
                          _selected = i;
                          _lastCorrect = question.isCorrect(i);
                          if (_lastCorrect!) _score++;
                        }),
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

  void _next(int total) {
    if (_index + 1 >= total) {
      ref.read(progressServiceProvider).recordDailyChallengeCompletion();
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

class _Summary extends StatelessWidget {
  const _Summary({required this.score, required this.total, required this.l10n});

  final int score;
  final int total;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, size: 64, color: colors.goldAccent),
            const SizedBox(height: 16),
            Text('$score / $total', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 8),
            Text(l10n.wellRidden, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
