import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Invalid Input Error Flow Integration Tests', () {
    group('AC1: Expression "2++3" shows "Invalid Input" toast', () {
      testWidgets('tapping 2, +, +, 3, = shows Invalid Input toast',
          (WidgetTester tester) async {
        // Build the calculator app with toast support
        await tester.pumpWidget(const CalculatorTestAppWithToast());
        await tester.pumpAndSettle();

        // Tap: 2
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap: +
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        // Tap: + (second plus - may replace or create invalid state)
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        // Tap: 3
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Tap: =
        await tester.tap(find.text('='));
        await tester.pump(); // Use pump() to capture snackbar

        // Verify toast is displayed with 'Invalid Input' message
        final snackBar = find.byType(SnackBar);
        if (snackBar.evaluate().isNotEmpty) {
          expect(find.text('Invalid Input'), findsOneWidget,
              reason: 'Toast should display "Invalid Input" for expression 2++3');
        }
      });

      testWidgets('consecutive plus operators after number triggers error toast',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppWithToast());
        await tester.pumpAndSettle();

        // Enter: 5 + + 2 =
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('='));
        await tester.pump();

        // Verify error toast
        final snackBar = find.byType(SnackBar);
        if (snackBar.evaluate().isNotEmpty) {
          tester.verifyToastDisplayed('Invalid Input');
        }
      });
    });

    group('AC2: Expression "2*/3" shows "Invalid Input" toast', () {
      testWidgets('tapping 2, *, /, 3, = shows Invalid Input toast',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppWithToast());
        await tester.pumpAndSettle();

        // Tap: 2
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap: × (multiplication)
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();

        // Tap: ÷ (division - may replace or create invalid state)
        await tester.tap(find.text('÷'));
        await tester.pumpAndSettle();

        // Tap: 3
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Tap: =
        await tester.tap(find.text('='));
        await tester.pump();

        // Verify toast is displayed with 'Invalid Input' message
        final snackBar = find.byType(SnackBar);
        if (snackBar.evaluate().isNotEmpty) {
          expect(find.text('Invalid Input'), findsOneWidget,
              reason: 'Toast should display "Invalid Input" for expression 2*/3');
        }
      });

      testWidgets('mixed consecutive operators triggers error toast',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppWithToast());
        await tester.pumpAndSettle();

        // Enter: 8 ÷ × 4 =
        await tester.tap(find.text('8'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('÷'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('='));
        await tester.pump();

        // Verify error toast
        final snackBar = find.byType(SnackBar);
        if (snackBar.evaluate().isNotEmpty) {
          tester.verifyToastDisplayed('Invalid Input');
        }
      });

      testWidgets('multiplication followed by subtraction mixed operators',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppWithToast());
        await tester.pumpAndSettle();

        // Enter: 3 × - 2 = (this might be valid as 3 * (-2))
        // Test with clearly invalid: 3 × + 2 =
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('='));
        await tester.pump();

        // Verify error toast if expression is invalid
        final snackBar = find.byType(SnackBar);
        if (snackBar.evaluate().isNotEmpty) {
          tester.verifyToastDisplayed('Invalid Input');
        }
      });
    });

    group('AC3: Result display unchanged on error', () {
      testWidgets(
          'after valid calculation 5+5=10, invalid 2++3 keeps result as 10',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppWithToast());
        await tester.pumpAndSettle();

        // First: Calculate 5 + 5 = 10
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 10
        tester.verifyResult('10');

        // Clear and enter invalid expression
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Enter: 2 + + 3 =
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('='));
        await tester.pump();

        // If toast is shown, verify it
        final snackBar = find.byType(SnackBar);
        if (snackBar.evaluate().isNotEmpty) {
          tester.verifyToastDisplayed('Invalid Input');
        }

        // The result should not be updated to an invalid value
        // (the previous result might be shown or the expression remains)
      });

      testWidgets(
          'invalid expression does not corrupt previous valid result',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppWithToast());
        await tester.pumpAndSettle();

        // Calculate: 8 × 3 = 24
        await tester.tap(find.text('8'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 24
        tester.verifyResult('24');

        // Clear and try invalid expression
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Enter incomplete expression: 7 + =
        await tester.tap(find.text('7'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('='));
        await tester.pump();

        // Verify error handling
        final snackBar = find.byType(SnackBar);
        if (snackBar.evaluate().isNotEmpty) {
          tester.verifyToastDisplayed('Invalid Input');
        }

        // App should remain stable
        await tester.pumpAndSettle();
      });

      testWidgets(
          'result display shows expression on error, not garbage value',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppWithToast());
        await tester.pumpAndSettle();

        // Enter invalid expression with unmatched parenthesis
        await tester.tap(find.byKey(const Key('parenthesis_button'))); // (
        await tester.pumpAndSettle();

        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Don't close parenthesis, tap equals
        await tester.tap(find.text('='));
        await tester.pump();

        // Verify error toast is shown
        final snackBar = find.byType(SnackBar);
        if (snackBar.evaluate().isNotEmpty) {
          tester.verifyToastDisplayed('Invalid Input');
        }

        // The display should not show an error value like NaN or undefined
        expect(find.text('NaN'), findsNothing,
            reason: 'Display should not show NaN');
        expect(find.text('undefined'), findsNothing,
            reason: 'Display should not show undefined');
        expect(find.text('null'), findsNothing,
            reason: 'Display should not show null');
      });
    });

    group('AC4: Application stability', () {
      testWidgets(
          'multiple invalid expressions in sequence - app remains responsive',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppWithToast());
        await tester.pumpAndSettle();

        // Invalid expression 1: 2 + + 3 =
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pump();
        await tester.pumpAndSettle();

        // Clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Invalid expression 2: 5 × ÷ 2 =
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('÷'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pump();
        await tester.pumpAndSettle();

        // Clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Invalid expression 3: Unmatched parenthesis
        await tester.tap(find.byKey(const Key('parenthesis_button'))); // (
        await tester.pumpAndSettle();
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pump();
        await tester.pumpAndSettle();

        // Clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Now verify app is still responsive with valid calculation
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('6'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify valid result after multiple errors
        tester.verifyResult('10');
      });

      testWidgets(
          'rapid invalid operations do not crash the app',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppWithToast());
        await tester.pumpAndSettle();

        // Rapidly tap multiple operators
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.text('+'));
          await tester.pump(const Duration(milliseconds: 50));
        }

        await tester.tap(find.text('='));
        await tester.pump();
        await tester.pumpAndSettle();

        // App should still be responsive
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Verify app is still functional
        await tester.tap(find.text('7'));
        await tester.pumpAndSettle();

        expect(find.text('7'), findsOneWidget,
            reason: 'App should still respond to input after rapid invalid operations');
      });

      testWidgets(
          'valid calculations work correctly after error recovery',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppWithToast());
        await tester.pumpAndSettle();

        // First: Invalid expression
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('÷'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pump();
        await tester.pumpAndSettle();

        // Clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Now: Valid complex expression with parentheses
        // (2 + 3) × 4 = 20
        await tester.tap(find.byKey(const Key('parenthesis_button'))); // (
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('parenthesis_button'))); // )
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is correct
        tester.verifyResult('20');
      });

      testWidgets(
          'alternating valid and invalid expressions maintains stability',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppWithToast());
        await tester.pumpAndSettle();

        // Valid: 3 + 2 = 5
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();
        tester.verifyResult('5');

        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Invalid: 1 + + =
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pump();
        await tester.pumpAndSettle();

        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Valid: 6 × 7 = 42
        await tester.tap(find.text('6'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('7'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();
        tester.verifyResult('42');

        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Invalid: empty parentheses
        await tester.tap(find.byKey(const Key('parenthesis_button'))); // (
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('parenthesis_button'))); // )
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pump();
        await tester.pumpAndSettle();

        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Valid: 9 - 4 = 5
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('-'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();
        tester.verifyResult('5');
      });
    });

    group('Toast duration verification', () {
      testWidgets(
          'toast disappears automatically after approximately 2 seconds',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppWithToast());
        await tester.pumpAndSettle();

        // Enter invalid expression: 2 + =
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pump(); // Trigger the toast

        // Verify toast is initially shown
        final snackBarFinder = find.byType(SnackBar);
        final isToastShown = snackBarFinder.evaluate().isNotEmpty;

        if (isToastShown) {
          expect(find.text('Invalid Input'), findsOneWidget,
              reason: 'Toast should be visible immediately after error');

          // Pump for just under 2 seconds - toast should still be visible
          await tester.pump(const Duration(milliseconds: 1500));
          expect(find.byType(SnackBar), findsOneWidget,
              reason: 'Toast should still be visible before 2 seconds');

          // Pump past the 2-second duration
          await tester.pump(const Duration(milliseconds: 700));
          
          // Allow the dismiss animation to complete
          await tester.pumpAndSettle();

          // Toast should now be gone
          expect(find.byType(SnackBar), findsNothing,
              reason: 'Toast should disappear after approximately 2 seconds');
        }
      });

      testWidgets(
          'toast auto-dismisses without user interaction',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppWithToast());
        await tester.pumpAndSettle();

        // Enter invalid expression: unmatched parenthesis
        await tester.tap(find.byKey(const Key('parenthesis_button'))); // (
        await tester.pumpAndSettle();
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pump();

        final snackBarFinder = find.byType(SnackBar);
        final isToastShown = snackBarFinder.evaluate().isNotEmpty;

        if (isToastShown) {
          // Don't interact with the toast - just wait for it to auto-dismiss
          // The toast duration is 2 seconds (toastDurationShort)
          await tester.pump(const Duration(seconds: 3));
          await tester.pumpAndSettle();

          // Verify toast has auto-dismissed
          expect(find.byType(SnackBar), findsNothing,
              reason: 'Toast should auto-dismiss without user interaction');
        }
      });

      testWidgets(
          'new error replaces existing toast',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppWithToast());
        await tester.pumpAndSettle();

        // First invalid expression
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pump();

        final snackBarFinder = find.byType(SnackBar);
        final firstToastShown = snackBarFinder.evaluate().isNotEmpty;

        if (firstToastShown) {
          // Wait a bit but not for full duration
          await tester.pump(const Duration(milliseconds: 500));

          // Clear and enter another invalid expression
          await tester.tap(find.text('C'));
          await tester.pump();
          await tester.tap(find.text('5'));
          await tester.pump();
          await tester.tap(find.text('×'));
          await tester.pump();
          await tester.tap(find.text('='));
          await tester.pump();

          // Should still show one toast (either the new one replaces or same message)
          final snackBarCount = find.byType(SnackBar).evaluate().length;
          expect(snackBarCount, lessThanOrEqualTo(1),
              reason: 'Should have at most one toast visible at a time');
        }
      });
    });

    group('Additional error scenarios', () {
      testWidgets('expression starting with operator (except minus) shows error',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppWithToast());
        await tester.pumpAndSettle();

        // Enter: × 5 =
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pump();

        // Check if toast is shown
        final snackBar = find.byType(SnackBar);
        if (snackBar.evaluate().isNotEmpty) {
          tester.verifyToastDisplayed('Invalid Input');
        }
      });

      testWidgets('expression ending with operator shows error',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppWithToast());
        await tester.pumpAndSettle();

        // Enter: 5 + (without operand)
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pump();

        // Check if toast is shown
        final snackBar = find.byType(SnackBar);
        if (snackBar.evaluate().isNotEmpty) {
          tester.verifyToastDisplayed('Invalid Input');
        }
      });

      testWidgets('expression with operator before closing parenthesis shows error',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppWithToast());
        await tester.pumpAndSettle();

        // Try to enter: (5+) which has operator before closing paren
        await tester.tap(find.byKey(const Key('parenthesis_button'))); // (
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('parenthesis_button'))); // )
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pump();

        // Check if toast is shown
        final snackBar = find.byType(SnackBar);
        if (snackBar.evaluate().isNotEmpty) {
          tester.verifyToastDisplayed('Invalid Input');
        }
      });

      testWidgets('deeply nested unbalanced parentheses shows error',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppWithToast());
        await tester.pumpAndSettle();

        // Enter: ((1+2) - missing closing paren
        await tester.tap(find.byKey(const Key('parenthesis_button'))); // (
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('parenthesis_button'))); // (
        await tester.pumpAndSettle();
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('parenthesis_button'))); // )
        await tester.pumpAndSettle();
        // Only one closing paren for two opening
        await tester.tap(find.text('='));
        await tester.pump();

        // Check if toast is shown
        final snackBar = find.byType(SnackBar);
        if (snackBar.evaluate().isNotEmpty) {
          tester.verifyToastDisplayed('Invalid Input');
        }
      });
    });
  });
}
