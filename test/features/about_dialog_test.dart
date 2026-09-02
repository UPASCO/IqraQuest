import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/app/app_version.dart';
import 'package:iqraquest/features/settings/presentation/settings_screen.dart';
import 'package:iqraquest/l10n/generated/app_localizations.dart';
import 'package:iqraquest/l10n/generated/app_localizations_fr.dart';
import 'package:iqraquest/theme/app_theme.dart';

/// Settings › About must carry the IqraQuest copyright: the concept,
/// rules, artwork and content are the project's own and the notice is
/// the one place a reader looks for who owns them.
final fr = AppLocalizationsFr();

void main() {
  test('the copyright years run from the first year to the current one', () {
    expect(copyrightYears(DateTime(kCopyrightStartYear, 9, 2)), '2026');
    expect(copyrightYears(DateTime(kCopyrightStartYear + 2)), '2026–2028');
    // Never earlier than the first publication, whatever the clock says.
    expect(copyrightYears(DateTime(kCopyrightStartYear - 1)), '2026');
  });

  testWidgets('the About dialog names IqraQuest as the rights holder', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light('fr'),
        home: AboutIqraQuestDialog(now: DateTime(2026, 9, 2)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(fr.aboutDialogTitle), findsOneWidget);
    expect(find.text('© 2026 IqraQuest. Tous droits réservés.'), findsOneWidget);
    expect(find.text(fr.versionLabel(kAppVersion)), findsOneWidget);
    expect(find.text(fr.originalWorkNotice), findsOneWidget);
  });
}
