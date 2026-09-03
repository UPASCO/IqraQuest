// A phone layout dropped onto an iPad does not overflow — it strands.
// The composition huddles under the status bar with half the screen
// empty, a card stretches to eleven hundred points around a 76-point
// thumbnail, and a line of text runs well past the eye's measure.
//
// These hold the two rules that turn the same layout into a tablet one:
// the content keeps a measure, and it is centred rather than stacked
// from the top. Nothing here may change on a phone, which is narrower
// than the cap — so every case also checks the phone is untouched.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/widgets/content_width.dart';
import 'package:iqraquest/widgets/fit_or_scroll.dart';

const _phone = Size(390, 844);
const _tabletPortrait = Size(834, 1194);
const _tabletLandscape = Size(1194, 834);

Future<EdgeInsets> _paddingAt(WidgetTester tester, Size size) async {
  late EdgeInsets result;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size),
      child: Builder(
        builder: (context) {
          result = pagePadding(context, horizontal: 20, top: 8, bottom: 8);
          return const SizedBox();
        },
      ),
    ),
  );
  return result;
}

void main() {
  testWidgets('a phone keeps the margins it was designed with', (tester) async {
    final padding = await _paddingAt(tester, _phone);
    expect(padding.left, 20);
    expect(padding.right, 20);
    expect(padding.top, 8);
  });

  testWidgets('a tablet grows its margins to hold the measure', (tester) async {
    for (final size in [_tabletPortrait, _tabletLandscape]) {
      final padding = await _paddingAt(tester, size);
      final content = size.width - padding.horizontal;
      expect(
        content,
        closeTo(kMaxContentWidth, 0.5),
        reason: 'content runs to $content points on a ${size.width}-point screen',
      );
      expect(
        padding.left,
        padding.right,
        reason: 'the content is off-centre on ${size.width}',
      );
    }
  });

  testWidgets('a zero-width frame during layout does not throw', (tester) async {
    // It happens for a frame; clamp() would have thrown on it.
    final padding = await _paddingAt(tester, Size.zero);
    expect(padding.left, 20);
  });

  testWidgets('FitOrScroll holds its child to the measure on a tablet', (
    tester,
  ) async {
    for (final (size, expected) in [
      (_phone, 390.0 - 40),
      (_tabletPortrait, kMaxContentWidth),
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FitOrScroll(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(key: const Key('band'), height: 40, color: Colors.red),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        tester.getSize(find.byKey(const Key('band'))).width,
        closeTo(expected, 0.5),
        reason: 'stretched wrong on ${size.width}',
      );
    }
  });

  testWidgets('a bottom bar wrapped in ContentWidth stays as tall as its child', (
    tester,
  ) async {
    // The first version used Center, which grows to fill loose height:
    // a bottom bar then ate the whole screen and the page above it built
    // nothing at all.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: ContentWidth(
            child: SizedBox(key: const Key('cta'), height: 56, child: Container()),
          ),
        ),
      ),
    );
    await tester.pump();
    final bar = tester.getSize(find.byType(ContentWidth));
    expect(bar.height, 56, reason: 'the bar grew past its child');
  });
}
