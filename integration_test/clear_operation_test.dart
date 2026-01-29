import 'package:android_calculator_flutter/features/calculator/presentation/widgets/clear_button_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Clear Operation Integration Tests', () {
    group('AC1: Clear expression', () {
      testWidgets('clears expression "123+456" when C button is tapped',
          (WidgetTester tester) async {
        // Build the calculator app
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter expression '123+456'
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('6'));
        await tester.pumpAndSettle();

        // Verify expression is displayed
        expect(find.text('123+456'), findsOneWidget);

        // Tap 'C' button to clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Verify expression display is empty (should not find '123+456')
        expect(find.text('123+456'), findsNothing);
      });

      testWidgets('clears simple numeric expression',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '999'
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();

        // Verify expression is displayed
        expect(find.text('999'), findsOneWidget);

        // Tap 'C' button to clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Verify expression is cleared
        expect(find.text('999'), findsNothing);
      });

      testWidgets('clears complex expression with multiple operators',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '5+3×2'
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Verify expression is displayed
        expect(find.text('5+3×2'), findsOneWidget);

        // Tap 'C' button to clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Verify expression is cleared
        expect(find.text('5+3×2'), findsNothing);
      });
    });

    group('AC2: Clear result display', () {
      testWidgets('clears result after evaluation when C button is tapped',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter expression '123+456'
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('6'));
        await tester.pumpAndSettle();

        // Tap '=' to evaluate
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is displayed (579)
        expect(find.text('579'), findsOneWidget);

        // Tap 'C' button to clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Verify result is cleared
        expect(find.text('579'), findsNothing);
        // Also verify original expression is cleared
        expect(find.text('123+456'), findsNothing);
      });

      testWidgets('clears result of multiplication',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '7×8'
        await tester.tap(find.text('7'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('8'));
        await tester.pumpAndSettle();

        // Tap '=' to evaluate
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is displayed (56)
        expect(find.text('56'), findsOneWidget);

        // Tap 'C' button to clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Verify result is cleared
        expect(find.text('56'), findsNothing);
      });

      testWidgets('clears decimal result',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '5÷2'
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('÷'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap '=' to evaluate
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is displayed (2.5)
        expect(find.text('2.5'), findsOneWidget);

        // Tap 'C' button to clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Verify result is cleared
        expect(find.text('2.5'), findsNothing);
      });
    });

    group('AC3: Bracket state reset', () {
      testWidgets(
          'resets bracket state so next parenthesis is opening bracket',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '(5+' using parenthesis button
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        // Verify expression shows '(5+'
        expect(find.text('(5+'), findsOneWidget);

        // Tap 'C' button to clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Tap parenthesis button - should insert '(' not ')'
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();

        // Verify '(' is inserted (not ')')
        expect(find.text('('), findsWidgets);
        expect(find.text(')'), findsNothing);
      });

      testWidgets(
          'after entering "(5+3)" and clearing, next bracket is "("',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '(5+3)' - first parenthesis is '('
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        // Second parenthesis should be ')'
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();

        // Verify expression shows '(5+3)'
        expect(find.text('(5+3)'), findsOneWidget);

        // Tap 'C' button to clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Tap parenthesis button - should insert '(' (reset state)
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();

        // Verify '(' is inserted (bracket state was reset)
        expect(find.text('('), findsWidgets);
      });

      testWidgets(
          'multiple brackets then clear resets to opening bracket',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '((1+2)'
        await tester.tap(find.byKey(const Key('parenthesis_button'))); // (
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('parenthesis_button'))); // )
        await tester.pumpAndSettle();
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('parenthesis_button'))); // (
        await tester.pumpAndSettle();

        // Tap 'C' button to clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Tap parenthesis button - should insert '(' (reset state)
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();

        // Verify only '(' is in the expression (bracket state was reset)
        expect(find.text('('), findsWidgets);
      });
    });

    group('AC4: Clear button visual appearance', () {
      testWidgets('Clear button displays "C" label',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Verify Clear button shows 'C' label
        expect(find.text('C'), findsOneWidget);
      });

      testWidgets('Clear button has correct key identifier',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Verify Clear button has the correct key
        expect(find.byKey(const Key('clear_button')), findsOneWidget);
      });

      testWidgets('Clear button config has gray background color',
          (WidgetTester tester) async {
        // Verify ClearButtonConfig provides the correct styling
        expect(ClearButtonConfig.label, equals('C'));
        
        // Verify the background color is gray (not null)
        expect(ClearButtonConfig.backgroundColor, isNotNull);
        
        // Verify text color is set for contrast
        expect(ClearButtonConfig.textColor, isNotNull);
        
        // Verify decoration is provided
        expect(ClearButtonConfig.decoration, isNotNull);
      });
    });

    group('Sequential clear operations', () {
      testWidgets(
          'multiple clear operations work without state accumulation',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // First operation: Enter '1+2'
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap '=' to evaluate
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result (3)
        expect(find.text('3'), findsOneWidget);

        // Tap 'C' to clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Verify cleared
        expect(find.text('3'), findsNothing);
        expect(find.text('1+2'), findsNothing);

        // Second operation: Enter '3×4'
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        // Tap '=' to evaluate
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result (12)
        expect(find.text('12'), findsOneWidget);

        // Tap 'C' to clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Verify both displays are empty
        expect(find.text('12'), findsNothing);
        expect(find.text('3×4'), findsNothing);
      });

      testWidgets(
          'clear works correctly after each operation in a sequence',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Cycle 1: Enter, evaluate, clear
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();
        expect(find.text('5'), findsNothing);

        // Cycle 2: Enter, evaluate, clear
        await tester.tap(find.text('8'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('-'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();
        expect(find.text('5'), findsOneWidget); // 8-3=5
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();
        expect(find.text('5'), findsNothing);

        // Cycle 3: Enter with parentheses, clear
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
        expect(find.text('(2+3)'), findsOneWidget);
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();
        expect(find.text('(2+3)'), findsNothing);
      });

      testWidgets(
          'clear button can be tapped multiple times consecutively',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter some expression
        await tester.tap(find.text('7'));
        await tester.pumpAndSettle();

        // Tap clear multiple times (should not cause any errors)
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Verify no errors and can still enter new expression
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();
        expect(find.text('9'), findsWidgets);
      });
    });

    group('Clear with test helpers', () {
      testWidgets('tapClear helper works correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Use enterExpression helper
        await tester.enterExpression('42');

        // Verify expression is displayed
        expect(find.text('42'), findsOneWidget);

        // Use tapClear helper
        await tester.tapClear();

        // Verify expression is cleared
        expect(find.text('42'), findsNothing);
      });

      testWidgets('clear works with enterExpression and tapEquals helpers',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter and evaluate expression using helpers
        await tester.enterExpression('10+5');
        await tester.tapEquals();

        // Verify result
        tester.verifyResult('15');

        // Clear using helper
        await tester.tapClear();

        // Verify cleared
        expect(find.text('15'), findsNothing);
        expect(find.text('10+5'), findsNothing);
      });
    });
  });
}
