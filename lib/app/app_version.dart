/// The version shown in Settings › About. Mirrors `version:` in
/// `pubspec.yaml`; `test/quality/app_version_test.dart` fails the build
/// if the two drift apart, so this never lies to a reviewer.
const String kAppVersion = '1.0.0';
