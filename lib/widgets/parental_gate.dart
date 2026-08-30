import 'dart:math';

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

/// A simple arithmetic challenge shown before an adult action (purchase,
/// restore, external link) so a young child can't trigger it by accident
/// (spec §87). Collects no birthdate or personal information — it is a
/// one-time in-memory logic check, nothing is stored.
class ParentalGate {
  const ParentalGate._();

  /// Shows the gate and resolves to true only if answered correctly.
  static Future<bool> show(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final random = Random();
    final a = random.nextInt(8) + 2;
    final b = random.nextInt(8) + 2;
    final correct = a + b;
    final options = <int>{correct};
    while (options.length < 4) {
      options.add(correct + random.nextInt(9) - 4);
    }
    final shuffled = options.toList()..shuffle(random);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.parentalGateTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.parentalGateInstruction),
            const SizedBox(height: 12),
            Text('$a + $b = ?', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                for (final option in shuffled)
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(option == correct),
                    child: Text('$option'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  }
}
