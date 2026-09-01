// The premium screen subscribes to the purchase service long after
// `initialize()` ran at bootstrap. A broadcast stream does not replay,
// so the service has to remember what the store said — otherwise a
// store that answered "unavailable" during startup leaves the screen on
// "connecting to the store…" for good.
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:iqraquest/services/entitlement_service.dart';
import 'package:iqraquest/services/purchase_service.dart';

/// Only the two calls `initialize()` makes on an unavailable store.
class _NoStore implements InAppPurchase {
  _NoStore({this.throws = false});

  final bool throws;

  @override
  Future<bool> isAvailable() async {
    if (throws) throw UnimplementedError('no store plugin on this platform');
    return false;
  }

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} must not be called');
}

void main() {
  test('an unavailable store is remembered for late subscribers', () async {
    final service = PurchaseService(
      iap: _NoStore(),
      entitlements: EntitlementService(),
    );
    await service.initialize();
    expect(service.state, PurchaseUiState.storeUnavailable);
    expect(service.premiumProduct, isNull);
  });

  test(
    'a platform without a store plugin reads as unavailable, not a crash',
    () async {
      final service = PurchaseService(
        iap: _NoStore(throws: true),
        entitlements: EntitlementService(),
      );
      await service.initialize();
      expect(service.state, PurchaseUiState.storeUnavailable);
    },
  );

  test('state is pushed to live listeners as well as remembered', () async {
    final service = PurchaseService(
      iap: _NoStore(),
      entitlements: EntitlementService(),
    );
    final seen = <PurchaseUiState>[];
    service.stateStream.listen(seen.add);
    await service.initialize();
    await Future<void>.delayed(Duration.zero);
    expect(seen, [
      PurchaseUiState.loadingProduct,
      PurchaseUiState.storeUnavailable,
    ]);
  });
}
