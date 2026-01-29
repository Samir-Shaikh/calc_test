import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/test_app.dart';

/// Integration tests for Order of Operations user flow.
///
/// These tests verify the complete flow from button taps to result display
/// with correct order of operations (operator precedence).
///
/// Acceptance Criteria:
/// - AC1: 2+3*4 should equal 14 (multiplication before addition)
/// - AC2: 10-4/2 should equal 8 (division before subtraction)
/// - AC3: (2+3)*4 should equal 20 (parentheses priority)
/// - AC4: 2^3+1 should equal 9 (exponent before addition)
/// - Additional: Left-to-right evaluation for same precedence operators
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Order of Operations Integration Tests', () {
    group('AC1: Multiplication before Addition (2+3*4=14)', () {
      testWidgets('2+3*4 should equal 14.0 (multiplication before addition)',
          (WidgetTester tester) async {
        // Build the calculator app
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter expression: 2 + 3 * 4
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        // Verify expression is displayed correctly
        expect(find.text('2+3×4'), findsOneWidget);

        // Tap equals
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 14 (multiplication has higher precedence)
        // Result should be 2 + (3 * 4) = 2 + 12 = 14
        tester.verifyResult('14');
      });

      testWidgets('verifies multiplication is evaluated before addition in 2+3*4',
          (WidgetTester tester) async {
        // This test verifies the same AC1 but with explicit step-by-step verification
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap 2
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        expect(find.text('2'), findsWidgets);

        // Tap +
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        expect(find.text('2+'), findsOneWidget);

        // Tap 3
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        expect(find.text('2+3'), findsOneWidget);

        // Tap ×
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        expect(find.text('2+3×'), findsOneWidget);

        // Tap 4
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();
        expect(find.text('2+3×4'), findsOneWidget);

        // Tap =
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result shows 14 (not 20 if left-to-right was used)
        tester.verifyResult('14');
      });
    });

    group('AC2: Division before Subtraction (10-4/2=8)', () {
      testWidgets('10-4/2 should equal 8.0 (division before subtraction)',
          (WidgetTester tester) async {
        // Build the calculator app
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter expression: 10 - 4 / 2
        // Tap 1
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();

        // Tap 0
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();

        // Tap -
        await tester.tap(find.text('-'));
        await tester.pumpAndSettle();

        // Tap 4
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        // Tap ÷
        await tester.tap(find.text('÷'));
        await tester.pumpAndSettle();

        // Tap 2
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Verify expression is displayed correctly
        expect(find.text('10-4÷2'), findsOneWidget);

        // Tap =
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 8 (division has higher precedence)
        // Result should be 10 - (4 / 2) = 10 - 2 = 8
        tester.verifyResult('8');
      });

      testWidgets('verifies division is evaluated before subtraction in 10-4/2',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Build expression step by step
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();
        expect(find.text('10'), findsOneWidget);

        await tester.tap(find.text('-'));
        await tester.pumpAndSettle();
        expect(find.text('10-'), findsOneWidget);

        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();
        expect(find.text('10-4'), findsOneWidget);

        await tester.tap(find.text('÷'));
        await tester.pumpAndSettle();
        expect(find.text('10-4÷'), findsOneWidget);

        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        expect(find.text('10-4÷2'), findsOneWidget);

        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result shows 8 (not 3 if left-to-right was used)
        tester.verifyResult('8');
      });
    });

    group('AC3: Parentheses Priority ((2+3)*4=20)', () {
      testWidgets('(2+3)*4 should equal 20.0 (parentheses priority)',
          (WidgetTester tester) async {
        // Build the calculator app
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter expression: ( 2 + 3 ) * 4
        // Tap (
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();

        // Tap 2
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap +
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        // Tap 3
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Tap ) (second tap on parenthesis button toggles to closing)
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();

        // Tap ×
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();

        // Tap 4
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        // Verify expression is displayed correctly
        expect(find.text('(2+3)×4'), findsOneWidget);

        // Tap =
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 20 (parentheses have highest priority)
        // Result should be (2 + 3) * 4 = 5 * 4 = 20
        tester.verifyResult('20');
      });

      testWidgets('verifies parentheses override normal precedence in (2+3)*4',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // First calculate without parentheses: 2+3*4 = 14
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Result without parentheses should be 14
        tester.verifyResult('14');

        // Clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Now calculate with parentheses: (2+3)*4 = 20
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Result with parentheses should be 20
        tester.verifyResult('20');
      });
    });

    group('AC4: Exponent before Addition (2^3+1=9)', () {
      testWidgets('2^3+1 should equal 9.0 (exponent before addition)',
          (WidgetTester tester) async {
        // Build the calculator app
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter expression: 2 ^ 3 + 1
        // Tap 2
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap ^
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        // Tap 3
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Tap +
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        // Tap 1
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();

        // Verify expression is displayed correctly
        expect(find.text('2^3+1'), findsOneWidget);

        // Tap =
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 9 (exponentiation has higher precedence than addition)
        // Result should be (2 ^ 3) + 1 = 8 + 1 = 9
        tester.verifyResult('9');
      });

      testWidgets('verifies exponentiation is evaluated before addition in 2^3+1',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Build expression step by step
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        expect(find.text('2'), findsWidgets);

        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();
        expect(find.text('2^'), findsOneWidget);

        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        expect(find.text('2^3'), findsOneWidget);

        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        expect(find.text('2^3+'), findsOneWidget);

        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        expect(find.text('2^3+1'), findsOneWidget);

        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result shows 9
        tester.verifyResult('9');
      });
    });

    group('Left-to-Right Evaluation for Same Precedence', () {
      testWidgets('6-3-1 should equal 2 (left-to-right for subtraction)',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter expression: 6 - 3 - 1
        await tester.tap(find.text('6'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('-'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('-'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();

        // Tap =
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 2 (left-to-right: (6-3)-1 = 3-1 = 2)
        tester.verifyResult('2');
      });

      testWidgets('12/3/2 should equal 2 (left-to-right for division)',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter expression: 12 / 3 / 2
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('÷'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('÷'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap =
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 2 (left-to-right: (12/3)/2 = 4/2 = 2)
        tester.verifyResult('2');
      });

      testWidgets('2*3*4 should equal 24 (left-to-right for multiplication)',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter expression: 2 * 3 * 4
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        // Tap =
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 24 (left-to-right: (2*3)*4 = 6*4 = 24)
        tester.verifyResult('24');
      });

      testWidgets('1+2+3+4 should equal 10 (left-to-right for addition)',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter expression: 1 + 2 + 3 + 4
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        // Tap =
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 10
        tester.verifyResult('10');
      });
    });

    group('Complex Expressions with Multiple Precedence Levels', () {
      testWidgets('2+3*4-5 should equal 9 (mixed + and * with precedence)',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter expression: 2 + 3 * 4 - 5
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('-'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Result: 2 + (3*4) - 5 = 2 + 12 - 5 = 9
        tester.verifyResult('9');
      });

      testWidgets('2^3*2 should equal 16 (exponent then multiplication)',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter expression: 2 ^ 3 * 2
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Result: (2^3) * 2 = 8 * 2 = 16
        tester.verifyResult('16');
      });

      testWidgets('(2+3)^2 should equal 25 (parentheses with power)',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter expression: ( 2 + 3 ) ^ 2
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Result: (2+3)^2 = 5^2 = 25
        tester.verifyResult('25');
      });

      testWidgets('10-4/2+3*2 should equal 14 (mixed operators)',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter expression: 10 - 4 / 2 + 3 * 2
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('-'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('÷'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Result: 10 - (4/2) + (3*2) = 10 - 2 + 6 = 14
        tester.verifyResult('14');
      });
    });

    group('User Flow Verification', () {
      testWidgets('complete user flow: multiple calculations with clear between',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // First calculation: AC1 - 2+3*4 = 14
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();
        tester.verifyResult('14');

        // Clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Second calculation: AC2 - 10-4/2 = 8
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('-'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('÷'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();
        tester.verifyResult('8');

        // Clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Third calculation: AC3 - (2+3)*4 = 20
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();
        tester.verifyResult('20');

        // Clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Fourth calculation: AC4 - 2^3+1 = 9
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();
        tester.verifyResult('9');
      });

      testWidgets('user can see expression while typing before evaluation',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Type expression and verify it's displayed at each step
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        expect(find.text('2'), findsWidgets);

        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        expect(find.text('2+'), findsOneWidget);

        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        expect(find.text('2+3'), findsOneWidget);

        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        expect(find.text('2+3×'), findsOneWidget);

        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();
        expect(find.text('2+3×4'), findsOneWidget);

        // Evaluate
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Result is displayed
        tester.verifyResult('14');
      });
    });
  });
}
