import 'dart:io' show Platform;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// The game's sound cues, all synthesized in-house by
/// `tool/audio/gen_sfx.py` (spec §26-27: warm and short, no recitation,
/// no adhan, no casino jingles).
enum Sfx {
  tap('tap'),
  gaitSelect('gait_select'),
  gaitConfirm('gait_confirm'),
  moveHoofs('move_hoofs'),
  correct('correct'),
  wrong('wrong'),
  chest('chest'),
  streak('streak'),
  water('water'),
  victory('victory');

  const Sfx(this.file);

  final String file;
}

/// Plays short SFX from `assets/audio/`. Sound is decoration: every
/// failure (missing plugin in widget tests, platform quirks, races on
/// dispose) is swallowed so audio can never break a game in progress.
class SoundService {
  SoundService();

  /// Kept in sync with AppSettings.soundEnabled by the provider.
  bool enabled = true;

  static const _poolSize = 4;
  final List<AudioPlayer> _pool = [];
  int _next = 0;
  bool _broken = false;

  /// The audioplayers plugin registers async platform channels whose
  /// MissingPluginExceptions escape any try/catch under `flutter test`,
  /// so the widget-test environment is detected up front.
  static final bool _inTest = () {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }();

  Future<void> play(Sfx sfx) async {
    if (!enabled || _broken || _inTest) return;
    try {
      if (_pool.isEmpty) {
        for (var i = 0; i < _poolSize; i++) {
          final p = AudioPlayer();
          await p.setReleaseMode(ReleaseMode.stop);
          _pool.add(p);
        }
      }
      final player = _pool[_next];
      _next = (_next + 1) % _pool.length;
      await player.stop();
      await player.play(AssetSource('audio/${sfx.file}.wav'));
    } catch (e) {
      // No audio backend here (tests, simulators without sound):
      // stay silent from now on instead of retrying every cue.
      _broken = true;
      debugPrint('SoundService disabled: $e');
    }
  }

  Future<void> dispose() async {
    for (final p in _pool) {
      try {
        await p.dispose();
      } catch (_) {}
    }
    _pool.clear();
  }
}
