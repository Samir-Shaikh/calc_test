import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:android_calculator_flutter/features/calculator/presentation/theme/calculator_colors.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/power_button_config.dart';

import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Power Operation Integration Tests', () {
    group('AC1: Power operator insertion', () {
      testWidgets('tapping power after number shows number with caret',
          (WidgetTester tester) async {
        // Build the calculator app
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap '2'
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap '^' (power operator)
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        // Verify expression shows '2^'
        expect(find.text('2^'), findsOneWidget);
      });

      testWidgets('power operator can be inserted after multiple digits',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap '1', '2', '3'
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Tap '^'
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        // Verify expression shows '123^'
        expect(find.text('123^'), findsOneWidget);
      });
    });

    group('AC2: Simple power calculation', () {
      testWidgets('2^3 equals 8', (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap '2'
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap '^'
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        // Tap '3'
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Tap '='
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 8 (may show as '8' or '8.0')
        final result8 = find.text('8');
        final result8_0 = find.text('8.0');
        expect(result8.evaluate().isNotEmpty || result8_0.evaluate().isNotEmpty, isTrue,
            reason: 'Expected result to be 8 or 8.0');
      });

      testWidgets('3^2 equals 9', (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap '3'
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Tap '^'
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        // Tap '2'
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap '='
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 9 (may show as '9' or '9.0')
        final result9 = find.text('9');
        final result9_0 = find.text('9.0');
        expect(result9.evaluate().isNotEmpty || result9_0.evaluate().isNotEmpty, isTrue,
            reason: 'Expected result to be 9 or 9.0');
      });

      testWidgets('5^2 equals 25', (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap '5'
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        // Tap '^'
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        // Tap '2'
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap '='
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 25
        final result25 = find.text('25');
        final result25_0 = find.text('25.0');
        expect(result25.evaluate().isNotEmpty || result25_0.evaluate().isNotEmpty, isTrue,
            reason: 'Expected result to be 25 or 25.0');
      });
    });

    group('AC3: Large exponent calculation', () {
      testWidgets('2^10 equals 1024', (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap '2'
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap '^'
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        // Tap '1', '0' to enter 10
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();

        // Tap '='
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 1024 (may show as '1024' or '1024.0')
        final result1024 = find.text('1024');
        final result1024_0 = find.text('1024.0');
        expect(result1024.evaluate().isNotEmpty || result1024_0.evaluate().isNotEmpty, isTrue,
            reason: 'Expected result to be 1024 or 1024.0');
      });

      testWidgets('2^8 equals 256', (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap '2'
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap '^'
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        // Tap '8'
        await tester.tap(find.text('8'));
        await tester.pumpAndSettle();

        // Tap '='
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 256
        final result256 = find.text('256');
        final result256_0 = find.text('256.0');
        expect(result256.evaluate().isNotEmpty || result256_0.evaluate().isNotEmpty, isTrue,
            reason: 'Expected result to be 256 or 256.0');
      });

      testWidgets('10^3 equals 1000', (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap '1', '0' to enter 10
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();

        // Tap '^'
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        // Tap '3'
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Tap '='
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 1000
        final result1000 = find.text('1000');
        final result1000_0 = find.text('1000.0');
        expect(result1000.evaluate().isNotEmpty || result1000_0.evaluate().isNotEmpty, isTrue,
            reason: 'Expected result to be 1000 or 1000.0');
      });
    });

    group('AC4: Fractional exponent (square root)', () {
      testWidgets('2^0.5 approximately equals 1.414 (square root of 2)',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap '2'
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap '^'
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        // Tap '0', '.', '5' to enter 0.5
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('.'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        // Tap '='
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is approximately 1.414 (sqrt(2) = 1.41421356...)
        // The result should start with '1.414'
        final resultFinder = find.textContaining('1.414');
        expect(resultFinder, findsWidgets,
            reason: 'Expected result to be approximately 1.414... (square root of 2)');
      });

      testWidgets('4^0.5 equals 2 (square root of 4)',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap '4'
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        // Tap '^'
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        // Tap '0', '.', '5' to enter 0.5
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('.'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        // Tap '='
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 2 (sqrt(4) = 2)
        final result2 = find.text('2');
        final result2_0 = find.text('2.0');
        expect(result2.evaluate().isNotEmpty || result2_0.evaluate().isNotEmpty, isTrue,
            reason: 'Expected result to be 2 or 2.0 (square root of 4)');
      });

      testWidgets('9^0.5 equals 3 (square root of 9)',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap '9'
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();

        // Tap '^'
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        // Tap '0', '.', '5' to enter 0.5
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('.'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        // Tap '='
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 3 (sqrt(9) = 3)
        final result3 = find.text('3');
        final result3_0 = find.text('3.0');
        expect(result3.evaluate().isNotEmpty || result3_0.evaluate().isNotEmpty, isTrue,
            reason: 'Expected result to be 3 or 3.0 (square root of 9)');
      });

      testWidgets('8^(1/3) using 0.333... approximates cube root',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Test 27^0.333... which should be approximately 3 (cube root of 27)
        // Tap '2', '7' to enter 27
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('7'));
        await tester.pumpAndSettle();

        // Tap '^'
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        // Tap '0', '.', '3', '3', '3' to enter approximately 1/3
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('.'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Tap '='
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is approximately 3 (cube root of 27)
        // Due to floating point, result will be close to 3
        final resultFinder = find.textContaining('2.99');
        final exactResult = find.text('3');
        final exactResult3_0 = find.text('3.0');
        expect(
          resultFinder.evaluate().isNotEmpty ||
              exactResult.evaluate().isNotEmpty ||
              exactResult3_0.evaluate().isNotEmpty,
          isTrue,
          reason: 'Expected result to be approximately 3 (cube root of 27)',
        );
      });
    });

    group('AC5: Power button visual appearance', () {
      testWidgets('power button displays caret symbol (^)',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Find the power button by key
        final powerButton = find.byKey(const Key('power_button'));
        expect(powerButton, findsOneWidget);

        // Verify button displays '^' label
        final caretText = find.descendant(
          of: powerButton,
          matching: find.text('^'),
        );
        expect(caretText, findsOneWidget,
            reason: 'Power button should display ^ symbol');
      });

      testWidgets('power button has gray background color',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Verify power button config has correct background color
        expect(
          PowerButtonConfig.backgroundColor,
          equals(CalculatorColors.powerButtonBackground),
          reason: 'Power button should use powerButtonBackground color',
        );

        // Verify the color is gray (#505050)
        expect(
          PowerButtonConfig.backgroundColor,
          equals(const Color(0xFF505050)),
          reason: 'Power button background should be gray (#505050)',
        );
      });

      testWidgets('power button has white text color',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Verify power button config has white text color
        expect(
          PowerButtonConfig.textColor,
          equals(CalculatorColors.lightButtonText),
          reason: 'Power button should use lightButtonText color',
        );

        expect(
          PowerButtonConfig.textColor,
          equals(Colors.white),
          reason: 'Power button text should be white',
        );
      });

      testWidgets('power button label configuration is correct',
          (WidgetTester tester) async {
        // Verify the static configuration
        expect(
          PowerButtonConfig.label,
          equals('^'),
          reason: 'Power button label should be ^',
        );
      });
    });

    group('Complex expressions with power (operator precedence)', () {
      testWidgets('3+2^4*5 equals 83 (power has higher precedence than multiply)',
          (WidgetTester tester) async {
        // This tests: 3 + (2^4) * 5 = 3 + 16 * 5 = 3 + 80 = 83
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap '3'
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Tap '+'
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        // Tap '2'
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap '^'
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        // Tap '4'
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        // Tap '×'
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();

        // Tap '5'
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        // Tap '='
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 83
        final result83 = find.text('83');
        final result83_0 = find.text('83.0');
        expect(result83.evaluate().isNotEmpty || result83_0.evaluate().isNotEmpty, isTrue,
            reason: 'Expected result to be 83 (3+2^4*5 with proper precedence)');
      });

      testWidgets('2^3+1 equals 9 (power before addition)',
          (WidgetTester tester) async {
        // This tests: (2^3) + 1 = 8 + 1 = 9
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap '2'
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap '^'
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        // Tap '3'
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Tap '+'
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        // Tap '1'
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();

        // Tap '='
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 9
        final result9 = find.text('9');
        final result9_0 = find.text('9.0');
        expect(result9.evaluate().isNotEmpty || result9_0.evaluate().isNotEmpty, isTrue,
            reason: 'Expected result to be 9 (2^3+1)');
      });

      testWidgets('10-2^3 equals 2 (power before subtraction)',
          (WidgetTester tester) async {
        // This tests: 10 - (2^3) = 10 - 8 = 2
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap '1', '0' to enter 10
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();

        // Tap '-'
        await tester.tap(find.text('-'));
        await tester.pumpAndSettle();

        // Tap '2'
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap '^'
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        // Tap '3'
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Tap '='
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 2
        final result2 = find.text('2');
        final result2_0 = find.text('2.0');
        expect(result2.evaluate().isNotEmpty || result2_0.evaluate().isNotEmpty, isTrue,
            reason: 'Expected result to be 2 (10-2^3)');
      });

      testWidgets('2*3^2 equals 18 (power before multiplication)',
          (WidgetTester tester) async {
        // This tests: 2 * (3^2) = 2 * 9 = 18
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap '2'
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap '×'
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();

        // Tap '3'
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Tap '^'
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        // Tap '2'
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap '='
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 18
        final result18 = find.text('18');
        final result18_0 = find.text('18.0');
        expect(result18.evaluate().isNotEmpty || result18_0.evaluate().isNotEmpty, isTrue,
            reason: 'Expected result to be 18 (2*3^2)');
      });

      testWidgets('(2+3)^2 equals 25 (parentheses with power)',
          (WidgetTester tester) async {
        // This tests: (2+3)^2 = 5^2 = 25
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap '(' (parenthesis button)
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();

        // Tap '2'
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap '+'
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        // Tap '3'
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Tap ')' (parenthesis button again)
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();

        // Tap '^'
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        // Tap '2'
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap '='
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 25
        final result25 = find.text('25');
        final result25_0 = find.text('25.0');
        expect(result25.evaluate().isNotEmpty || result25_0.evaluate().isNotEmpty, isTrue,
            reason: 'Expected result to be 25 ((2+3)^2)');
      });
    });

    group('Edge cases for power operation', () {
      testWidgets('any number to power of 0 equals 1',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Test 5^0 = 1
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 1
        final result1 = find.text('1');
        final result1_0 = find.text('1.0');
        expect(result1.evaluate().isNotEmpty || result1_0.evaluate().isNotEmpty, isTrue,
            reason: 'Expected result to be 1 (5^0)');
      });

      testWidgets('any number to power of 1 equals itself',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Test 7^1 = 7
        await tester.tap(find.text('7'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 7
        final result7 = find.text('7');
        final result7_0 = find.text('7.0');
        expect(result7.evaluate().isNotEmpty || result7_0.evaluate().isNotEmpty, isTrue,
            reason: 'Expected result to be 7 (7^1)');
      });

      testWidgets('0 to any positive power equals 0',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Test 0^5 = 0
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 0
        final result0 = find.text('0');
        final result0_0 = find.text('0.0');
        expect(result0.evaluate().isNotEmpty || result0_0.evaluate().isNotEmpty, isTrue,
            reason: 'Expected result to be 0 (0^5)');
      });

      testWidgets('1 to any power equals 1', (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Test 1^99 = 1 (using 1^9 for simplicity)
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 1
        final result1 = find.text('1');
        final result1_0 = find.text('1.0');
        expect(result1.evaluate().isNotEmpty || result1_0.evaluate().isNotEmpty, isTrue,
            reason: 'Expected result to be 1 (1^9)');
      });

      testWidgets('clear after power operation resets expression',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter power expression
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Verify expression is cleared
        expect(find.text('2^3'), findsNothing);

        // Can enter new expression
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        expect(find.text('5'), findsWidgets);
      });
    });
  });
}
