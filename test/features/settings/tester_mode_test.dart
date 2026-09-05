// "Pourquoi je vois que les 50 mêmes questions à chaque fois ?"
//
// Because the build is the free edition, and the free edition draws from
// the 50 questions marked free — 1,050 of the bank's 1,100 are behind the
// purchase. That is the bank working as designed, but it leaves a tester
// unable to read the content they are shipping.
//
// The tester switch flips the same local entitlement a purchase would, so
// the whole bank is in play. These pin the two things that matter about
// it: that it actually widens the bank, and that it is not in the binary
// that goes to the App Store.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/app/build_flags.dart';
import 'package:iqraquest/app/providers.dart';
import 'package:iqraquest/features/settings/presentation/settings_screen.dart';
import 'package:iqraquest/features/settings/presentation/tester_mode_tile.dart';
import 'package:iqraquest/l10n/generated/app_localizations.dart';
import 'package:iqraquest/l10n/generated/app_localizations_fr.dart';
import 'package:iqraquest/services/entitlement_service.dart';
import 'package:iqraquest/services/local_storage_service.dart';
import 'package:iqraquest/services/question_repository.dart';
import 'package:iqraquest/services/settings_service.dart';
import 'package:iqraquest/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The real one writes to the Keychain, which no test harness has.
class _MemoryEntitlements implements EntitlementService {
  bool _premium = false;

  @override
  Future<bool> isPremium() async => _premium;

  @override
  Future<void> grantPremium() async => _premium = true;

  @override
  Future<void> revokePremium() async => _premium = false;
}

Future<void> _pump(WidgetTester tester, Widget home) async {
  SharedPreferences.setMockInitialValues({});
  final storage = await LocalStorageService.create();
  // The bank is read off disk, which the fake-async zone a widget test
  // runs in never lets finish — so it is loaded for real out here and
  // handed to the provider already resolved.
  final pool = await tester.runAsync(() => QuestionRepository().loadAll('fr'));
  tester.view.physicalSize = const Size(420, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsServiceProvider.overrideWithValue(SettingsService(storage)),
        entitlementServiceProvider.overrideWithValue(_MemoryEntitlements()),
        questionRepositoryProvider.overrideWithValue(QuestionRepository()),
        questionPoolProvider.overrideWith((ref) => pool!),
        initialSettingsProvider.overrideWithValue(const AppSettings()),
        initialPremiumProvider.overrideWithValue(false),
      ],
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light('fr'),
        home: Scaffold(body: home),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final fr = AppLocalizationsFr();

  testWidgets('the switch widens the bank from the free 50 to all 1100', (
    tester,
  ) async {
    await _pump(tester, const TesterModeTile());

    final count = find.byKey(const Key('tester-bank-count'));
    expect(
      tester.widget<Text>(count).data,
      fr.testerBankPlayable(50, 1100),
      reason: 'the free edition should report only the free questions',
    );

    await tester.tap(find.byKey(const Key('tester-mode-toggle')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(count).data,
      fr.testerBankPlayable(1100, 1100),
      reason: 'the whole bank should be in play once the switch is on',
    );

    // And back, so the free experience can be checked on the same device.
    await tester.tap(find.byKey(const Key('tester-mode-toggle')));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(count).data, fr.testerBankPlayable(50, 1100));
  });

  testWidgets('the settings carry the switch only in a tester build', (
    tester,
  ) async {
    await _pump(tester, const SettingsScreen());
    final toggle = find.byKey(const Key('tester-mode-toggle'));
    if (kTesterBuild) {
      // Run the suite with --dart-define=IQRAQUEST_TESTER=true to take
      // this branch: it proves the switch is reachable when it should be.
      expect(toggle, findsOneWidget);
    } else {
      // Plain `flutter test` compiles exactly the App Store binary's
      // configuration, and that binary must offer no way to unlock
      // Premium for nothing.
      expect(toggle, findsNothing);
      expect(find.text(fr.testerMode), findsNothing);
    }
  });
}
