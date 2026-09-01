import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/app/app_version.dart';

void main() {
  test('kAppVersion mirrors pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(r'^version:\s*([0-9.]+)', multiLine: true).firstMatch(pubspec);
    expect(match, isNotNull, reason: 'pubspec.yaml must declare a version');
    expect(kAppVersion, match!.group(1));
  });
}
