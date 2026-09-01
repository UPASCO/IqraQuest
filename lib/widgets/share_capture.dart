import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Renders the [RepaintBoundary] behind [key] to a PNG at share quality,
/// or `null` when it is not on screen — a share must never break the
/// screen that offers it.
Future<Uint8List?> captureBoundaryPng(GlobalKey key, {double pixelRatio = 3}) async {
  final boundary = key.currentContext?.findRenderObject();
  if (boundary is! RenderRepaintBoundary) return null;
  try {
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return bytes?.buffer.asUint8List();
  } catch (e) {
    debugPrint('captureBoundaryPng failed: $e');
    return null;
  }
}

/// Screen rect of the widget behind [key]; iPad anchors its share
/// popover to the button that opened it.
Rect? shareOriginOf(GlobalKey key) {
  final box = key.currentContext?.findRenderObject();
  if (box is RenderBox && box.hasSize) {
    return box.localToGlobal(Offset.zero) & box.size;
  }
  return null;
}
