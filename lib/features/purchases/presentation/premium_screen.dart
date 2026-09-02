import 'dart:async' show StreamSubscription;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../features/game/application/game_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/game_state.dart';
import '../../../services/purchase_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/geometric_motif_painter.dart';
import '../../../widgets/parental_gate.dart';
import '../../../widgets/button_label.dart';
import '../../../widgets/fit_or_scroll.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  PurchaseUiState _uiState = PurchaseUiState.idle;
  StreamSubscription<PurchaseUiState>? _sub;

  @override
  void initState() {
    super.initState();
    final purchases = ref.read(purchaseServiceProvider);
    // Catch up on what the store already said during bootstrap.
    _uiState = purchases.state;
    _sub = purchases.stateStream.listen((s) {
      if (!mounted) return;
      setState(() => _uiState = s);
      if (s == PurchaseUiState.purchased || s == PurchaseUiState.restored) {
        ref.read(premiumControllerProvider.notifier).grant();
        // A game already in progress gets the full bank immediately —
        // the buyer must not have to finish the free game first.
        final game = ref.read(gameControllerProvider.notifier);
        ref.read(questionPoolProvider.future).then((pool) {
          game.configure(pool: pool, isPremium: true);
        });
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final isPremium = ref.watch(premiumControllerProvider);
    final purchases = ref.watch(purchaseServiceProvider);
    final product = purchases.premiumProduct;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.premiumTitle)),
      body: SafeArea(
        child: GeometricMotifBackground(
          opacity: 0.05,
          color: colors.goldAccent,
          child: FitOrScroll(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.workspace_premium,
                  size: 72,
                  color: colors.goldAccent,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.premiumUnlockAll,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.premiumOneTime,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: 8),
                // The honest pitch: the real size of today's verified
                // bank, read from the bank itself (never a hardcoded
                // marketing number).
                Consumer(
                  builder: (context, ref, _) => ref
                      .watch(questionPoolProvider)
                      .maybeWhen(
                        data: (pool) => Text(
                          l10n.premiumQuestionsIncluded(pool.length),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.textSecondary),
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                ),
                const SizedBox(height: 20),
                // What the purchase actually buys, in three lines a
                // parent can check against the app itself.
                _BenefitRow(
                  icon: Icons.menu_book_rounded,
                  text: l10n.premiumBenefitBank,
                ),
                _BenefitRow(
                  icon: Icons.all_inclusive_rounded,
                  text: l10n.premiumBenefitUnlimited(GameState.freeDrawLimit),
                ),
                _BenefitRow(
                  icon: Icons.family_restroom_rounded,
                  text: l10n.premiumBenefitFamily,
                ),
                const SizedBox(height: 8),
                if (isPremium)
                  Text(
                    l10n.purchaseSuccess,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
              ],
            ),
          ),
        ),
      ),
      // The buy and restore buttons are pinned under the pitch: a parent
      // reads the three lines, and the button is exactly where the
      // thumb already is, whatever the phone or the text size.
      bottomNavigationBar: isPremium
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed:
                          product == null ||
                              _uiState == PurchaseUiState.purchasing
                          ? null
                          : () async {
                              if (await ParentalGate.show(context)) {
                                purchases.buyPremium();
                              }
                            },
                      // Never hardcode a price — always read it from the
                      // Store's own ProductDetails (spec §73–§74).
                      child: ButtonLabel(
                        product != null
                            ? l10n.premiumCta(product.price)
                            : _uiState == PurchaseUiState.storeUnavailable ||
                                  _uiState == PurchaseUiState.error
                            ? l10n.storeUnavailableCta
                            : l10n.storeLoading,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () async {
                        if (await ParentalGate.show(context)) {
                          purchases.restorePurchases();
                        }
                      },
                      child: ButtonLabel(l10n.restorePurchases),
                    ),
                    if (_uiState == PurchaseUiState.storeUnavailable ||
                        _uiState == PurchaseUiState.error) ...[
                      const SizedBox(height: 12),
                      Text(
                        l10n.purchaseError,
                        style: TextStyle(color: colors.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.goldAccent.withValues(alpha: 0.18),
            ),
            child: Icon(icon, size: 20, color: colors.goldAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
