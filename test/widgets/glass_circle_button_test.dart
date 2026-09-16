import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/widgets/glass_circle_button.dart';
import 'package:iqraquest/widgets/premium_lock.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );

  testWidgets('the tap area is the platform minimum, whatever the disc', (
    tester,
  ) async {
    var taps = 0;
    await pump(
      tester,
      GlassCircleButton(icon: Icons.menu, label: 'Menu', onTap: () => taps++),
    );
    final size = tester.getSize(find.byType(GlassCircleButton));
    // The design system's minimum is 48 (Apple asks 44, Material 48):
    // the disc may be drawn smaller, the target may not.
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
    expect(GlassCircleButton.discSize, lessThanOrEqualTo(size.width));

    // A tap on the rim of the target, outside the drawn disc, counts.
    final rect = tester.getRect(find.byType(GlassCircleButton));
    await tester.tapAt(rect.topLeft + const Offset(2, 2));
    expect(taps, 1);
  });

  testWidgets('a screen reader hears what it does, not the glyph', (
    tester,
  ) async {
    await pump(
      tester,
      GlassCircleButton(icon: Icons.menu, label: 'Open the menu', onTap: () {}),
    );
    final semantics = tester.getSemantics(find.byType(GlassCircleButton));
    expect(semantics.label, 'Open the menu');
    expect(semantics.flagsCollection.isButton, isTrue);
  });

  testWidgets('locked, it wears the gold lock and still answers the tap', (
    tester,
  ) async {
    var taps = 0;
    await pump(
      tester,
      GlassCircleButton(
        icon: Icons.bookmark_add_outlined,
        label: 'Save, Premium',
        locked: true,
        onTap: () => taps++,
      ),
    );
    expect(find.byType(LockBadge), findsOneWidget);
    await tester.tap(find.byType(GlassCircleButton));
    expect(taps, 1);
  });
}
