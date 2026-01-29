import 'package:android_calculator_flutter/features/calculator/presentation/widgets/backspace_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Button Grid Layout Integration Tests', () {
    group('Standard Calculator Input Sequence', () {
      testWidgets('7+8= calculation produces correct result',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap 7 button
        await tester.tap(find.text('7'));
        await tester.pumpAndSettle();

        // Tap + button
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        // Tap 8 button
        await tester.tap(find.text('8'));
        await tester.pumpAndSettle();

        // Verify expression is displayed
        expect(find.text('7+8'), findsOneWidget);

        // Tap = button
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 15
        tester.verifyResult('15');
      });

      testWidgets('9×6= calculation produces correct result',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap 9 button
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();

        // Tap × button
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();

        // Tap 6 button
        await tester.tap(find.text('6'));
        await tester.pumpAndSettle();

        // Verify expression is displayed
        expect(find.text('9×6'), findsOneWidget);

        // Tap = button
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 54
        tester.verifyResult('54');
      });

      testWidgets('45-12= calculation produces correct result',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap 4 button
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        // Tap 5 button
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        // Tap - button
        await tester.tap(find.text('-'));
        await tester.pumpAndSettle();

        // Tap 1 button
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();

        // Tap 2 button
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Verify expression is displayed
        expect(find.text('45-12'), findsOneWidget);

        // Tap = button
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 33
        tester.verifyResult('33');
      });

      testWidgets('30÷5= calculation produces correct result',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap 3 button
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Tap 0 button
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();

        // Tap ÷ button
        await tester.tap(find.text('÷'));
        await tester.pumpAndSettle();

        // Tap 5 button
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        // Verify expression is displayed
        expect(find.text('30÷5'), findsOneWidget);

        // Tap = button
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 6
        tester.verifyResult('6');
      });

      testWidgets('decimal calculation 3.14×2= produces correct result',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap 3 button
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Tap . button
        await tester.tap(find.text('.'));
        await tester.pumpAndSettle();

        // Tap 1 button
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();

        // Tap 4 button
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        // Tap × button
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();

        // Tap 2 button
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Verify expression is displayed
        expect(find.text('3.14×2'), findsOneWidget);

        // Tap = button
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result is 6.28
        expect(find.text('6.28'), findsOneWidget);
      });
    });

    group('All Buttons Accessible and Functional', () {
      testWidgets('all 20 buttons in the 5×4 grid are present and tappable',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Row 1: C, (), ^, ÷
        expect(find.text('C'), findsOneWidget);
        expect(find.text('()'), findsOneWidget);
        expect(find.text('^'), findsOneWidget);
        expect(find.text('÷'), findsOneWidget);

        // Row 2: 7, 8, 9, ×
        expect(find.text('7'), findsOneWidget);
        expect(find.text('8'), findsOneWidget);
        expect(find.text('9'), findsOneWidget);
        expect(find.text('×'), findsOneWidget);

        // Row 3: 4, 5, 6, +
        expect(find.text('4'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
        expect(find.text('6'), findsOneWidget);
        expect(find.text('+'), findsOneWidget);

        // Row 4: 1, 2, 3, -
        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('-'), findsOneWidget);

        // Row 5: +/-, 0, ., =
        expect(find.text('+/-'), findsOneWidget);
        expect(find.text('0'), findsOneWidget);
        expect(find.text('.'), findsOneWidget);
        expect(find.text('='), findsOneWidget);
      });

      testWidgets('all digit buttons (0-9) are functional',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Test each digit button
        for (var i = 1; i <= 9; i++) {
          await tester.tap(find.text('$i'));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();

        // Verify all digits were entered
        expect(find.text('1234567890'), findsOneWidget);
      });

      testWidgets('all operator buttons are functional',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Test + operator
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        expect(find.text('5+'), findsOneWidget);

        // Clear and test - operator
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('-'));
        await tester.pumpAndSettle();
        expect(find.text('5-'), findsOneWidget);

        // Clear and test × operator
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        expect(find.text('5×'), findsOneWidget);

        // Clear and test ÷ operator
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('÷'));
        await tester.pumpAndSettle();
        expect(find.text('5÷'), findsOneWidget);
      });

      testWidgets('clear button resets expression',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter some expression
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        expect(find.text('123'), findsOneWidget);

        // Tap clear button
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Verify expression is cleared
        expect(find.text('123'), findsNothing);
        expect(find.text('0'), findsOneWidget); // Placeholder
      });

      testWidgets('parenthesis button is functional',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap parenthesis button to insert '('
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();

        expect(find.text('('), findsWidgets);

        // Enter a number
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        // Tap parenthesis button again to insert ')'
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();

        expect(find.text('(5)'), findsOneWidget);
      });

      testWidgets('power button is functional',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter base number
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap power button
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        // Enter exponent
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        expect(find.text('2^3'), findsOneWidget);

        // Evaluate
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        tester.verifyResult('8');
      });

      testWidgets('decimal button is functional',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter a decimal number
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('.'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        expect(find.text('1.5'), findsOneWidget);
      });

      testWidgets('equals button evaluates expression',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter simple expression
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap equals
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        tester.verifyResult('4');
      });
    });

    group('Negate Button Integration', () {
      testWidgets('+/- button toggles sign of positive number',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter a positive number
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        expect(find.text('5'), findsWidgets);

        // Tap negate button
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();

        // Number should be negated
        expect(find.text('-5'), findsOneWidget);
      });

      testWidgets('+/- button toggles sign of negative number back to positive',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter a number and negate it
        await tester.tap(find.text('7'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();
        expect(find.text('-7'), findsOneWidget);

        // Tap negate again to make it positive
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();

        // Number should be positive again
        expect(find.text('7'), findsWidgets);
      });

      testWidgets('+/- button on empty expression starts negative number',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap negate button on empty expression
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();

        // Should show minus sign
        expect(find.text('-'), findsWidgets);

        // Add digits
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        expect(find.text('-42'), findsOneWidget);
      });

      testWidgets('negate works in complex expression',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Build expression: -5+3
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        expect(find.text('-5+3'), findsOneWidget);

        // Evaluate
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Result should be -2
        final resultNeg2 = find.text('-2');
        final resultNeg2_0 = find.text('-2.0');
        expect(
          resultNeg2.evaluate().isNotEmpty || resultNeg2_0.evaluate().isNotEmpty,
          isTrue,
          reason: 'Expected result to be -2 or -2.0',
        );
      });

      testWidgets('negate with decimal number',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter decimal number
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('.'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        expect(find.text('3.14'), findsOneWidget);

        // Negate
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();

        expect(find.text('-3.14'), findsOneWidget);
      });
    });

    group('Backspace Button Position Above Grid', () {
      testWidgets('backspace button exists and is positioned above the button grid',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Verify BackspaceButton exists
        final backspaceButton = find.byType(BackspaceButton);
        expect(backspaceButton, findsOneWidget);

        // Verify backspace icon exists
        expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);

        // Get positions
        final backspacePosition = tester.getCenter(backspaceButton);

        // Get position of a button in the first row of the grid (e.g., 'C' button)
        final clearButton = find.text('C');
        final clearPosition = tester.getCenter(clearButton);

        // Backspace should be above the clear button (smaller Y value)
        expect(backspacePosition.dy, lessThan(clearPosition.dy),
            reason: 'Backspace button should be positioned above the button grid');
      });

      testWidgets('backspace button is separate from the main 5×4 grid',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Find backspace button
        final backspaceButton = find.byType(BackspaceButton);
        expect(backspaceButton, findsOneWidget);

        // Find top row buttons in the grid
        final clearButton = find.text('C');
        final parenthesisButton = find.text('()');
        final powerButton = find.text('^');
        final divideButton = find.text('÷');

        // Get Y positions
        final backspaceY = tester.getCenter(backspaceButton).dy;
        final clearY = tester.getCenter(clearButton).dy;
        final parenthesisY = tester.getCenter(parenthesisButton).dy;
        final powerY = tester.getCenter(powerButton).dy;
        final divideY = tester.getCenter(divideButton).dy;

        // All top row grid buttons should be in the same row
        const tolerance = 5.0;
        expect((clearY - parenthesisY).abs(), lessThan(tolerance));
        expect((parenthesisY - powerY).abs(), lessThan(tolerance));
        expect((powerY - divideY).abs(), lessThan(tolerance));

        // Backspace should be clearly above all of them
        expect(backspaceY, lessThan(clearY - tolerance),
            reason: 'Backspace should be clearly above the grid top row');
      });

      testWidgets('backspace button is functional and deletes last character',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter expression
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        expect(find.text('123'), findsOneWidget);

        // Tap backspace using the icon
        await tester.tap(find.byIcon(Icons.backspace_outlined));
        await tester.pumpAndSettle();

        // Last character should be deleted
        expect(find.text('12'), findsOneWidget);
        expect(find.text('123'), findsNothing);
      });

      testWidgets('backspace button uses text symbol in grid for fallback',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // The ⌫ symbol should exist (in the button grid as fallback text)
        expect(find.text('⌫'), findsOneWidget);
      });
    });

    group('Grid Layout Structure Verification', () {
      testWidgets('Row 1 buttons are in correct horizontal order: C, (), ^, ÷',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        final clearX = tester.getCenter(find.text('C')).dx;
        final parenthesisX = tester.getCenter(find.text('()')).dx;
        final powerX = tester.getCenter(find.text('^')).dx;
        final divideX = tester.getCenter(find.text('÷')).dx;

        expect(clearX, lessThan(parenthesisX));
        expect(parenthesisX, lessThan(powerX));
        expect(powerX, lessThan(divideX));
      });

      testWidgets('Row 2 buttons are in correct horizontal order: 7, 8, 9, ×',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        final pos7 = tester.getCenter(find.text('7')).dx;
        final pos8 = tester.getCenter(find.text('8')).dx;
        final pos9 = tester.getCenter(find.text('9')).dx;
        final posMultiply = tester.getCenter(find.text('×')).dx;

        expect(pos7, lessThan(pos8));
        expect(pos8, lessThan(pos9));
        expect(pos9, lessThan(posMultiply));
      });

      testWidgets('Row 3 buttons are in correct horizontal order: 4, 5, 6, +',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        final pos4 = tester.getCenter(find.text('4')).dx;
        final pos5 = tester.getCenter(find.text('5')).dx;
        final pos6 = tester.getCenter(find.text('6')).dx;
        final posPlus = tester.getCenter(find.text('+')).dx;

        expect(pos4, lessThan(pos5));
        expect(pos5, lessThan(pos6));
        expect(pos6, lessThan(posPlus));
      });

      testWidgets('Row 4 buttons are in correct horizontal order: 1, 2, 3, -',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        final pos1 = tester.getCenter(find.text('1')).dx;
        final pos2 = tester.getCenter(find.text('2')).dx;
        final pos3 = tester.getCenter(find.text('3')).dx;
        final posMinus = tester.getCenter(find.text('-')).dx;

        expect(pos1, lessThan(pos2));
        expect(pos2, lessThan(pos3));
        expect(pos3, lessThan(posMinus));
      });

      testWidgets('Row 5 buttons are in correct horizontal order: +/-, 0, ., =',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        final posNegate = tester.getCenter(find.text('+/-')).dx;
        final pos0 = tester.getCenter(find.text('0')).dx;
        final posDecimal = tester.getCenter(find.text('.')).dx;
        final posEquals = tester.getCenter(find.text('=')).dx;

        expect(posNegate, lessThan(pos0));
        expect(pos0, lessThan(posDecimal));
        expect(posDecimal, lessThan(posEquals));
      });

      testWidgets('rows are in correct vertical order (top to bottom)',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Get Y position of one button from each row
        final row1Y = tester.getCenter(find.text('C')).dy;
        final row2Y = tester.getCenter(find.text('7')).dy;
        final row3Y = tester.getCenter(find.text('4')).dy;
        final row4Y = tester.getCenter(find.text('1')).dy;
        final row5Y = tester.getCenter(find.text('0')).dy;

        expect(row1Y, lessThan(row2Y), reason: 'Row 1 should be above Row 2');
        expect(row2Y, lessThan(row3Y), reason: 'Row 2 should be above Row 3');
        expect(row3Y, lessThan(row4Y), reason: 'Row 3 should be above Row 4');
        expect(row4Y, lessThan(row5Y), reason: 'Row 4 should be above Row 5');
      });

      testWidgets('operators are in rightmost column',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Get X positions of operators
        final divideX = tester.getCenter(find.text('÷')).dx;
        final multiplyX = tester.getCenter(find.text('×')).dx;
        final plusX = tester.getCenter(find.text('+')).dx;
        final minusX = tester.getCenter(find.text('-')).dx;

        // Get X position of digit in same row for comparison
        final digit9X = tester.getCenter(find.text('9')).dx;
        final digit6X = tester.getCenter(find.text('6')).dx;
        final digit3X = tester.getCenter(find.text('3')).dx;

        // Operators should be to the right of digits
        expect(multiplyX, greaterThan(digit9X));
        expect(plusX, greaterThan(digit6X));
        expect(minusX, greaterThan(digit3X));

        // All operators should be aligned in the same column
        const tolerance = 5.0;
        expect((divideX - multiplyX).abs(), lessThan(tolerance));
        expect((multiplyX - plusX).abs(), lessThan(tolerance));
        expect((plusX - minusX).abs(), lessThan(tolerance));
      });

      testWidgets('digit buttons 7-8-9, 4-5-6, 1-2-3 are in standard 3x3 arrangement',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        const tolerance = 5.0;

        // Get positions
        final pos1 = tester.getCenter(find.text('1'));
        final pos2 = tester.getCenter(find.text('2'));
        final pos3 = tester.getCenter(find.text('3'));
        final pos4 = tester.getCenter(find.text('4'));
        final pos5 = tester.getCenter(find.text('5'));
        final pos6 = tester.getCenter(find.text('6'));
        final pos7 = tester.getCenter(find.text('7'));
        final pos8 = tester.getCenter(find.text('8'));
        final pos9 = tester.getCenter(find.text('9'));

        // Left column: 7, 4, 1 should be aligned vertically
        expect((pos7.dx - pos4.dx).abs(), lessThan(tolerance));
        expect((pos4.dx - pos1.dx).abs(), lessThan(tolerance));

        // Middle column: 8, 5, 2 should be aligned vertically
        expect((pos8.dx - pos5.dx).abs(), lessThan(tolerance));
        expect((pos5.dx - pos2.dx).abs(), lessThan(tolerance));

        // Right column: 9, 6, 3 should be aligned vertically
        expect((pos9.dx - pos6.dx).abs(), lessThan(tolerance));
        expect((pos6.dx - pos3.dx).abs(), lessThan(tolerance));
      });
    });

    group('Complete Calculator Workflow', () {
      testWidgets('full calculation workflow with all button types',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Build complex expression: (2+3)^2
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
        await tester.tap(find.byKey(const Key('power_button'))); // ^
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Verify expression
        expect(find.text('(2+3)^2'), findsOneWidget);

        // Evaluate
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Result should be 25
        tester.verifyResult('25');

        // Clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Start new calculation with negate
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();

        expect(find.text('-10'), findsOneWidget);

        // Add to expression
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        // Evaluate
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Result should be 5
        tester.verifyResult('5');
      });

      testWidgets('calculation with backspace correction',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter 123
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        expect(find.text('123'), findsOneWidget);

        // Use backspace to correct to 12
        await tester.tap(find.byIcon(Icons.backspace_outlined));
        await tester.pumpAndSettle();

        expect(find.text('12'), findsOneWidget);

        // Continue with calculation
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Evaluate
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Result should be 24
        tester.verifyResult('24');
      });

      testWidgets('multiple sequential calculations',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Calculation 1: 5+3=8
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();
        tester.verifyResult('8');

        // Clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Calculation 2: 9×7=63
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('7'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();
        tester.verifyResult('63');

        // Clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Calculation 3: 100÷4=25
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('÷'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();
        tester.verifyResult('25');
      });
    });
  });
}
