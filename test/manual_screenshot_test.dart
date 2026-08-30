// Manual visual-QA helper, not part of CI (spec §97). Renders the horse
// token in isolation (no app/router/riverpod overhead, so this runs fast)
// at large size for design review, in every coat, standing and rearing.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/theme/app_team.dart';
import 'package:iqraquest/widgets/horse_painter.dart';

Future<void> _capture(WidgetTester tester, String name) async {
  final element = find.byType(RepaintBoundary).evaluate().first;
  final boundary = element.renderObject! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 1);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final dir = Directory('build/screenshots')..createSync(recursive: true);
  File('${dir.path}/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  testWidgets('horse gallery', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final coats = HorseCoat.values;
    final poses = [HorsePose.standing, HorsePose.rearingProud, HorsePose.gallop];

    await tester.pumpWidget(
      RepaintBoundary(
        child: MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFFEFE6D2),
            body: Center(
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  for (final coat in coats)
                    for (final pose in poses)
                      Container(
                        width: 380,
                        height: 320,
                        color: Colors.white,
                        child: Center(
                          child: SizedBox(
                            width: 320,
                            height: 320 * (HorsePainter.boxH / HorsePainter.boxW),
                            child: CustomPaint(
                              painter: HorsePainter(
                                coat: coat,
                                team: AppTeam.emerald,
                                pose: pose,
                                colors: const Color(0xFF0E6B52),
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await _capture(tester, 'horse_gallery');
  });
}
