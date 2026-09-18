import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../app/build_flags.dart';

/// The device's Premium right, kept in the secure store (Keychain on
/// iOS, EncryptedSharedPreferences on Android).
///
/// Two separate flags, on purpose:
///
/// - the **purchase**, written by [PurchaseService] when the Store
///   reports a purchase or a restore, and read by every build;
/// - the **tester unlock**, written by Settings › Tester mode in a
///   tester build, and read by a tester build only.
///
/// The first version kept one flag for both, and it leaked: the
/// Keychain survives an uninstall, so a phone that had once flipped
/// the tester switch opened the *store* build already unlocked, with no
/// purchase behind it. A store build now ignores the tester flag
/// altogether, so nothing a tester build did on a device can carry into
/// what the App Store or Play delivers. The old shared flag is cleared
/// the first time it is met; no published build ever wrote a purchase
/// under it.
class EntitlementService {
  EntitlementService({
    FlutterSecureStorage? storage,
    bool testerBuild = kTesterBuild,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       // Private on purpose, so the in-memory fakes in the tests need
       // not grow a field that means nothing to them.
       // ignore: prefer_initializing_formals
       _testerBuild = testerBuild;

  static const _purchaseKey = 'iqraquest.entitlement.purchase';
  static const _testerKey = 'iqraquest.entitlement.tester';

  /// The flag both paths used to share. Read by nobody now; deleted
  /// when found so it cannot confuse anyone reading the store later.
  static const _legacyKey = 'iqraquest.entitlement.premium';

  final FlutterSecureStorage _storage;

  /// Whether the tester flag counts: true in a tester build only.
  final bool _testerBuild;

  /// Whether this device is Premium: bought, or — in a tester build
  /// only — unlocked by the tester switch.
  Future<bool> isPremium() async {
    if (await _storage.read(key: _legacyKey) != null) {
      await _storage.delete(key: _legacyKey);
    }
    if (await _storage.read(key: _purchaseKey) == 'true') return true;
    if (!_testerBuild) return false;
    return await _storage.read(key: _testerKey) == 'true';
  }

  /// The Store said so: a purchase, or a restore.
  Future<void> grantPremium() =>
      _storage.write(key: _purchaseKey, value: 'true');

  /// Used only for restore-purchase reconciliation when the Store reports
  /// no active entitlement for this account.
  Future<void> revokePremium() => _storage.delete(key: _purchaseKey);

  /// Settings › Tester mode, on. Written in any build, honoured by a
  /// tester build only.
  Future<void> grantTester() => _storage.write(key: _testerKey, value: 'true');

  /// Settings › Tester mode, off.
  Future<void> revokeTester() => _storage.delete(key: _testerKey);
}
