import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
            ListTile(
              title: Text(l10n.language),
              trailing: DropdownButton<String>(
                value: language,
                items: [
                  for (final (code, label) in _supportedLanguages)
                    DropdownMenuItem(value: code, child: Text(label)),
                ],
                onChanged: (code) {
                  if (code != null) controller.setLanguage(code);
                },
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
              title: Text('Sound'),
              value: settings.soundEnabled,
              onChanged: controller.setSoundEnabled,
            ),
            const Divider(),
            ListTile(
              title: Text(l10n.privacyPolicy),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.privacyPolicy),
                  content: const Text(
                    'IqraQuest collects no personal data, has no account, '
                    'no backend, and no advertising. Progress and settings '
                    'stay on this device. See legal/privacy_policy_en.md '
                    'in the app repository for the full policy.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: const Text('How to play'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/tutorial'),
            ),
            ListTile(title: Text(l10n.about), subtitle: const Text('IqraQuest 1.0')),
          ],
        ),
      ),
    );
  }
}
