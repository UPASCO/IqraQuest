import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/services/entitlement_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test(
    'a fresh device is free, in a store build and in a tester build',
    () async {
      expect(await EntitlementService(testerBuild: false).isPremium(), isFalse);
      expect(await EntitlementService(testerBuild: true).isPremium(), isFalse);
    },
  );

  test('a purchase is Premium in every build', () async {
    await EntitlementService(testerBuild: false).grantPremium();
    expect(await EntitlementService(testerBuild: false).isPremium(), isTrue);
    expect(await EntitlementService(testerBuild: true).isPremium(), isTrue);
  });

  test('the tester switch unlocks a tester build only', () async {
    // The switch flipped on a tester build, then the store build
    // installed over it: the Keychain keeps the flag, the store build
    // must not honour it.
    await EntitlementService(testerBuild: true).grantTester();
    expect(await EntitlementService(testerBuild: true).isPremium(), isTrue);
    expect(await EntitlementService(testerBuild: false).isPremium(), isFalse);

    await EntitlementService(testerBuild: true).revokeTester();
    expect(await EntitlementService(testerBuild: true).isPremium(), isFalse);
  });

  test('the tester switch off leaves a purchase in place', () async {
    final tester = EntitlementService(testerBuild: true);
    await tester.grantPremium();
    await tester.grantTester();
    await tester.revokeTester();
    expect(await tester.isPremium(), isTrue);
  });

  test('the old shared flag is ignored and cleared', () async {
    FlutterSecureStorage.setMockInitialValues({
      'iqraquest.entitlement.premium': 'true',
    });
    expect(await EntitlementService(testerBuild: false).isPremium(), isFalse);
    expect(await EntitlementService(testerBuild: true).isPremium(), isFalse);
    expect(
      await const FlutterSecureStorage().read(
        key: 'iqraquest.entitlement.premium',
      ),
      isNull,
    );
  });
}
