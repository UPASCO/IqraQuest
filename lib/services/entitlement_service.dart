import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Tracks whether Premium (`iqraquest_full_access`) is unlocked.
///
/// Stored with [FlutterSecureStorage] (spec §30/§78) so the entitlement
/// survives app reinstall-adjacent storage clears better than plain
/// preferences and so it works fully offline once granted — the Store is
/// only consulted to *establish* or *reconcile* the entitlement, never to
/// gate day-to-day play (spec §78).
class EntitlementService {
  EntitlementService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'iqraquest.entitlement.premium';

  final FlutterSecureStorage _storage;

  Future<bool> isPremium() async {
    final value = await _storage.read(key: _key);
    return value == 'true';
  }

  Future<void> grantPremium() => _storage.write(key: _key, value: 'true');

  /// Used only for restore-purchase reconciliation when the Store reports
  /// no active entitlement for this account.
  Future<void> revokePremium() => _storage.delete(key: _key);
}
