import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_theme.dart';

/// The rules of the race, in the player's own language: the classic
/// *jeu des petits chevaux* — four horses, out on a 5 or 6, captures, a
/// 6 replays — with the deck of question cards in place of the die.
class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // The goal FIRST. The list used to open on "draw a card" and never
    // said anywhere how the game is won — a player could read all nine
    // steps and still not know what they were racing for. After the
    // goal, the steps follow a turn in the order it happens, and the
    // three counters of the HUD each get the line they were missing.
    final rules = <({String title, String body})>[
      (title: l10n.ruleGoalTitle, body: l10n.ruleGoalBody),
      (title: l10n.ruleDrawCardTitle, body: l10n.ruleDrawCardBody),
      (
        title: l10n.ruleAnswerToAdvanceTitle,
        body: l10n.ruleAnswerToAdvanceBody,
      ),
      (title: l10n.ruleExitTitle, body: l10n.ruleExitBody),
      (title: l10n.ruleSixTitle, body: l10n.ruleSixBody),
      (title: l10n.ruleBonusTitle, body: l10n.ruleBonusBody),
      (title: l10n.ruleSpecialCellsTitle, body: l10n.ruleSpecialCellsBody),
      (title: l10n.ruleCaptureTitle, body: l10n.ruleCaptureBody),
      (title: l10n.ruleEscalierTitle, body: l10n.ruleEscalierBody),
      (title: l10n.ruleArrivalTitle, body: l10n.ruleArrivalBody),
      (title: l10n.ruleStreakTitle, body: l10n.ruleStreakBody),
      (title: l10n.ruleKnowledgeTitle, body: l10n.ruleKnowledgeBody),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.rulesTitle)),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: rules.length,
          itemBuilder: (context, i) =>
              _Rule(step: i + 1, title: rules[i].title, body: rules[i].body),
        ),
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.step, required this.title, required this.body});

  final int step;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The step number is decorative — the heading carries the meaning,
          // so screen readers are not made to count badges.
          ExcludeSemantics(
            child: CircleAvatar(
              radius: 16,
              backgroundColor: colors.primary.withValues(alpha: 0.14),
              child: Text(
                '$step',
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: colors.primary),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: colors.textSecondary, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
