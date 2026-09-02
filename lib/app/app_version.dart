/// The version shown in Settings › About. Mirrors `version:` in
/// `pubspec.yaml`; `test/quality/app_version_test.dart` fails the build
/// if the two drift apart, so this never lies to a reviewer.
const String kAppVersion = '1.0.0';

/// The first year IqraQuest was published; the copyright line in
/// Settings › About runs from here to the current year.
const int kCopyrightStartYear = 2026;

/// "2026" the first year, "2026–2028" later — never a stale single year.
String copyrightYears(DateTime now) {
  final year = now.year;
  return year > kCopyrightStartYear ? '$kCopyrightStartYear–$year' : '$kCopyrightStartYear';
}
