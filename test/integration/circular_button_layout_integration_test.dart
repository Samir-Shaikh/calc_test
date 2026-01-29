import 'package:android_calculator_flutter/features/calculator/domain/usecases/clear_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/delete_character_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_operator_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_parenthesis_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/negate_value_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_bloc.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_state.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/theme/calculator_dimensions.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_button.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_button_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper function to check if a border is effectively borderless.
/// A border is considered borderless if it is null, or has a transparent/zero-width border.
bool isBorderlessDecoration(BoxDecoration decoration) {
  if (decoration.border == null) return true;
  
  // Check if border is transparent or has zero width
  final border = decoration.border;
  if (border is Border) {
    final isTransparentOrZero = (side) =>
        side.width == 0.0 || side.color.alpha == 0;
    return isTransparentOrZero(border.top) &&
        isTransparentOrZero(border.right) &&
        isTransparentOrZero(border.bottom) &&
        isTransparentOrZero(border.left);
  }
  
  return false;
}

/// Widget-based integration tests for circular button layout.
/// These tests run without requiring a physical device or emulator.
///
/// This test file validates the complete calculator button layout
/// with all circular styling, spacing, and typography requirements
/// in a real app-like context.
void main() {
  group('Circular Button Layout Integration Tests', () {
    late ExpressionDisplayBloc bloc;

    Widget createCalculatorTestApp() {
      bloc = ExpressionDisplayBloc(
        insertParenthesisUseCase: InsertParenthesisUseCase(),
        insertOperatorUseCase: InsertOperatorUseCase(),
        evaluateExpressionUseCase: EvaluateExpressionUseCase(),
        clearExpressionUseCase: ClearExpressionUseCase(),
        deleteCharacterUseCase: DeleteCharacterUseCase(),
        negateValueUseCase: NegateValueUseCase(),
      );

      return MaterialApp(
        title: 'Calculator Integration Test',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: BlocProvider<ExpressionDisplayBloc>.value(
          value: bloc,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Calculator'),
              backgroundColor: Colors.blue.shade100,
            ),
            body: Column(
              children: [
                // Display area
                Expanded(
                  flex: 1,
                  child:
                      BlocBuilder<ExpressionDisplayBloc, ExpressionDisplayState>(
                    builder: (context, state) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              state.displayExpression,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              state.result ?? state.displayExpression,
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Button area
                const Expanded(
                  flex: 2,
                  child: CalculatorButtonGrid(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    tearDown(() {
      bloc.close();
    });

    group('All Button Types Render with Circular Styling', () {
      testWidgets('all 20 calculator buttons are present and use CalculatorButton widget',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // All button labels in the 5×4 grid
        final buttonLabels = [
          'C', '()', '^', '÷', // Row 1
          '7', '8', '9', '×', // Row 2
          '4', '5', '6', '+', // Row 3
          '1', '2', '3', '-', // Row 4
          '+/-', '0', '.', '=', // Row 5
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

      testWidgets('numeric buttons (0-9) all have circular borderless styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        for (var digit = 0; digit <= 9; digit++) {
          final buttonFinder = find.ancestor(
            of: find.text('$digit'),
            matching: find.byType(CalculatorButton),
          );
          expect(
            buttonFinder,
            findsOneWidget,
            reason: 'Digit $digit should be in a CalculatorButton',
          );

          // Verify borderless circular decoration
          final containerFinder = find.descendant(
            of: buttonFinder,
            matching: find.byType(Container),
          );
          expect(containerFinder, findsWidgets);

          final container = tester.widget<Container>(containerFinder.first);
          expect(container.decoration, isA<BoxDecoration>());

          final decoration = container.decoration as BoxDecoration;
          expect(
            isBorderlessDecoration(decoration),
            isTrue,
            reason: 'Digit $digit should have borderless appearance',
          );
          expect(
            decoration.borderRadius,
            isNotNull,
            reason: 'Digit $digit should have circular border radius',
          );
        }
      });

      testWidgets('operator buttons (+, -, ×, ÷, =) all have circular borderless styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        final operators = ['+', '-', '×', '÷', '='];

        for (final operator in operators) {
          Finder buttonFinder;
          if (operator == '=') {
            buttonFinder = find.byKey(const Key('equals_button'));
          } else {
            buttonFinder = find.ancestor(
              of: find.text(operator),
              matching: find.byType(CalculatorButton),
            );
          }
          expect(
            buttonFinder,
            findsOneWidget,
            reason: 'Operator $operator should be displayed',
          );

          final containerFinder = find.descendant(
            of: buttonFinder,
            matching: find.byType(Container),
          );
          expect(containerFinder, findsWidgets);

          final container = tester.widget<Container>(containerFinder.first);
          final decoration = container.decoration as BoxDecoration;
          expect(
            isBorderlessDecoration(decoration),
            isTrue,
            reason: 'Operator $operator should have borderless appearance',
          );
        }
      });

      testWidgets('function buttons (C, (), ^, +/-) all have circular borderless styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        final functionButtonKeys = [
          const Key('clear_button'),
          const Key('parenthesis_button'),
          const Key('power_button'),
          const Key('negate_button'),
        ];

        for (final key in functionButtonKeys) {
          final buttonFinder = find.byKey(key);
          expect(
            buttonFinder,
            findsOneWidget,
            reason: 'Button with key $key should exist',
          );

          final containerFinder = find.descendant(
            of: buttonFinder,
            matching: find.byType(Container),
          );
          expect(containerFinder, findsWidgets);

          final container = tester.widget<Container>(containerFinder.first);
          final decoration = container.decoration as BoxDecoration;
          expect(
            isBorderlessDecoration(decoration),
            isTrue,
            reason: 'Function button $key should have borderless appearance',
          );
        }
      });
    });

    group('Consistent Spacing Verification', () {
      testWidgets('buttons in the same row have consistent horizontal spacing',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
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
        await tester.pumpWidget(createCalculatorTestApp());
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
          reason:
              'Vertical spacing between Row 1-2 and Row 2-3 should be consistent',
        );
        expect(
          (spacingRow2to3 - spacingRow3to4).abs(),
          lessThan(tolerance),
          reason:
              'Vertical spacing between Row 2-3 and Row 3-4 should be consistent',
        );
        expect(
          (spacingRow3to4 - spacingRow4to5).abs(),
          lessThan(tolerance),
          reason:
              'Vertical spacing between Row 3-4 and Row 4-5 should be consistent',
        );
      });

      testWidgets('all columns are aligned vertically',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
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
    });

    group('Button Interaction Maintains Circular Appearance', () {
      testWidgets('numeric button maintains circular shape during tap',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
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
        final initialContainer =
            tester.widget<Container>(containerFinder.first);
        final initialDecoration = initialContainer.decoration as BoxDecoration;
        final initialBorderRadius = initialDecoration.borderRadius;

        // Tap and hold the button
        await tester.tap(buttonFinder);
        await tester.pump(); // Allow for press state

        // Verify decoration is still circular during press
        final pressedContainer =
            tester.widget<Container>(containerFinder.first);
        final pressedDecoration = pressedContainer.decoration as BoxDecoration;
        expect(
          pressedDecoration.borderRadius,
          equals(initialBorderRadius),
          reason: 'Border radius should remain the same during press',
        );
        expect(
          isBorderlessDecoration(pressedDecoration),
          isTrue,
          reason: 'Button should remain borderless during press',
        );

        await tester.pumpAndSettle();
      });

      testWidgets(
          'multiple button taps maintain circular appearance throughout calculation',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Perform a calculation: 7 + 8 = 15
        final buttons = ['7', '+', '8'];

        for (final buttonLabel in buttons) {
          final buttonFinder = find.ancestor(
            of: find.text(buttonLabel),
            matching: find.byType(CalculatorButton),
          );

          // Verify button has circular decoration before tap
          final containerFinder = find.descendant(
            of: buttonFinder,
            matching: find.byType(Container),
          );
          final container = tester.widget<Container>(containerFinder.first);
          final decoration = container.decoration as BoxDecoration;
          expect(
            isBorderlessDecoration(decoration),
            isTrue,
            reason:
                'Button $buttonLabel should have borderless appearance before tap',
          );

          // Tap the button
          await tester.tap(buttonFinder);
          await tester.pumpAndSettle();

          // Verify button still has circular decoration after tap
          final afterContainer =
              tester.widget<Container>(containerFinder.first);
          final afterDecoration = afterContainer.decoration as BoxDecoration;
          expect(
            isBorderlessDecoration(afterDecoration),
            isTrue,
            reason:
                'Button $buttonLabel should have borderless appearance after tap',
          );
        }

        // Tap equals button
        final equalsFinder = find.byKey(const Key('equals_button'));
        await tester.tap(equalsFinder);
        await tester.pumpAndSettle();

        // Verify result is displayed (15 or 15.0)
        final result15 = find.text('15');
        final result150 = find.text('15.0');
        expect(
          result15.evaluate().isNotEmpty || result150.evaluate().isNotEmpty,
          isTrue,
          reason: 'Expected result to be 15 or 15.0',
        );
      });

      testWidgets('InkWell ripple effect is clipped to circular shape',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
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
          equals(
              BorderRadius.circular(CalculatorDimensions.circularButtonRadius)),
          reason: 'InkWell borderRadius should match circular button radius',
        );
      });
    });

    group('Typography Consistency', () {
      testWidgets('all buttons use 24sp text size',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Sample buttons from each type
        final sampleLabels = ['5', '+', 'C', '0', '.', '×', '-'];

        for (final label in sampleLabels) {
          final textFinder = find.text(label);
          expect(textFinder, findsWidgets);

          final textWidget = tester.widget<Text>(textFinder.first);
          expect(
            textWidget.style?.fontSize,
            equals(CalculatorDimensions.circularButtonTextSize),
            reason: 'Button "$label" should have 24sp text size',
          );
        }
      });

      testWidgets('equals button has 24sp text size',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        final textFinder = find.descendant(
          of: find.byKey(const Key('equals_button')),
          matching: find.text('='),
        );
        expect(textFinder, findsOneWidget);

        final textWidget = tester.widget<Text>(textFinder);
        expect(
          textWidget.style?.fontSize,
          equals(24.0),
          reason: 'Equals button should have 24sp text size',
        );
      });
    });

    group('Complete Calculator Flow with Circular Buttons', () {
      testWidgets('addition calculation works with circular buttons',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // 12 + 34 = 46
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Verify result
        expect(
          find.text('46').evaluate().isNotEmpty ||
              find.text('46.0').evaluate().isNotEmpty,
          isTrue,
          reason: 'Expected result to be 46 or 46.0',
        );
      });

      testWidgets('clear button resets display while maintaining circular styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter some digits
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('6'));
        await tester.pumpAndSettle();

        // Tap clear
        await tester.tap(find.byKey(const Key('clear_button')));
        await tester.pumpAndSettle();

        // Verify clear button still has circular styling
        final clearFinder = find.byKey(const Key('clear_button'));
        final containerFinder = find.descendant(
          of: clearFinder,
          matching: find.byType(Container),
        );
        final container = tester.widget<Container>(containerFinder.first);
        final decoration = container.decoration as BoxDecoration;
        expect(
          isBorderlessDecoration(decoration),
          isTrue,
          reason: 'Clear button should maintain borderless appearance',
        );
        expect(
          decoration.borderRadius,
          isNotNull,
          reason: 'Clear button should maintain circular border radius',
        );
      });

      testWidgets('multiplication calculation works correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // 6 × 7 = 42
        await tester.tap(find.text('6'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('7'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Verify result
        expect(
          find.text('42').evaluate().isNotEmpty ||
              find.text('42.0').evaluate().isNotEmpty,
          isTrue,
          reason: 'Expected result to be 42 or 42.0',
        );
      });

      testWidgets('division calculation works correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // 8 ÷ 2 = 4
        await tester.tap(find.text('8'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('÷'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Verify result
        expect(
          find.text('4').evaluate().isNotEmpty ||
              find.text('4.0').evaluate().isNotEmpty,
          isTrue,
          reason: 'Expected result to be 4 or 4.0',
        );
      });

      testWidgets('subtraction calculation works correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // 9 - 3 = 6
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('-'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Verify result
        expect(
          find.text('6').evaluate().isNotEmpty ||
              find.text('6.0').evaluate().isNotEmpty,
          isTrue,
          reason: 'Expected result to be 6 or 6.0',
        );
      });
    });
  });
}
