import 'dart:async';

import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../domain/classroom_state.dart';

/// The seconds left on the open question.
///
/// The teacher can set a timer and the server enforces it, but until now
/// nothing showed it: a card closed without warning. This reads the
/// room's own stamp rather than counting locally, so a projector and
/// twenty-five phones agree to within the second — and it simply does
/// not build when the teacher chose to reveal by hand, which is the
/// default.
class ClassroomCountdown extends StatefulWidget {
  const ClassroomCountdown({
    super.key,
    required this.room,
    this.fontSize = 22,
    this.now,
  });

  final ClassroomState room;
  final double fontSize;

  /// Injected in tests; the wall clock otherwise.
  final DateTime Function()? now;

  @override
  State<ClassroomCountdown> createState() => _ClassroomCountdownState();
}

class _ClassroomCountdownState extends State<ClassroomCountdown> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.room.remaining(now: widget.now?.call());
    if (left == null) return const SizedBox.shrink();

    final colors = context.colors;
    final seconds = left.inSeconds;
    // The last ten seconds are the ones a class watches; they get the
    // warning colour, and nothing else changes so the card stays the
    // thing being read.
    final urgent = seconds <= 10;

    return Row(
      key: const Key('classroom-countdown'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer_outlined,
          size: widget.fontSize * 1.05,
          color: urgent ? colors.warning : colors.textSecondary,
        ),
        SizedBox(width: widget.fontSize * 0.35),
        Text(
          '$seconds s',
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: urgent ? colors.warning : colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
