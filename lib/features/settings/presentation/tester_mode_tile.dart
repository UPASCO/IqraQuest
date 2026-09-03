import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Settings › Tester mode. Present only in a build compiled with
/// `--dart-define=IQRAQUEST_TESTER=true`.
///
/// The free edition draws from the 50 free questions, so a tester playing
/// game after game meets the same ones — which is the bank working as
/// designed, not a bug. This switch flips the same local entitlement a
/// purchase would, so the whole bank is in play, and flips it back so the
/// free experience can be checked too. It reports the two numbers as it
/// goes, which is also the quickest way to see the bank actually loaded
/// in the current language.
class TesterModeTile extends ConsumerWidget {
  const TesterModeTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isPremium = ref.watch(premiumControllerProvider);
    final pool = ref.watch(questionPoolProvider);
    final total = pool.valueOrNull?.length ?? 0;
    final playable = pool.valueOrNull == null
        ? 0
        : isPremium
            ? total
            : pool.value!.where((q) => q.isFree).length;

    return SwitchListTile(
      key: const Key('tester-mode-toggle'),
      title: Text(l10n.testerMode),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The bank is read from disk, so for the first frame there is
          // no count to state — better one line than "all 0 questions".
          if (total > 0) Text(l10n.testerModeHint(total)),
          if (total > 0) const SizedBox(height: 4),
          Text(
            l10n.testerBankPlayable(playable, total),
            key: const Key('tester-bank-count'),
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
      isThreeLine: true,
      value: isPremium,
      onChanged: (on) {
        final controller = ref.read(premiumControllerProvider.notifier);
        on ? controller.grant() : controller.revoke();
      },
    );
  }
}
