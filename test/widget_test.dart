// MindHearth widget tests
//
// This file contains widget tests for the MindHearth application.
// These tests verify that UI components render correctly and respond to user interactions.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:mindhearth/core/widgets/app_button.dart';

void main() {
  group('MindHearth Widget Tests', () {
    testWidgets('AppButton should render correctly', (WidgetTester tester) async {
      // Build a simple button widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Verify that the button renders
      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
    });

    testWidgets('AppButton should be tappable', (WidgetTester tester) async {
      var buttonPressed = false;

      // Build a button with onPressed callback
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Tap Me',
              onPressed: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      // Tap the button
      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      // Verify the callback was called
      expect(buttonPressed, true);
    });

    testWidgets('AppButton should show loading state', (WidgetTester tester) async {
      // Build a button in loading state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Loading',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AppButton should be disabled when onPressed is null', (WidgetTester tester) async {
      // Build a disabled button (onPressed is null)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Disabled',
              onPressed: null, // This makes the button disabled
            ),
          ),
        ),
      );

      // Verify the button is disabled (should not be tappable)
      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
      
      // The button should be disabled (onPressed is null)
      final elevatedButton = tester.widget<ElevatedButton>(button);
      expect(elevatedButton.onPressed, isNull);
    });
  });
}
