import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import 'entitlement_service.dart';

/// The single non-consumable product IqraQuest sells (spec §73). Never
/// hardcode a price anywhere in the UI — always read [ProductDetails.price]
/// from the Store (spec §73–§74).
const String kPremiumProductId = 'iqraquest_full_access';

enum PurchaseUiState {
  idle,
  storeUnavailable,
  loadingProduct,
  purchasing,
  purchased,
  restored,
  pending,
  canceled,
  error,
}

/// Wraps `in_app_purchase` (StoreKit on iOS, Google Play Billing on
/// Android — spec §76: never Stripe/PayPal/web checkout/crypto) and
/// reconciles the result into [EntitlementService].
class PurchaseService {
  PurchaseService({InAppPurchase? iap, EntitlementService? entitlements})
    : _iap = iap ?? InAppPurchase.instance,
      _entitlements = entitlements ?? EntitlementService();

  final InAppPurchase _iap;
  final EntitlementService _entitlements;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final _stateController = StreamController<PurchaseUiState>.broadcast();
  Stream<PurchaseUiState> get stateStream => _stateController.stream;

  /// The last state emitted. [initialize] runs at bootstrap, long before
  /// the premium screen subscribes, and a broadcast stream does not
  /// replay: without this a store that answered "unavailable" during
  /// startup left the screen on "connecting to the store…" forever.
  PurchaseUiState get state => _state;
  PurchaseUiState _state = PurchaseUiState.idle;

  void _emit(PurchaseUiState s) {
    _state = s;
    _stateController.add(s);
  }

  ProductDetails? _premiumProduct;
  ProductDetails? get premiumProduct => _premiumProduct;

  Future<void> initialize() async {
    _emit(PurchaseUiState.loadingProduct);
    final bool available;
    try {
      available = await _iap.isAvailable();
    } catch (_) {
      // No store plugin on this platform (web preview, some test rigs):
      // the screen must say so rather than spin.
      _emit(PurchaseUiState.storeUnavailable);
      return;
    }
    if (!available) {
      _emit(PurchaseUiState.storeUnavailable);
      return;
    }

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (_) => _emit(PurchaseUiState.error),
    );

    _emit(PurchaseUiState.loadingProduct);
    final response = await _iap.queryProductDetails({kPremiumProductId});
    if (response.error != null || response.productDetails.isEmpty) {
      _emit(PurchaseUiState.error);
      return;
    }
    _premiumProduct = response.productDetails.first;
    _emit(PurchaseUiState.idle);
  }

  Future<void> buyPremium() async {
    final product = _premiumProduct;
    if (product == null) {
      _emit(PurchaseUiState.error);
      return;
    }
    _emit(PurchaseUiState.purchasing);
    final param = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
    } catch (_) {
      _emit(PurchaseUiState.error);
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _emit(PurchaseUiState.pending);
        case PurchaseStatus.purchased:
          _entitlements.grantPremium();
          _emit(PurchaseUiState.purchased);
          _complete(purchase);
        case PurchaseStatus.restored:
          _entitlements.grantPremium();
          _emit(PurchaseUiState.restored);
          _complete(purchase);
        case PurchaseStatus.error:
          _emit(PurchaseUiState.error);
          _complete(purchase);
        case PurchaseStatus.canceled:
          _emit(PurchaseUiState.canceled);
          _complete(purchase);
      }
    }
  }

  void _complete(PurchaseDetails purchase) {
    if (purchase.pendingCompletePurchase) {
      _iap.completePurchase(purchase);
    }
  }

  void dispose() {
    _subscription?.cancel();
    _stateController.close();
  }
}
