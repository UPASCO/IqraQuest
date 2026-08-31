@Tags(['manual'])
library;

// Manual visual-QA helper, not part of CI (spec §97). Renders the horse
// and the rest of the hand-painted visual system in isolation so the art
// can be reviewed as PNGs under build/screenshots/. Software
// rasterization makes it slow, so it is tagged `manual` and excluded
// from the default suite.
//
// Run it deliberately with:
//   flutter test --tags=manual test/manual_screenshot_test.dart
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

Future<void> _scene(WidgetTester tester, String name, Size size, Widget child) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  await tester.pumpWidget(
    RepaintBoundary(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(backgroundColor: const Color(0xFFF3EAD6), body: child),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
  await _capture(tester, name);
}

Widget _horse({
  required HorseCoat coat,
  required AppTeam team,
  required HorsePose pose,
  required double size,
  bool saddle = true,
  Color? color,
}) => SizedBox(
  width: size,
  height: size,
  child: CustomPaint(
    painter: HorsePainter(coat: coat, team: team, pose: pose, showSaddle: saddle, colors: color),
  ),
);

const _teamColors = <AppTeam, Color>{
  AppTeam.emerald: Color(0xFF0E6B52),
  AppTeam.saphir: Color(0xFF2A5C8A),
  AppTeam.grenat: Color(0xFFA83B3B),
  AppTeam.safran: Color(0xFFC89B45),
};

void main() {
  testWidgets('horse gallery — 4 coats x 4 poses', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const poses = HorsePose.values;
    final teams = AppTeam.values;

    await _scene(
      tester,
      'horse_gallery',
      const Size(1040, 1080),
      Column(
        children: [
          for (var r = 0; r < teams.length; r++)
            Expanded(
              child: Row(
                children: [
                  for (final pose in poses)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: _horse(
                            coat: teams[r].coat,
                            team: teams[r],
                            pose: pose,
                            size: 230,
                            color: _teamColors[teams[r]],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  });

  testWidgets('horse hero — large close-up', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _scene(
      tester,
      'horse_hero',
      const Size(900, 480),
      Row(
        children: [
          Expanded(
            child: Container(
              color: const Color(0xFFFFF9ED),
              child: Center(
                child: _horse(
                  coat: HorseCoat.chestnut,
                  team: AppTeam.grenat,
                  pose: HorsePose.standing,
                  size: 440,
                  color: const Color(0xFFA83B3B),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFF0D1A29),
              child: Center(
                child: _horse(
                  coat: HorseCoat.grayWhite,
                  team: AppTeam.emerald,
                  pose: HorsePose.rearingProud,
                  size: 440,
                  saddle: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });

  testWidgets('horse small sizes — board pawn legibility', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _scene(
      tester,
      'horse_small',
      const Size(1000, 260),
      Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final s in [24.0, 32.0, 48.0, 72.0, 110.0, 160.0])
              for (final team in [AppTeam.emerald, AppTeam.saphir])
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: _horse(
                    coat: team.coat,
                    team: team,
                    pose: HorsePose.standing,
                    size: s,
                    color: _teamColors[team],
                  ),
                ),
          ],
        ),
      ),
    );
  });
}
