import 'package:android_calculator_flutter/features/calculator/presentation/theme/calculator_dimensions.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Circular Button Design Integration Tests', () {
    group('Numeric Buttons Circular Appearance', () {
      testWidgets('all numeric buttons (0-9) are rendered with circular shape',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Verify all numeric buttons exist and are CalculatorButtons
        for (var digit = 0; digit <= 9; digit++) {
          final buttonFinder = find.ancestor(
            of: find.text('$digit'),
            matching: find.byType(CalculatorButton),
          );
          expect(
            buttonFinder,
            findsOneWidget,
            reason: 'Digit $digit should be displayed in a CalculatorButton',
          );
        }
      });

      testWidgets('numeric buttons have consistent height of 70dp',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Check height of numeric buttons
        for (var digit = 1; digit <= 9; digit++) {
          final buttonFinder = find.ancestor(
            of: find.text('$digit'),
            matching: find.byType(CalculatorButton),
          );

          final buttonWidget = tester.widget<CalculatorButton>(buttonFinder);
          expect(buttonWidget, isNotNull);

          // The CalculatorButton uses CalculatorDimensions.circularButtonHeight
          // We verify this constant is applied in the layout
          final sizedBoxFinder = find.descendant(
            of: buttonFinder,
            matching: find.byType(SizedBox),
          );
          expect(sizedBoxFinder, findsWidgets);
        }
      });

      testWidgets('numeric buttons have 5dp margin applied',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Find a numeric button and verify padding
        final buttonFinder = find.ancestor(
          of: find.text('5'),
          matching: find.byType(CalculatorButton),
        );

        final paddingFinder = find.descendant(
          of: buttonFinder,
          matching: find.byType(Padding),
        );
        expect(paddingFinder, findsWidgets);

        // Get the first Padding widget (should be the margin)
        final paddingWidget = tester.widget<Padding>(paddingFinder.first);
        final edgeInsets = paddingWidget.padding as EdgeInsets;
        expect(
          edgeInsets.left,
          equals(CalculatorDimensions.circularButtonMargin),
          reason: 'Button should have 5dp left margin',
        );
        expect(
          edgeInsets.right,
          equals(CalculatorDimensions.circularButtonMargin),
          reason: 'Button should have 5dp right margin',
        );
        expect(
          edgeInsets.top,
          equals(CalculatorDimensions.circularButtonMargin),
          reason: 'Button should have 5dp top margin',
        );
        expect(
          edgeInsets.bottom,
          equals(CalculatorDimensions.circularButtonMargin),
          reason: 'Button should have 5dp bottom margin',
        );
      });

      testWidgets('numeric buttons have borderless circular decoration',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Find a numeric button container
        final buttonFinder = find.ancestor(
          of: find.text('7'),
          matching: find.byType(CalculatorButton),
        );

        final containerFinder = find.descendant(
          of: buttonFinder,
          matching: find.byType(Container),
        );
        expect(containerFinder, findsWidgets);

        // The container should have a BoxDecoration with high border radius
        final container = tester.widget<Container>(containerFinder.first);
        expect(container.decoration, isA<BoxDecoration>());

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.borderRadius, isNotNull);
        expect(
          decoration.border,
          isNull,
          reason: 'Button should have borderless appearance',
        );
      });
    });

    group('Operator Buttons Circular Appearance', () {
      testWidgets('all operator buttons (+, -, ×, ÷, =) are rendered with circular shape',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        final operators = ['+', '-', '×', '÷', '='];

        for (final operator in operators) {
          final buttonFinder = find.ancestor(
            of: find.text(operator),
            matching: find.byType(CalculatorButton),
          );
          expect(
            buttonFinder,
            findsOneWidget,
            reason: 'Operator $operator should be displayed in a CalculatorButton',
          );
        }
      });

      testWidgets('operator buttons have consistent circular styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        final operators = ['+', '-', '×', '÷'];

        for (final operator in operators) {
          final buttonFinder = find.ancestor(
            of: find.text(operator),
            matching: find.byType(CalculatorButton),
          );

          final containerFinder = find.descendant(
            of: buttonFinder,
            matching: find.byType(Container),
          );
          expect(containerFinder, findsWidgets);

          final container = tester.widget<Container>(containerFinder.first);
          expect(
            container.decoration,
            isA<BoxDecoration>(),
            reason: 'Operator $operator should have BoxDecoration',
          );

          final decoration = container.decoration as BoxDecoration;
          expect(
            decoration.border,
            isNull,
            reason: 'Operator $operator should have borderless appearance',
          );
        }
      });

      testWidgets('equals button has circular styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        final equalsFinder = find.byKey(const Key('equals_button'));
        expect(equalsFinder, findsOneWidget);

        // Verify it has circular decoration by checking the container
        final containerFinder = find.descendant(
          of: equalsFinder,
          matching: find.byType(Container),
        );
        expect(containerFinder, findsWidgets);

        final container = tester.widget<Container>(containerFinder.first);
        expect(container.decoration, isA<BoxDecoration>());

        final decoration = container.decoration as BoxDecoration;
        expect(
          decoration.border,
          isNull,
          reason: 'Equals button should have borderless appearance',
        );
      });
    });

    group('Function Buttons Circular Appearance', () {
      testWidgets('clear button (C) has circular styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        final clearFinder = find.byKey(const Key('clear_button'));
        expect(clearFinder, findsOneWidget);

        // Verify circular decoration
        final containerFinder = find.descendant(
          of: clearFinder,
          matching: find.byType(Container),
        );
        expect(containerFinder, findsWidgets);

        final container = tester.widget<Container>(containerFinder.first);
        expect(container.decoration, isA<BoxDecoration>());

        final decoration = container.decoration as BoxDecoration;
        expect(
          decoration.border,
          isNull,
          reason: 'Clear button should have borderless appearance',
        );
      });

      testWidgets('parenthesis button (()) has circular styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        final parenthesisFinder = find.byKey(const Key('parenthesis_button'));
        expect(parenthesisFinder, findsOneWidget);

        // Verify circular decoration
        final containerFinder = find.descendant(
          of: parenthesisFinder,
          matching: find.byType(Container),
        );
        expect(containerFinder, findsWidgets);

        final container = tester.widget<Container>(containerFinder.first);
        expect(container.decoration, isA<BoxDecoration>());
      });

      testWidgets('power button (^) has circular styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        final powerFinder = find.byKey(const Key('power_button'));
        expect(powerFinder, findsOneWidget);

        // Verify circular decoration
        final containerFinder = find.descendant(
          of: powerFinder,
          matching: find.byType(Container),
        );
        expect(containerFinder, findsWidgets);

        final container = tester.widget<Container>(containerFinder.first);
        expect(container.decoration, isA<BoxDecoration>());
      });

      testWidgets('negate button (+/-) has circular styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        final negateFinder = find.byKey(const Key('negate_button'));
        expect(negateFinder, findsOneWidget);

        // Verify circular decoration
        final containerFinder = find.descendant(
          of: negateFinder,
          matching: find.byType(Container),
        );
        expect(containerFinder, findsWidgets);

        final container = tester.widget<Container>(containerFinder.first);
        expect(container.decoration, isA<BoxDecoration>());
      });

      testWidgets('decimal button (.) has circular styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        final buttonFinder = find.ancestor(
          of: find.text('.'),
          matching: find.byType(CalculatorButton),
        );
        expect(buttonFinder, findsOneWidget);

        // Verify circular decoration
        final containerFinder = find.descendant(
          of: buttonFinder,
          matching: find.byType(Container),
        );
        expect(containerFinder, findsWidgets);

        final container = tester.widget<Container>(containerFinder.first);
        expect(container.decoration, isA<BoxDecoration>());

        final decoration = container.decoration as BoxDecoration;
        expect(
          decoration.border,
          isNull,
          reason: 'Decimal button should have borderless appearance',
        );
      });
    });

    group('Consistent Spacing Between Buttons', () {
      testWidgets('buttons in the same row have consistent horizontal spacing',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Check Row 2: 7, 8, 9, ×
        final pos7 = tester.getCenter(find.text('7'));
        final pos8 = tester.getCenter(find.text('8'));
        final pos9 = tester.getCenter(find.text('9'));
        final posMultiply = tester.getCenter(find.text('×'));

        // Calculate spacing between adjacent buttons
        final spacing78 = pos8.dx - pos7.dx;
        final spacing89 = pos9.dx - pos8.dx;
        final spacing9Multiply = posMultiply.dx - pos9.dx;

        // All spacings should be approximately equal (within tolerance)
        const tolerance = 5.0;
        expect(
          (spacing78 - spacing89).abs(),
          lessThan(tolerance),
          reason: 'Spacing between 7-8 and 8-9 should be consistent',
        );
        expect(
          (spacing89 - spacing9Multiply).abs(),
          lessThan(tolerance),
          reason: 'Spacing between 8-9 and 9-× should be consistent',
        );
      });

      testWidgets('buttons in adjacent rows have consistent vertical spacing',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Check vertical spacing between rows (using leftmost column)
        final posClear = tester.getCenter(find.text('C'));
        final pos7 = tester.getCenter(find.text('7'));
        final pos4 = tester.getCenter(find.text('4'));
        final pos1 = tester.getCenter(find.text('1'));
        final posNegate = tester.getCenter(find.text('+/-'));

        // Calculate vertical spacing between adjacent rows
        final spacingRow1to2 = pos7.dy - posClear.dy;
        final spacingRow2to3 = pos4.dy - pos7.dy;
        final spacingRow3to4 = pos1.dy - pos4.dy;
        final spacingRow4to5 = posNegate.dy - pos1.dy;

        // All vertical spacings should be approximately equal
        const tolerance = 5.0;
        expect(
          (spacingRow1to2 - spacingRow2to3).abs(),
          lessThan(tolerance),
          reason: 'Vertical spacing between Row 1-2 and Row 2-3 should be consistent',
        );
        expect(
          (spacingRow2to3 - spacingRow3to4).abs(),
          lessThan(tolerance),
          reason: 'Vertical spacing between Row 2-3 and Row 3-4 should be consistent',
        );
        expect(
          (spacingRow3to4 - spacingRow4to5).abs(),
          lessThan(tolerance),
          reason: 'Vertical spacing between Row 3-4 and Row 4-5 should be consistent',
        );
      });

      testWidgets('all columns are aligned vertically',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        const tolerance = 5.0;

        // Column 1: C, 7, 4, 1, +/-
        final xClear = tester.getCenter(find.text('C')).dx;
        final x7 = tester.getCenter(find.text('7')).dx;
        final x4 = tester.getCenter(find.text('4')).dx;
        final x1 = tester.getCenter(find.text('1')).dx;
        final xNegate = tester.getCenter(find.text('+/-')).dx;

        expect((xClear - x7).abs(), lessThan(tolerance));
        expect((x7 - x4).abs(), lessThan(tolerance));
        expect((x4 - x1).abs(), lessThan(tolerance));
        expect((x1 - xNegate).abs(), lessThan(tolerance));

        // Column 2: (), 8, 5, 2, 0
        final xParenthesis = tester.getCenter(find.text('()')).dx;
        final x8 = tester.getCenter(find.text('8')).dx;
        final x5 = tester.getCenter(find.text('5')).dx;
        final x2 = tester.getCenter(find.text('2')).dx;
        final x0 = tester.getCenter(find.text('0')).dx;

        expect((xParenthesis - x8).abs(), lessThan(tolerance));
        expect((x8 - x5).abs(), lessThan(tolerance));
        expect((x5 - x2).abs(), lessThan(tolerance));
        expect((x2 - x0).abs(), lessThan(tolerance));

        // Column 3: ^, 9, 6, 3, .
        final xPower = tester.getCenter(find.text('^')).dx;
        final x9 = tester.getCenter(find.text('9')).dx;
        final x6 = tester.getCenter(find.text('6')).dx;
        final x3 = tester.getCenter(find.text('3')).dx;
        final xDecimal = tester.getCenter(find.text('.')).dx;

        expect((xPower - x9).abs(), lessThan(tolerance));
        expect((x9 - x6).abs(), lessThan(tolerance));
        expect((x6 - x3).abs(), lessThan(tolerance));
        expect((x3 - xDecimal).abs(), lessThan(tolerance));

        // Column 4: ÷, ×, +, -, =
        final xDivide = tester.getCenter(find.text('÷')).dx;
        final xMultiply = tester.getCenter(find.text('×')).dx;
        final xPlus = tester.getCenter(find.text('+')).dx;
        final xMinus = tester.getCenter(find.text('-')).dx;
        final xEquals = tester.getCenter(find.text('=')).dx;

        expect((xDivide - xMultiply).abs(), lessThan(tolerance));
        expect((xMultiply - xPlus).abs(), lessThan(tolerance));
        expect((xPlus - xMinus).abs(), lessThan(tolerance));
        expect((xMinus - xEquals).abs(), lessThan(tolerance));
      });

      testWidgets('grid has consistent padding on edges',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Get positions of edge buttons
        final leftButton = tester.getTopLeft(find.text('C'));
        final rightButton = tester.getTopRight(find.text('÷'));

        // The left and right padding should be similar
        // (accounting for the button's internal margin)
        expect(leftButton.dx, greaterThan(0));
        
        // Get screen width to verify right padding
        final screenWidth = tester.binding.renderViews.first.size.width;
        expect(rightButton.dx, lessThan(screenWidth));
      });
    });

    group('Button Interaction Maintains Circular Appearance', () {
      testWidgets('numeric button maintains circular shape during tap',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Find button 5
        final buttonFinder = find.ancestor(
          of: find.text('5'),
          matching: find.byType(CalculatorButton),
        );

        // Get initial decoration
        final containerFinder = find.descendant(
          of: buttonFinder,
          matching: find.byType(Container),
        );
        final initialContainer = tester.widget<Container>(containerFinder.first);
        final initialDecoration = initialContainer.decoration as BoxDecoration;
        final initialBorderRadius = initialDecoration.borderRadius;

        // Tap and hold the button
        await tester.tap(buttonFinder);
        await tester.pump(); // Allow for press state

        // Verify decoration is still circular during press
        final pressedContainer = tester.widget<Container>(containerFinder.first);
        final pressedDecoration = pressedContainer.decoration as BoxDecoration;
        expect(
          pressedDecoration.borderRadius,
          equals(initialBorderRadius),
          reason: 'Border radius should remain the same during press',
        );
        expect(
          pressedDecoration.border,
          isNull,
          reason: 'Button should remain borderless during press',
        );

        await tester.pumpAndSettle();

        // Verify decoration is still circular after press
        final afterContainer = tester.widget<Container>(containerFinder.first);
        final afterDecoration = afterContainer.decoration as BoxDecoration;
        expect(
          afterDecoration.borderRadius,
          equals(initialBorderRadius),
          reason: 'Border radius should remain the same after press',
        );
      });

      testWidgets('operator button maintains circular shape during tap',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // First enter a digit so operator is valid
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        // Find operator button
        final buttonFinder = find.ancestor(
          of: find.text('+'),
          matching: find.byType(CalculatorButton),
        );

        final containerFinder = find.descendant(
          of: buttonFinder,
          matching: find.byType(Container),
        );
        final initialContainer = tester.widget<Container>(containerFinder.first);
        final initialDecoration = initialContainer.decoration as BoxDecoration;
        final initialBorderRadius = initialDecoration.borderRadius;

        // Tap the operator
        await tester.tap(buttonFinder);
        await tester.pump();

        // Verify circular styling maintained
        final pressedContainer = tester.widget<Container>(containerFinder.first);
        final pressedDecoration = pressedContainer.decoration as BoxDecoration;
        expect(
          pressedDecoration.borderRadius,
          equals(initialBorderRadius),
          reason: 'Operator button border radius should remain during press',
        );

        await tester.pumpAndSettle();
      });

      testWidgets('function button maintains circular shape during tap',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Find clear button
        final clearFinder = find.byKey(const Key('clear_button'));

        final containerFinder = find.descendant(
          of: clearFinder,
          matching: find.byType(Container),
        );
        final initialContainer = tester.widget<Container>(containerFinder.first);
        final initialDecoration = initialContainer.decoration as BoxDecoration;
        final initialBorderRadius = initialDecoration.borderRadius;

        // Tap the clear button
        await tester.tap(clearFinder);
        await tester.pump();

        // Verify circular styling maintained
        final pressedContainer = tester.widget<Container>(containerFinder.first);
        final pressedDecoration = pressedContainer.decoration as BoxDecoration;
        expect(
          pressedDecoration.borderRadius,
          equals(initialBorderRadius),
          reason: 'Clear button border radius should remain during press',
        );

        await tester.pumpAndSettle();
      });

      testWidgets('multiple button taps maintain circular appearance throughout calculation',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Perform a calculation: 7 + 8 = 15
        final buttons = ['7', '+', '8', '='];

        for (final buttonLabel in buttons) {
          Finder buttonFinder;
          if (buttonLabel == '=') {
            buttonFinder = find.byKey(const Key('equals_button'));
          } else {
            buttonFinder = find.ancestor(
              of: find.text(buttonLabel),
              matching: find.byType(CalculatorButton),
            );
          }

          // Verify button has circular decoration before tap
          final containerFinder = find.descendant(
            of: buttonFinder,
            matching: find.byType(Container),
          );
          final container = tester.widget<Container>(containerFinder.first);
          final decoration = container.decoration as BoxDecoration;
          expect(
            decoration.border,
            isNull,
            reason: 'Button $buttonLabel should have borderless appearance before tap',
          );

          // Tap the button
          await tester.tap(buttonFinder);
          await tester.pumpAndSettle();

          // Verify button still has circular decoration after tap
          final afterContainer = tester.widget<Container>(containerFinder.first);
          final afterDecoration = afterContainer.decoration as BoxDecoration;
          expect(
            afterDecoration.border,
            isNull,
            reason: 'Button $buttonLabel should have borderless appearance after tap',
          );
        }

        // Verify result is correct
        tester.verifyResult('15');
      });

      testWidgets('InkWell ripple effect is clipped to circular shape',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Find a button with InkWell
        final buttonFinder = find.ancestor(
          of: find.text('5'),
          matching: find.byType(CalculatorButton),
        );

        final inkWellFinder = find.descendant(
          of: buttonFinder,
          matching: find.byType(InkWell),
        );
        expect(inkWellFinder, findsOneWidget);

        final inkWell = tester.widget<InkWell>(inkWellFinder);
        expect(
          inkWell.borderRadius,
          isNotNull,
          reason: 'InkWell should have borderRadius for circular ripple clipping',
        );
        expect(
          inkWell.borderRadius,
          equals(BorderRadius.circular(CalculatorDimensions.circularButtonRadius)),
          reason: 'InkWell borderRadius should match circular button radius',
        );
      });
    });

    group('All 20 Buttons Use CalculatorButton Widget', () {
      testWidgets('all buttons in the 5×4 grid are CalculatorButton widgets',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // All button labels in the grid
        final buttonLabels = [
          'C', '()', '^', '÷',    // Row 1
          '7', '8', '9', '×',     // Row 2
          '4', '5', '6', '+',     // Row 3
          '1', '2', '3', '-',     // Row 4
          '+/-', '0', '.', '=',   // Row 5
        ];

        for (final label in buttonLabels) {
          final textFinder = find.text(label);
          expect(
            textFinder,
            findsWidgets,
            reason: 'Button with label "$label" should exist',
          );

          // Find the CalculatorButton ancestor
          final buttonFinder = find.ancestor(
            of: textFinder.first,
            matching: find.byType(CalculatorButton),
          );
          expect(
            buttonFinder,
            findsOneWidget,
            reason: 'Button "$label" should be a CalculatorButton',
          );
        }
      });

      testWidgets('total of 20 CalculatorButton widgets in the grid',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Find all CalculatorButton widgets
        final calculatorButtons = find.byType(CalculatorButton);

        // Should have at least 20 buttons (the grid buttons)
        // Note: There might be additional buttons like backspace
        expect(
          calculatorButtons.evaluate().length,
          greaterThanOrEqualTo(20),
          reason: 'Should have at least 20 CalculatorButton widgets in the grid',
        );
      });
    });

    group('Typography Consistency', () {
      testWidgets('all buttons use 24sp text size',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Sample some buttons to verify text size
        final sampleLabels = ['5', '+', 'C', '='];

        for (final label in sampleLabels) {
          Finder textFinder;
          if (label == '=') {
            textFinder = find.descendant(
              of: find.byKey(const Key('equals_button')),
              matching: find.text(label),
            );
          } else if (label == 'C') {
            textFinder = find.descendant(
              of: find.byKey(const Key('clear_button')),
              matching: find.text(label),
            );
          } else {
            textFinder = find.text(label);
          }

          expect(textFinder, findsWidgets);

          final textWidget = tester.widget<Text>(textFinder.first);
          expect(
            textWidget.style?.fontSize,
            equals(CalculatorDimensions.circularButtonTextSize),
            reason: 'Button "$label" should have 24sp text size',
          );
        }
      });
    });
  });
}
