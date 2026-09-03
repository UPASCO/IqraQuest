// Pre-release gate (spec §120). Run with: `dart run tool/pre_release_check.dart`
//
// Checks the repository against IqraQuest 1.0's full target scope. Some
// checks are expected to FAIL on this v1 curated content pass — see
// README.md §Content scope and CONTENT_SOURCE_POLICY.md §10 for why: the
// content bank ships smaller than the 500×12 target rather than lower the
// "reject on doubt" sourcing bar (spec §52) to hit a number. This script
// reports that gap precisely instead of hiding it, and will pass cleanly
// once the content bank is scaled to the full target with the same
// per-question discipline.
import 'dart:convert';
import 'dart:io';

const targetQuestionCount = 500;
const targetFreeCount = 50;
const targetPremiumCount = 450;
const targetLanguages = ['fr', 'en', 'ar', 'es', 'pt', 'de', 'tr', 'id', 'ur', 'ms', 'it', 'nl'];
const targetCategoryCounts = {
  'prophets': 150,
  'sira': 150,
  'quran': 80,
  'faith': 70,
  'virtues': 50,
};
const targetDifficultyCounts = {'easy': 180, 'medium': 180, 'hard': 140};

const forbiddenStrings = [
  'TODO',
  'FIXME',
  'Lorem ipsum',
  'example.com',
  'placeholder',
  'coming soon',
  'test purchase',
];

int failures = 0;
int passes = 0;

void check(String name, bool condition, {String? detail}) {
  if (condition) {
    passes++;
    stdout.writeln('  PASS  $name');
  } else {
    failures++;
    stdout.writeln('  FAIL  $name${detail != null ? ' — $detail' : ''}');
  }
}

void section(String title) {
  stdout.writeln('\n=== $title ===');
}

void main() {
  final root = Directory.current;

  section('Question bank');
  final masterFile = File('${root.path}/assets/data/questions/master/questions.json');
  if (!masterFile.existsSync()) {
    check('master questions.json exists', false);
  } else {
    final master = (jsonDecode(masterFile.readAsStringSync()) as List).cast<Map<String, dynamic>>();
    check(
      'total question count == $targetQuestionCount',
      master.length == targetQuestionCount,
      detail: 'found ${master.length}',
    );

    final ids = master.map((q) => q['id'] as String).toList();
    check('no duplicate question ids', ids.toSet().length == ids.length);

    final freeCount = master.where((q) => q['isFree'] == true).length;
    check(
      'free question count == $targetFreeCount',
      freeCount == targetFreeCount,
      detail: 'found $freeCount',
    );
    check(
      'premium question count == $targetPremiumCount',
      master.length - freeCount == targetPremiumCount,
      detail: 'found ${master.length - freeCount}',
    );

    for (final entry in targetCategoryCounts.entries) {
      final count = master.where((q) => q['category'] == entry.key).length;
      check(
        'category "${entry.key}" count == ${entry.value}',
        count == entry.value,
        detail: 'found $count',
      );
    }
    for (final entry in targetDifficultyCounts.entries) {
      final count = master.where((q) => q['difficulty'] == entry.key).length;
      check(
        'difficulty "${entry.key}" count == ${entry.value}',
        count == entry.value,
        detail: 'found $count',
      );
    }

    check(
      'every question is verified',
      master.every((q) => q['sourceVerificationStatus'] == 'verified'),
    );
    check(
      'every question is non-controversial',
      master.every((q) => q['consensusStatus'] == 'nonControversial'),
    );
    check(
      'every question has a non-empty source reference',
      master.every((q) => (q['sourceReference'] as String).trim().isNotEmpty),
    );
    check(
      'no pending_human_review status exists in the schema',
      master.every(
        (q) =>
            q['sourceVerificationStatus'] == 'verified' ||
            q['sourceVerificationStatus'] == 'rejected',
      ),
    );

    section('Languages');
    for (final lang in targetLanguages) {
      final file = File('${root.path}/assets/data/questions/$lang/questions.json');
      if (!file.existsSync()) {
        check('$lang question content exists', false);
        continue;
      }
      final content = (jsonDecode(file.readAsStringSync()) as List).cast<Map<String, dynamic>>();
      check(
        '$lang has $targetQuestionCount question texts',
        content.length == targetQuestionCount,
        detail: 'found ${content.length}',
      );
    }
    final totalLinguisticContent = targetLanguages
        .map((lang) => File('${root.path}/assets/data/questions/$lang/questions.json'))
        .where((f) => f.existsSync())
        .map((f) => (jsonDecode(f.readAsStringSync()) as List).length)
        .fold<int>(0, (a, b) => a + b);
    check(
      'total linguistic content == ${targetQuestionCount * targetLanguages.length}',
      totalLinguisticContent == targetQuestionCount * targetLanguages.length,
      detail: 'found $totalLinguisticContent',
    );
  }

  section('No placeholders in shipped code/content');
  final libDir = Directory('${root.path}/lib');
  var placeholderHits = <String>[];
  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (entity.path.contains('${Platform.pathSeparator}l10n${Platform.pathSeparator}generated')) {
      continue;
    }
    final text = entity.readAsStringSync();
    for (final term in forbiddenStrings) {
      if (text.contains(term)) {
        placeholderHits.add('${entity.path}: "$term"');
      }
    }
  }
  check(
    'no forbidden placeholder strings in lib/',
    placeholderHits.isEmpty,
    detail: placeholderHits.join('; '),
  );

  section('Graphics');
  check('DESIGN_SYSTEM.md exists', File('${root.path}/DESIGN_SYSTEM.md').existsSync());
  check('app theme tokens file exists', File('${root.path}/lib/theme/app_theme.dart').existsSync());
  check(
    'a distinctive launcher icon has replaced the flutter template default',
    _hasCustomLauncherIcon(root),
    detail: 'regenerate from tool/art/source/app_icon_source.webp with tool/art/bake_app_icon.py (see ASSET_INVENTORY.md)',
  );

  section('Privacy & legal');
  check(
    'English privacy policy exists',
    File('${root.path}/legal/privacy_policy_en.md').existsSync(),
  );
  check(
    'French privacy policy exists',
    File('${root.path}/legal/privacy_policy_fr.md').existsSync(),
  );
  check(
    'CONTENT_SOURCE_POLICY.md exists',
    File('${root.path}/CONTENT_SOURCE_POLICY.md').existsSync(),
  );

  section('Android');
  final gradle = File('${root.path}/android/app/build.gradle.kts');
  check('build.gradle.kts exists', gradle.existsSync());
  if (gradle.existsSync()) {
    final text = gradle.readAsStringSync();
    check(
      'applicationId is set to a non-default package',
      text.contains('applicationId = "com.IqraQuest.com"'),
    );
  }

  section('iOS');
  final pbxproj = File('${root.path}/ios/Runner.xcodeproj/project.pbxproj');
  check('Xcode project exists', pbxproj.existsSync());
  final infoPlist = File('${root.path}/ios/Runner/Info.plist');
  check('Info.plist exists', infoPlist.existsSync());
  if (infoPlist.existsSync()) {
    final text = infoPlist.readAsStringSync();
    // Without this key App Store Connect stops every single upload at
    // "Missing Compliance" until the same question is answered by hand.
    final key = text.indexOf('<key>ITSAppUsesNonExemptEncryption</key>');
    check(
      'export compliance is declared in Info.plist',
      key >= 0 && text.substring(key).contains('<false/>'),
      detail:
          'add <key>ITSAppUsesNonExemptEncryption</key><false/> — the app '
          'uses only the operating system\'s own encryption (TLS, Keychain)',
    );
    check(
      'portrait-only builds opt out of iPad multitasking',
      text.contains('<key>UIRequiresFullScreen</key>'),
    );
  }

  section('Android');
  final manifest = File(
    '${root.path}/android/app/src/main/AndroidManifest.xml',
  );
  check('AndroidManifest.xml exists', manifest.existsSync());
  if (manifest.existsSync()) {
    final text = manifest.readAsStringSync();
    // A hard orientation lock in the manifest overrides main()'s rule and
    // would keep every Android tablet in portrait.
    check(
      'orientation is decided at runtime, not locked in the manifest',
      !text.contains('android:screenOrientation'),
      detail:
          'remove android:screenOrientation so a tablet can be turned; '
          'main() locks a phone to portrait from its shortest side',
    );
    check(
      'predictive back is opted into (Android 13+)',
      text.contains('android:enableOnBackInvokedCallback="true"'),
    );
    check('a round icon is declared', text.contains('android:roundIcon'));
  }
  final adaptive = File(
    '${root.path}/android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
  );
  // Without an adaptive icon Android 8+ letterboxes the square PNG on a
  // white plate, which is the most visible defect a launcher can show.
  check('adaptive launcher icon exists', adaptive.existsSync());
  for (final density in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']) {
    check(
      'adaptive icon foreground for $density',
      File(
        '${root.path}/android/app/src/main/res/mipmap-$density/'
        'ic_launcher_foreground.png',
      ).existsSync(),
      detail: 'run python3 tool/art/bake_app_icon.py',
    );
  }
  for (final dir in ['drawable', 'drawable-v21']) {
    final launch = File(
      '${root.path}/android/app/src/main/res/$dir/launch_background.xml',
    );
    check(
      'the $dir launch window is not white',
      launch.existsSync() && !launch.readAsStringSync().contains('@android:color/white'),
      detail: 'a white flash before a dark board is a visible defect',
    );
  }

  section('Race rules (no dice, no chance)');
  final engineFile = File('${root.path}/lib/features/game/domain/game_engine.dart');
  check('game_engine.dart exists', engineFile.existsSync());
  if (engineFile.existsSync()) {
    final text = engineFile.readAsStringSync();
    check('the engine imports no random source', !text.contains('dart:math'));
    check('the engine instantiates no Random', !text.contains('Random'));
  }

  // A functional dice reference anywhere in lib/ means the rules change is
  // incomplete. The migration service is allowed to *name* the old format
  // it detects, and the l10n bundle explains the change to the player.
  final diceOffenders = <String>[];
  for (final entity in Directory('${root.path}/lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (entity.path.endsWith('legacy_game_migration_service.dart')) continue;
    if (entity.path.contains('l10n/generated')) continue;
    final text = entity.readAsStringSync();
    for (final banned in const ['rollDice', 'DiceWidget', 'lastDiceValue', 'waitingForDice']) {
      if (text.contains(banned)) {
        diceOffenders.add('${entity.path.split('/lib/').last}: $banned');
      }
    }
  }
  check(
    'no dice API remains anywhere in lib/',
    diceOffenders.isEmpty,
    detail: diceOffenders.join(', '),
  );

  final circuitFile = File('${root.path}/lib/models/circuit.dart');
  check('the three circuits are defined', circuitFile.existsSync());
  if (circuitFile.existsSync()) {
    final text = circuitFile.readAsStringSync();
    check(
      'circuit effects are keyed per quadrant, so fairness is structural',
      text.contains('quadrantEffects'),
    );
    for (final id in const ['oasisRoute', 'caravanTrail', 'greatRide']) {
      check('circuit $id exists', text.contains(id));
    }
  }

  final gaitFile = File('${root.path}/lib/models/movement_choice.dart');
  if (gaitFile.existsSync()) {
    final text = gaitFile.readAsStringSync();
    check('gaits run 1 to 6', text.contains('minSteps = 1') && text.contains('maxSteps = 6'));
  }

  section('Purchases');
  final purchaseService = File('${root.path}/lib/services/purchase_service.dart');
  if (purchaseService.existsSync()) {
    final text = purchaseService.readAsStringSync();
    check(
      'no hardcoded price literal (e.g. "7.99" / "7,99") in purchase code',
      !RegExp(r'7[.,]99').hasMatch(text),
    );
    check(
      'price is read from ProductDetails, not hardcoded',
      text.contains('product.price') || text.contains('.price'),
    );
  }

  // The tester switch unlocks the Premium bank for nothing, so the one
  // thing that must never slip is its default: a build that nobody
  // compiled with --dart-define=IQRAQUEST_TESTER must not carry it.
  final flags = File('${root.path}/lib/app/build_flags.dart');
  check('build_flags.dart exists', flags.existsSync());
  if (flags.existsSync()) {
    final text = flags.readAsStringSync();
    check(
      'the tester unlock is off unless compiled in',
      text.contains("bool.fromEnvironment('IQRAQUEST_TESTER')") &&
          !text.contains('defaultValue: true'),
      detail: 'kTesterBuild must default to false',
    );
  }
  final settingsScreen = File(
    '${root.path}/lib/features/settings/presentation/settings_screen.dart',
  );
  if (settingsScreen.existsSync()) {
    final text = settingsScreen.readAsStringSync();
    check(
      'the tester switch is behind kTesterBuild',
      !text.contains('TesterModeTile') || text.contains('if (kTesterBuild)'),
      detail: 'an App Store build must not show a way to unlock Premium',
    );
  }

  stdout.writeln('\n================================');
  stdout.writeln('$passes passed, $failures failed');
  if (failures > 0) {
    stdout.writeln('PRE-RELEASE CHECK FAILED');
    exit(1);
  } else {
    stdout.writeln('PRE-RELEASE CHECK PASSED');
  }
}

bool _hasCustomLauncherIcon(Directory root) {
  // The icon is baked by tool/art/bake_app_icon.py. The
  // stock `flutter create` placeholder 1024px icon is ~10 KB; the
  // rendered IqraQuest artwork is far larger, so a size floor cleanly
  // separates "template still in place" from "real icon shipped".
  final marketing = File(
    '${root.path}/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png',
  );
  if (!marketing.existsSync() || marketing.lengthSync() < 50 * 1024) return false;
  for (final density in const ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']) {
    if (!File('${root.path}/android/app/src/main/res/mipmap-$density/ic_launcher.png')
        .existsSync()) {
      return false;
    }
  }
  return true;
}
