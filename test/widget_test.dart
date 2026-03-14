import 'package:flutter_test/flutter_test.dart';
import 'package:conference_app/main.dart';

void main() {
  testWidgets('Dashboard smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: This test might fail if Firebase isn't mocked, 
    // but we'll update the reference to the new App class name.
    await tester.pumpWidget(const ICSmartConferenceApp());

    // Verify that dashboard title exists
    expect(find.text('IC-SMART 2026'), findsWidgets);
  });
}
