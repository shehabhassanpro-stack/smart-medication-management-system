import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_care_app/main.dart';

void main() {
  testWidgets('Medical Care App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that app launches successfully
    expect(find.byType(MaterialApp), findsOneWidget);

    // Can add more tests here later
  });
}