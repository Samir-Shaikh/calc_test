import 'package:android_calculator_flutter/features/calculator/presentation/widgets/backspace_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('RTL Layout Mirroring Integration Tests', () {
    group('Calculator Screen Layout in RTL Mode', () {
      testWidgets('calculator screen renders correctly in RTL mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        // Verify all essential UI elements are present
        expect(find.text('0'), findsWidgets); // Initial display
        expect(find.text('C'), findsOneWidget);
        expect(find.text('()'), findsOneWidget);
        expect(find.text('^'), findsOneWidget);
        expect(find.text('÷'), findsOneWidget);
        expect(find.text('='), findsOneWidget);
        expect(find.byType(BackspaceButton), findsOneWidget);
      });

      testWidgets('display area is present and accessible in RTL mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        // Verify expression display area exists
        expect(find.text('0'), findsWidgets);

        // Enter some digits to verify display works
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        expect(find.text('123'), findsOneWidget);
      });

      testWidgets('backspace button is positioned at logical end in RTL mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        // Find backspace button
        final backspaceButton = find.byType(BackspaceButton);
        expect(backspaceButton, findsOneWidget);

        // Get screen width
        final screenSize = tester.view.physicalSize / tester.view.devicePixelRatio;
        final screenCenterX = screenSize.width / 2;

        // Get backspace button position
        final backspacePosition = tester.getCenter(backspaceButton);

        // In RTL mode, the backspace button (which uses MainAxisAlignment.end)
        // should be positioned on the left side of the screen (logical end in RTL)
        expect(backspacePosition.dx, lessThan(screenCenterX),
            reason: 'Backspace button should be on the left side in RTL mode');
      });

      testWidgets('backspace button is above the button grid in RTL mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        // Get positions
        final backspacePosition = tester.getCenter(find.byType(BackspaceButton));
        final clearButtonPosition = tester.getCenter(find.text('C'));

        // Backspace should be above the grid (smaller Y value)
        expect(backspacePosition.dy, lessThan(clearButtonPosition.dy),
            reason: 'Backspace button should be above the button grid in RTL mode');
      });
    });

    group('Button Grid Layout in RTL Mode', () {
      testWidgets('Row 1 buttons are mirrored in RTL: ÷, ^, (), C',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        final clearX = tester.getCenter(find.text('C')).dx;
        final parenthesisX = tester.getCenter(find.text('()')).dx;
        final powerX = tester.getCenter(find.text('^')).dx;
        final divideX = tester.getCenter(find.text('÷')).dx;

        // In RTL mode, the order should be reversed (right to left):
        // Visually: ÷, ^, (), C
        // So divideX < powerX < parenthesisX < clearX
        expect(divideX, lessThan(powerX),
            reason: 'In RTL, ÷ should be to the left of ^');
        expect(powerX, lessThan(parenthesisX),
            reason: 'In RTL, ^ should be to the left of ()');
        expect(parenthesisX, lessThan(clearX),
            reason: 'In RTL, () should be to the left of C');
      });

      testWidgets('Row 2 buttons are mirrored in RTL: ×, 9, 8, 7',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        final pos7 = tester.getCenter(find.text('7')).dx;
        final pos8 = tester.getCenter(find.text('8')).dx;
        final pos9 = tester.getCenter(find.text('9')).dx;
        final posMultiply = tester.getCenter(find.text('×')).dx;

        // In RTL mode, the order should be reversed:
        // Visually: ×, 9, 8, 7
        expect(posMultiply, lessThan(pos9),
            reason: 'In RTL, × should be to the left of 9');
        expect(pos9, lessThan(pos8),
            reason: 'In RTL, 9 should be to the left of 8');
        expect(pos8, lessThan(pos7),
            reason: 'In RTL, 8 should be to the left of 7');
      });

      testWidgets('Row 3 buttons are mirrored in RTL: +, 6, 5, 4',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        final pos4 = tester.getCenter(find.text('4')).dx;
        final pos5 = tester.getCenter(find.text('5')).dx;
        final pos6 = tester.getCenter(find.text('6')).dx;
        final posPlus = tester.getCenter(find.text('+')).dx;

        // In RTL mode, the order should be reversed:
        // Visually: +, 6, 5, 4
        expect(posPlus, lessThan(pos6),
            reason: 'In RTL, + should be to the left of 6');
        expect(pos6, lessThan(pos5),
            reason: 'In RTL, 6 should be to the left of 5');
        expect(pos5, lessThan(pos4),
            reason: 'In RTL, 5 should be to the left of 4');
      });

      testWidgets('Row 4 buttons are mirrored in RTL: -, 3, 2, 1',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        final pos1 = tester.getCenter(find.text('1')).dx;
        final pos2 = tester.getCenter(find.text('2')).dx;
        final pos3 = tester.getCenter(find.text('3')).dx;
        final posMinus = tester.getCenter(find.text('-')).dx;

        // In RTL mode, the order should be reversed:
        // Visually: -, 3, 2, 1
        expect(posMinus, lessThan(pos3),
            reason: 'In RTL, - should be to the left of 3');
        expect(pos3, lessThan(pos2),
            reason: 'In RTL, 3 should be to the left of 2');
        expect(pos2, lessThan(pos1),
            reason: 'In RTL, 2 should be to the left of 1');
      });

      testWidgets('Row 5 buttons are mirrored in RTL: =, ., 0, +/-',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        final posNegate = tester.getCenter(find.text('+/-')).dx;
        final pos0 = tester.getCenter(find.text('0')).dx;
        final posDecimal = tester.getCenter(find.text('.')).dx;
        final posEquals = tester.getCenter(find.text('=')).dx;

        // In RTL mode, the order should be reversed:
        // Visually: =, ., 0, +/-
        expect(posEquals, lessThan(posDecimal),
            reason: 'In RTL, = should be to the left of .');
        expect(posDecimal, lessThan(pos0),
            reason: 'In RTL, . should be to the left of 0');
        expect(pos0, lessThan(posNegate),
            reason: 'In RTL, 0 should be to the left of +/-');
      });

      testWidgets('operators are in leftmost column in RTL mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        // Get X positions of operators
        final divideX = tester.getCenter(find.text('÷')).dx;
        final multiplyX = tester.getCenter(find.text('×')).dx;
        final plusX = tester.getCenter(find.text('+')).dx;
        final minusX = tester.getCenter(find.text('-')).dx;

        // Get X position of digits in same rows for comparison
        final digit9X = tester.getCenter(find.text('9')).dx;
        final digit6X = tester.getCenter(find.text('6')).dx;
        final digit3X = tester.getCenter(find.text('3')).dx;

        // In RTL, operators should be to the left of digits (lower X value)
        expect(multiplyX, lessThan(digit9X),
            reason: 'In RTL, × should be to the left of 9');
        expect(plusX, lessThan(digit6X),
            reason: 'In RTL, + should be to the left of 6');
        expect(minusX, lessThan(digit3X),
            reason: 'In RTL, - should be to the left of 3');

        // All operators should be aligned in the same column
        const tolerance = 5.0;
        expect((divideX - multiplyX).abs(), lessThan(tolerance),
            reason: 'Operators should be vertically aligned');
        expect((multiplyX - plusX).abs(), lessThan(tolerance),
            reason: 'Operators should be vertically aligned');
        expect((plusX - minusX).abs(), lessThan(tolerance),
            reason: 'Operators should be vertically aligned');
      });

      testWidgets('rows maintain correct vertical order in RTL mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        // Get Y position of one button from each row
        final row1Y = tester.getCenter(find.text('C')).dy;
        final row2Y = tester.getCenter(find.text('7')).dy;
        final row3Y = tester.getCenter(find.text('4')).dy;
        final row4Y = tester.getCenter(find.text('1')).dy;
        final row5Y = tester.getCenter(find.text('0')).dy;

        // Vertical order should be the same as LTR
        expect(row1Y, lessThan(row2Y), reason: 'Row 1 should be above Row 2');
        expect(row2Y, lessThan(row3Y), reason: 'Row 2 should be above Row 3');
        expect(row3Y, lessThan(row4Y), reason: 'Row 3 should be above Row 4');
        expect(row4Y, lessThan(row5Y), reason: 'Row 4 should be above Row 5');
      });
    });

    group('Complete Calculation Flow in RTL Mode', () {
      testWidgets('basic addition works in RTL mode: 5+3=8',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        expect(find.text('5+3'), findsOneWidget);

        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        tester.verifyResult('8');
      });

      testWidgets('subtraction works in RTL mode: 10-4=6',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('-'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        tester.verifyResult('6');
      });

      testWidgets('multiplication works in RTL mode: 7×8=56',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        await tester.tap(find.text('7'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('8'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        tester.verifyResult('56');
      });

      testWidgets('division works in RTL mode: 24÷6=4',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('÷'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('6'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        tester.verifyResult('4');
      });

      testWidgets('power operation works in RTL mode: 2^4=16',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        expect(find.text('2^4'), findsOneWidget);

        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        tester.verifyResult('16');
      });

      testWidgets('parentheses work in RTL mode: (2+3)×4=20',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

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

        expect(find.text('(2+3)×4'), findsOneWidget);

        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        tester.verifyResult('20');
      });

      testWidgets('clear button works in RTL mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        // Enter some expression
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        expect(find.text('123'), findsOneWidget);

        // Tap clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Expression should be cleared
        expect(find.text('123'), findsNothing);
        expect(find.text('0'), findsWidgets);
      });

      testWidgets('backspace button works in RTL mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        // Enter expression
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        expect(find.text('123'), findsOneWidget);

        // Tap backspace
        await tester.tap(find.byIcon(Icons.backspace_outlined));
        await tester.pumpAndSettle();

        // Last character should be deleted
        expect(find.text('12'), findsOneWidget);
        expect(find.text('123'), findsNothing);
      });

      testWidgets('negate button works in RTL mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        // Enter a number
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        // Tap negate
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();

        expect(find.text('-5'), findsOneWidget);

        // Tap negate again
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();

        expect(find.text('5'), findsWidgets);
      });

      testWidgets('decimal input works in RTL mode: 3.14×2=6.28',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('.'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        expect(find.text('6.28'), findsOneWidget);
      });

      testWidgets('order of operations works in RTL mode: 2+3×4=14',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

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

        // Should be 2 + (3 × 4) = 2 + 12 = 14
        tester.verifyResult('14');
      });

      testWidgets('complex expression works in RTL mode: (2+3)^2=25',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

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

        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        tester.verifyResult('25');
      });

      testWidgets('multiple sequential calculations work in RTL mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        // First calculation: 5+3=8
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

        // Second calculation: 9×7=63
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

        // Third calculation: 100÷4=25
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

    group('RTL vs LTR Layout Comparison', () {
      testWidgets('buttons are horizontally mirrored between LTR and RTL',
          (WidgetTester tester) async {
        // First test LTR
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        final ltrClearX = tester.getCenter(find.text('C')).dx;
        final ltrDivideX = tester.getCenter(find.text('÷')).dx;

        // In LTR: C is on the left, ÷ is on the right
        expect(ltrClearX, lessThan(ltrDivideX),
            reason: 'In LTR, C should be to the left of ÷');

        // Now test RTL
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        final rtlClearX = tester.getCenter(find.text('C')).dx;
        final rtlDivideX = tester.getCenter(find.text('÷')).dx;

        // In RTL: C is on the right, ÷ is on the left
        expect(rtlDivideX, lessThan(rtlClearX),
            reason: 'In RTL, ÷ should be to the left of C');
      });

      testWidgets('digit buttons 1-2-3 are mirrored between LTR and RTL',
          (WidgetTester tester) async {
        // First test LTR
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        final ltr1X = tester.getCenter(find.text('1')).dx;
        final ltr3X = tester.getCenter(find.text('3')).dx;

        // In LTR: 1 is on the left, 3 is on the right
        expect(ltr1X, lessThan(ltr3X),
            reason: 'In LTR, 1 should be to the left of 3');

        // Now test RTL
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        final rtl1X = tester.getCenter(find.text('1')).dx;
        final rtl3X = tester.getCenter(find.text('3')).dx;

        // In RTL: 1 is on the right, 3 is on the left
        expect(rtl3X, lessThan(rtl1X),
            reason: 'In RTL, 3 should be to the left of 1');
      });

      testWidgets('calculation produces same result in both LTR and RTL',
          (WidgetTester tester) async {
        // Test in LTR
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

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

        // Test same calculation in RTL
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

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

        // Result should be the same regardless of text direction
        tester.verifyResult('14');
      });
    });

    group('Edge Cases in RTL Mode', () {
      testWidgets('division by zero shows Infinity in RTL mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('÷'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        expect(find.text('Infinity'), findsOneWidget);
      });

      testWidgets('negative number calculation works in RTL mode: -5+3=-2',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        // Enter 5, negate it, then add 3
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // -5 + 3 = -2
        final resultNeg2 = find.text('-2');
        final resultNeg2_0 = find.text('-2.0');
        expect(
          resultNeg2.evaluate().isNotEmpty || resultNeg2_0.evaluate().isNotEmpty,
          isTrue,
          reason: 'Expected result to be -2 or -2.0',
        );
      });

      testWidgets('large numbers work correctly in RTL mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestAppRTL());
        await tester.pumpAndSettle();

        // 999 × 999 = 998001
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        tester.verifyResult('998001');
      });
    });
  });
}
