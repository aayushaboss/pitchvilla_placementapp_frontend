import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pitchvilla/main.dart';

void main() {
  testWidgets('App boots and renders the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PitchvillaApp());
    await tester.pump();

    expect(find.byKey(const ValueKey('splash-screen')), findsOneWidget);
    expect(find.text('jobsvilla'), findsOneWidget);

    // Flush the splash screen's pending delayed-navigation timers so the
    // test doesn't end with timers still scheduled.
    await tester.pump(const Duration(milliseconds: 2000));
  });
}
