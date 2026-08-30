import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_theme.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(progressServiceProvider).load();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.progress)),
      body: SafeArea(
        child: GridView.count(
          padding: const EdgeInsets.all(20),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _StatTile(label: l10n.gamesPlayed, value: '${stats.gamesPlayed}'),
            _StatTile(label: l10n.winRate, value: '${(stats.winRate * 100).round()}%'),
            _StatTile(label: l10n.questionsAnswered, value: '${stats.questionsAnswered}'),
            _StatTile(label: l10n.streak, value: '${stats.dayStreak}'),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(color: colors.primary),
          ),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
