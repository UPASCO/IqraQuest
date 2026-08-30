import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/app/app.dart';
import 'package:iqraquest/app/providers.dart';
import 'package:iqraquest/app/router.dart';
import 'package:iqraquest/services/entitlement_service.dart';
import 'package:iqraquest/services/game_save_service.dart';
import 'package:iqraquest/services/local_storage_service.dart';
import 'package:iqraquest/services/progress_service.dart';
import 'package:iqraquest/services/purchase_service.dart';
import 'package:iqraquest/services/question_repository.dart';
import 'package:iqraquest/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App boots to the home screen without crashing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.create();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsServiceProvider.overrideWithValue(SettingsService(storage)),
          entitlementServiceProvider.overrideWithValue(EntitlementService()),
          progressServiceProvider.overrideWithValue(ProgressService(storage)),
          gameSaveServiceProvider.overrideWithValue(GameSaveService(storage)),
          questionRepositoryProvider.overrideWithValue(QuestionRepository()),
          purchaseServiceProvider.overrideWithValue(PurchaseService()),
          initialSettingsProvider.overrideWithValue(const AppSettings()),
          initialPremiumProvider.overrideWithValue(false),
          appRouterProvider.overrideWithValue(buildAppRouter(initialLocation: '/home')),
        ],
        child: const IqraQuestApp(),
      ),
    );
    // Not pumpAndSettle: the home screen's idle horse animation repeats
    // forever by design (spec §24), so it never "settles".
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('IqraQuest'), findsWidgets);
  });
}
