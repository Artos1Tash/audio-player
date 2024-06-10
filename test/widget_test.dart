import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audio/main.dart';

void main() {
  testWidgets('Audio Player smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app bar title is 'Audio Player'.
    expect(find.text('Audio Player'), findsOneWidget);

    // Verify that the initial play icon is displayed.
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    // Tap the play icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    // Verify that the pause icon is displayed after tapping the play icon.
    expect(find.byIcon(Icons.pause), findsOneWidget);

    // Check for the presence of the slider.
    expect(find.byType(Slider), findsOneWidget);

    // Check for the presence of the duration texts.
    expect(find.text('00:00'), findsNWidgets(2)); // Initially both position and duration are zero
  });
}
