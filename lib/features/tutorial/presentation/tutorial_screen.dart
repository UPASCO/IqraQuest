import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

/// A concise rules screen. Currently shipped in English/French text only —
/// see README.md §Content scope for the localization gap on long-form
/// text (the interactive UI itself is translated in all 12 languages).
class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appName)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            _Rule(
              step: '1',
              title: 'Answer to roll',
              body:
                  'Before you can roll the dice, answer a question. Get it '
                  'right and the dice unlocks; get it wrong and the turn '
                  'passes to the next player.',
            ),
            _Rule(
              step: '2',
              title: 'Leave the stable',
              body: 'You need to roll a 6 to bring a horse out onto the track.',
            ),
            _Rule(
              step: '3',
              title: 'Move & capture',
              body:
                  'Move a horse exactly the number rolled. Landing on an '
                  'opponent sends it back to its stable — unless the square '
                  'is protected (marked with a star).',
            ),
            _Rule(
              step: '4',
              title: 'Roll a 6, play again',
              body:
                  'A 6 grants another turn for the same player — but a new '
                  'question is always required first.',
            ),
            _Rule(
              step: '5',
              title: 'Win',
              body:
                  'Quick game: first horse home wins. Classic game: bring '
                  'all 4 horses home to win.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.step, required this.title, required this.body});

  final String step;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 16, child: Text(step)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
