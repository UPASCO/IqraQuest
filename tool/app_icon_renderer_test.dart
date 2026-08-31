// Renders the IqraQuest launcher icon — an original vector design — to
// every PNG size Android, iOS and the web target need, plus a 1024px
// review copy in build/screenshots/.
//
// Deliberately OUTSIDE test/ so a plain `flutter test` never rewrites
// files in the source tree. Run it only when the icon design changes:
//
//   flutter test tool/app_icon_renderer_test.dart
//   python3 tool/strip_icon_alpha.py   # App Store: no alpha channel
//
// Design constraints honoured (spec §23 + religious constraints): an
// arabian horse head with an eight-point star lattice — no depiction of
// any person, no Kaaba-as-object, no text.
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// The icon, drawn in a unit square scaled to [size]. `inset` shrinks the
/// artwork about the centre while the background still bleeds full-frame —
/// used for Android/web maskable icons whose outer ~10-20% may be cropped.
class AppIconPainter extends CustomPainter {
  const AppIconPainter({this.inset = 0});

  final double inset;

  static const _skyTop = Color(0xFF10493A);
  static const _skyBottom = Color(0xFF072B21);
  static const _gold = Color(0xFFD8A94E);
  static const _goldDeep = Color(0xFFB8893A);
  static const _ivory = Color(0xFFF4ECDC);
  static const _ivoryShade = Color(0xFFDECFB4);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    Offset p(double x, double y) => Offset(x * s, y * s);

    // --- Night-emerald ground, full bleed ---
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = ui.Gradient.linear(p(0.5, 0), p(0.5, 1), [_skyTop, _skyBottom]),
    );

    // A soft radial glow behind the head so the silhouette lifts off the
    // ground even at 20px.
    canvas.drawCircle(
      p(0.46, 0.46),
      0.52 * s,
      Paint()
        ..shader = ui.Gradient.radial(p(0.46, 0.46), 0.52 * s, [
          const Color(0x2EF4ECDC),
          const Color(0x00F4ECDC),
        ]),
    );

    // --- Faint eight-point star, fully inside the frame ---
    canvas.save();
    canvas.translate(0.5 * s, 0.52 * s);
    final star = Path();
    for (var i = 0; i < 16; i++) {
      final r = (i.isEven ? 0.46 : 0.335) * s;
      final a = i * math.pi / 8 - math.pi / 2;
      final v = Offset(math.cos(a) * r, math.sin(a) * r);
      i == 0 ? star.moveTo(v.dx, v.dy) : star.lineTo(v.dx, v.dy);
    }
    star.close();
    canvas.drawPath(
      star,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.011 * s
        ..color = _gold.withValues(alpha: 0.26),
    );
    canvas.restore();

    // --- The horse, inset-scaled about the centre for maskable targets ---
    canvas.save();
    if (inset > 0) {
      canvas.translate(0.5 * s, 0.5 * s);
      canvas.scale(1 - inset);
      canvas.translate(-0.5 * s, -0.5 * s);
    }

    // Mane first: a gold ribbon running just outside the crest, so the
    // head drawn on top of it tucks it against the neck with no gap.
    final mane = Path()
      ..moveTo(0.452 * s, 0.150 * s)
      ..cubicTo(0.580 * s, 0.210 * s, 0.700 * s, 0.330 * s, 0.762 * s, 0.530 * s)
      ..cubicTo(0.800 * s, 0.680 * s, 0.812 * s, 0.840 * s, 0.808 * s, 0.975 * s)
      ..lineTo(0.640 * s, 0.975 * s)
      ..cubicTo(0.648 * s, 0.780 * s, 0.630 * s, 0.560 * s, 0.560 * s, 0.380 * s)
      ..cubicTo(0.520 * s, 0.286 * s, 0.470 * s, 0.208 * s, 0.418 * s, 0.164 * s)
      ..close();
    canvas.drawPath(
      mane,
      Paint()..shader = ui.Gradient.linear(p(0.45, 0.10), p(0.80, 0.95), [_gold, _goldDeep]),
    );
    // Head on a diagonal axis: muzzle low-left, poll high-centre, the
    // crest a proud arch sweeping down to the bottom right. Long dished
    // face and a fine muzzle are what make it read as an Arabian.
    final head = Path()
      // Chest, bottom left of the neck.
      ..moveTo(0.415 * s, 0.975 * s)
      // Front of the neck: concave sweep up toward the throat latch.
      ..cubicTo(0.408 * s, 0.800 * s, 0.390 * s, 0.640 * s, 0.352 * s, 0.545 * s)
      // Round jowl.
      ..cubicTo(0.322 * s, 0.585 * s, 0.286 * s, 0.607 * s, 0.248 * s, 0.607 * s)
      // Chin and the underside of the muzzle.
      ..cubicTo(0.208 * s, 0.607 * s, 0.178 * s, 0.592 * s, 0.163 * s, 0.566 * s)
      // Muzzle front: short and refined, angled with the head axis.
      ..cubicTo(0.148 * s, 0.540 * s, 0.150 * s, 0.508 * s, 0.170 * s, 0.487 * s)
      // Dished face rising along the nose bridge to the forehead.
      ..cubicTo(0.230 * s, 0.420 * s, 0.298 * s, 0.330 * s, 0.352 * s, 0.238 * s)
      // Poll, near ear.
      ..cubicTo(0.362 * s, 0.215 * s, 0.372 * s, 0.195 * s, 0.386 * s, 0.178 * s)
      ..cubicTo(0.388 * s, 0.140 * s, 0.398 * s, 0.112 * s, 0.416 * s, 0.092 * s)
      ..cubicTo(0.432 * s, 0.118 * s, 0.438 * s, 0.148 * s, 0.434 * s, 0.172 * s)
      // Far ear, hinted shorter behind the near one.
      ..cubicTo(0.452 * s, 0.158 * s, 0.470 * s, 0.154 * s, 0.486 * s, 0.158 * s)
      ..cubicTo(0.485 * s, 0.178 * s, 0.477 * s, 0.198 * s, 0.462 * s, 0.214 * s)
      // Crest: high arch flowing right and down to the shoulder.
      ..cubicTo(0.560 * s, 0.290 * s, 0.630 * s, 0.420 * s, 0.668 * s, 0.590 * s)
      ..cubicTo(0.692 * s, 0.720 * s, 0.700 * s, 0.860 * s, 0.698 * s, 0.975 * s)
      ..close();

    canvas.drawPath(
      head,
      Paint()..shader = ui.Gradient.linear(p(0.18, 0.35), p(0.70, 0.97), [_ivory, _ivoryShade]),
    );

    // Eye: dark almond set high and forward, with a keeper highlight.
    final eye = Path()
      ..moveTo(0.318 * s, 0.388 * s)
      ..quadraticBezierTo(0.344 * s, 0.366 * s, 0.368 * s, 0.376 * s)
      ..quadraticBezierTo(0.346 * s, 0.402 * s, 0.318 * s, 0.388 * s)
      ..close();
    canvas.drawPath(eye, Paint()..color = const Color(0xFF241A10));
    canvas.drawCircle(p(0.350, 0.377), 0.008 * s, Paint()..color = Colors.white70);

    // Nostril, following the muzzle's angle.
    canvas.drawArc(
      Rect.fromCircle(center: p(0.192, 0.532), radius: 0.017 * s),
      math.pi * 0.1,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 0.010 * s
        ..color = const Color(0xFF8A7455),
    );

    // Mouth line: a short soft stroke closing the muzzle.
    canvas.drawPath(
      Path()
        ..moveTo(0.168 * s, 0.560 * s)
        ..quadraticBezierTo(0.196 * s, 0.576 * s, 0.228 * s, 0.596 * s),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 0.008 * s
        ..color = _ivoryShade,
    );

    // Cheek shading: one soft crescent under the eye for volume.
    canvas.drawPath(
      Path()
        ..moveTo(0.330 * s, 0.545 * s)
        ..quadraticBezierTo(0.372 * s, 0.490 * s, 0.386 * s, 0.415 * s)
        ..quadraticBezierTo(0.352 * s, 0.480 * s, 0.312 * s, 0.522 * s)
        ..close(),
      Paint()..color = _ivoryShade.withValues(alpha: 0.85),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AppIconPainter old) => old.inset != inset;
}

Future<void> _render(WidgetTester tester, String path, int px, {double inset = 0}) async {
  tester.view.physicalSize = Size(px.toDouble(), px.toDouble());
  tester.view.devicePixelRatio = 1.0;
  await tester.pumpWidget(
    RepaintBoundary(
      child: CustomPaint(
        size: Size(px.toDouble(), px.toDouble()),
        painter: AppIconPainter(inset: inset),
      ),
    ),
  );
  await tester.pump();
  final boundary =
      find.byType(RepaintBoundary).evaluate().first.renderObject! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    File(path)
      ..parent.createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('render the launcher icon at every required size', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Review copy first — judge this one before shipping the rest.
    await _render(tester, 'build/screenshots/app_icon_1024.png', 1024);

    const android = {
      'mipmap-mdpi': 48,
      'mipmap-hdpi': 72,
      'mipmap-xhdpi': 96,
      'mipmap-xxhdpi': 144,
      'mipmap-xxxhdpi': 192,
    };
    for (final e in android.entries) {
      // Launchers mask Android icons freely, so keep a safe inset.
      await _render(
        tester,
        'android/app/src/main/res/${e.key}/ic_launcher.png',
        e.value,
        inset: 0.10,
      );
    }

    const ios = {
      'Icon-App-20x20@1x.png': 20,
      'Icon-App-20x20@2x.png': 40,
      'Icon-App-20x20@3x.png': 60,
      'Icon-App-29x29@1x.png': 29,
      'Icon-App-29x29@2x.png': 58,
      'Icon-App-29x29@3x.png': 87,
      'Icon-App-40x40@1x.png': 40,
      'Icon-App-40x40@2x.png': 80,
      'Icon-App-40x40@3x.png': 120,
      'Icon-App-60x60@2x.png': 120,
      'Icon-App-60x60@3x.png': 180,
      'Icon-App-76x76@1x.png': 76,
      'Icon-App-76x76@2x.png': 152,
      'Icon-App-83.5x83.5@2x.png': 167,
      'Icon-App-1024x1024@1x.png': 1024,
    };
    for (final e in ios.entries) {
      await _render(tester, 'ios/Runner/Assets.xcassets/AppIcon.appiconset/${e.key}', e.value);
    }

    await _render(tester, 'web/favicon.png', 32);
    await _render(tester, 'web/icons/Icon-192.png', 192);
    await _render(tester, 'web/icons/Icon-512.png', 512);
    await _render(tester, 'web/icons/Icon-maskable-192.png', 192, inset: 0.18);
    await _render(tester, 'web/icons/Icon-maskable-512.png', 512, inset: 0.18);

    expect(File('build/screenshots/app_icon_1024.png').existsSync(), isTrue);
  });
}
