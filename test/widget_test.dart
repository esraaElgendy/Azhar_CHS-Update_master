// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graduation_project/core/utils/app_preferences.dart';
import 'package:graduation_project/main.dart';

void main() {
  testWidgets('App start smoke test', (WidgetTester tester) async {
    final appPreferences = AppPreferences();
    // In a real test environment, you'd mock SharedPreferences here
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(appPreferences: appPreferences));
    
    // Wait for animations (Splash)
    await tester.pump(const Duration(seconds: 4));

    // Verify basic element existence (Splash or Login)
    // Note: Due to localization injection and async logic, 
    // basic pumpWidget might need Mocking. 
    // We will just verify it builds without crashing for now.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
