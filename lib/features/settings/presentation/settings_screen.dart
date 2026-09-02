import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_version.dart';
import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';

const _supportedLanguages = [
  ('fr', 'Français'),
  ('en', 'English'),
  ('ar', 'العربية'),
  ('es', 'Español'),
  ('pt', 'Português'),
  ('de', 'Deutsch'),
  ('tr', 'Türkçe'),
  ('id', 'Bahasa Indonesia'),
  ('ur', 'اردو'),
  ('ms', 'Bahasa Melayu'),
  ('it', 'Italiano'),
  ('nl', 'Nederlands'),
];

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final language = ref.watch(effectiveLanguageProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SafeArea(
        child: ListView(
          children: [
            // The picker sits under its label rather than beside it: as
            // `trailing` it shared one row's height with the title and
            // overflowed a 320 px screen at accessibility text sizes.
            ListTile(
              title: Text(l10n.language),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: DropdownButton<String>(
                  value: language,
                  isExpanded: true,
                  items: [
                    for (final (code, label) in _supportedLanguages)
                      DropdownMenuItem(
                        value: code,
                        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (code) {
                    if (code != null) controller.setLanguage(code);
                  },
                ),
              ),
            ),
            SwitchListTile(
              title: Text(l10n.darkMode),
              value: settings.themeMode == ThemeMode.dark,
              onChanged: (v) => controller.setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
            ),
            SwitchListTile(
              title: Text(l10n.reduceMotion),
              value: settings.reduceMotion,
              onChanged: controller.setReduceMotion,
            ),
            SwitchListTile(
              title: Text(l10n.soundEffects),
              value: settings.soundEnabled,
              onChanged: controller.setSoundEnabled,
            ),
            SwitchListTile(
              key: const Key('haptics-toggle'),
              title: Text(l10n.hapticFeedback),
              value: settings.hapticsEnabled,
              onChanged: controller.setHapticsEnabled,
            ),
            const Divider(),
            ListTile(
              title: Text(l10n.privacyPolicy),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.privacyPolicy),
                  content: Text(l10n.privacySummary),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(MaterialLocalizations.of(context).okButtonLabel),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: Text(l10n.howToPlay),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/tutorial'),
            ),
            ListTile(
              key: const Key('about-tile'),
              title: Text(l10n.about),
              subtitle: Text(
                '${l10n.appName} · $kAppVersion · '
                '${l10n.copyrightNotice(copyrightYears(DateTime.now()))}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showDialog<void>(
                context: context,
                builder: (context) => AboutIqraQuestDialog(
                  now: DateTime.now(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Settings › About: the app's identity and the copyright it rests on.
/// The notice is worded as a legal claim, not a footer — the concept,
/// rules, artwork and content are the project's own work.
class AboutIqraQuestDialog extends StatelessWidget {
  const AboutIqraQuestDialog({super.key, required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      key: const Key('about-dialog'),
      title: Text(l10n.aboutDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appName,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(l10n.appTagline, style: textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text(l10n.versionLabel(kAppVersion), style: textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text(
              l10n.copyrightNotice(copyrightYears(now)),
              key: const Key('about-copyright'),
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.originalWorkNotice,
              style: textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}
