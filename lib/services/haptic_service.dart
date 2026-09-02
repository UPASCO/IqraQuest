import 'package:flutter/services.dart';

/// The board felt in the hand: one short buzz per key moment, chosen
/// so the hand can tell them apart without looking — a tick to pick a
/// horse up, a firmer tap when it is set down, a double knock when it
/// is dropped off its square, and a bonus that grows with its value.
///
/// Haptics are decoration: every failure (no vibrator, a desktop, a
/// widget test) is swallowed, and the user's own switch turns the
/// whole service off in one place.
class HapticService {
  HapticService();

  /// Kept in sync with AppSettings.hapticsEnabled by the provider.
  bool enabled = true;

  /// A horse touched or an answer picked: the lightest tick.
  Future<void> select() => _run(HapticFeedback.selectionClick);

  /// A horse lifted off the plate.
  Future<void> pickup() => _run(HapticFeedback.lightImpact);

  /// A horse set down on its destination: the move is made.
  Future<void> drop() => _run(HapticFeedback.mediumImpact);

  /// A horse dropped off its destination glides back: two quick knocks,
  /// unlike anything else on the board.
  Future<void> wrongDrop() async {
    await _run(HapticFeedback.lightImpact);
    await Future<void>.delayed(const Duration(milliseconds: 90));
    await _run(HapticFeedback.lightImpact);
  }

  /// A right answer: a firm tap. A wrong one: a soft one.
  Future<void> correct() => _run(HapticFeedback.mediumImpact);
  Future<void> wrong() => _run(HapticFeedback.lightImpact);

  /// The squares are won: the medallion lands.
  Future<void> earn() => _run(HapticFeedback.mediumImpact);

  /// A bonus square fires: +5 is a tap, +10 a firm one, +20 a heavy
  /// knock followed by a second — the biggest thing the board says.
  Future<void> bonus(int value) async {
    if (value >= 20) {
      await _run(HapticFeedback.heavyImpact);
      await Future<void>.delayed(const Duration(milliseconds: 120));
      await _run(HapticFeedback.heavyImpact);
    } else if (value >= 10) {
      await _run(HapticFeedback.heavyImpact);
    } else {
      await _run(HapticFeedback.mediumImpact);
    }
  }

  /// A capture, an arrival, a win.
  Future<void> heavy() => _run(HapticFeedback.heavyImpact);

  Future<void> _run(Future<void> Function() cue) async {
    if (!enabled) return;
    try {
      await cue();
    } catch (_) {
      // No vibrator here: the board stays silent to the hand.
    }
  }
}
