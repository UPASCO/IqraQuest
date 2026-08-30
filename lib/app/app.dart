import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import 'providers.dart';
import 'router.dart' show appRouterProvider;

class IqraQuestApp extends ConsumerWidget {
  const IqraQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final languageCode = ref.watch(effectiveLanguageProvider);
    final isRtl = AppFonts.isRtl(languageCode);

    return MaterialApp.router(
      title: 'IqraQuest',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(appRouterProvider),
      themeMode: settings.themeMode,
      theme: AppTheme.light(languageCode),
      darkTheme: AppTheme.dark(languageCode),
      locale: Locale(languageCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) {
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: settings.reduceMotion || MediaQuery.of(context).disableAnimations,
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
