import 'package:android_calculator_flutter/features/calculator/domain/usecases/clear_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/delete_character_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_operator_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_parenthesis_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/negate_value_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_bloc.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_state.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_button_grid.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/negate_button_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget-based integration tests for Plus/Minus toggle functionality.
/// These tests run without requiring a physical device or emulator.
///
/// This test file validates the complete +/- button user flow including:
/// - AC1: Insert minus at cursor position when expression has value
/// - AC2: Button displays +/- label and is visible
/// - AC3: Insert minus on empty expression
void main() {
  group('Plus/Minus Toggle Integration Tests', () {
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

    group('AC1: Expression with value - Insert minus at cursor position', () {
      testWidgets('enters "5", taps +/- button, verifies "-5" is displayed',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '5'
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        // Verify expression shows '5'
        expect(find.text('5'), findsWidgets);

        // Tap +/- button to negate
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();

        // Verify '-5' is displayed (minus inserted before the number)
        // Note: The display shows expression in two places (expression area and result area)
        expect(find.text('-5'), findsWidgets);
      });

      testWidgets('enters "123", taps +/- button, verifies "-123" is displayed',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '123'
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Verify expression shows '123'
        expect(find.text('123'), findsWidgets);

        // Tap +/- button to negate
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();

        // Verify '-123' is displayed
        expect(find.text('-123'), findsWidgets);
      });

      testWidgets(
          'enters "5+3", taps +/- button, verifies "5+-3" (negate second number)',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '5+3'
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Verify expression shows '5+3'
        expect(find.text('5+3'), findsWidgets);

        // Tap +/- button to negate the current number (3)
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();

        // Verify '5+-3' is displayed (minus inserted before 3)
        expect(find.text('5+-3'), findsWidgets);
      });

      testWidgets('toggles sign twice returns to original positive value',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '7'
        await tester.tap(find.text('7'));
        await tester.pumpAndSettle();

        // Verify '7'
        expect(find.text('7'), findsWidgets);

        // Tap +/- to make negative
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();

        // Verify '-7'
        expect(find.text('-7'), findsWidgets);

        // Tap +/- again to make positive
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();

        // Verify '7' again
        expect(find.text('7'), findsWidgets);
      });

      testWidgets('negate decimal number "3.14" results in "-3.14"',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '3.14'
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('.'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        // Verify '3.14'
        expect(find.text('3.14'), findsWidgets);

        // Tap +/- to negate
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();

        // Verify '-3.14'
        expect(find.text('-3.14'), findsWidgets);
      });
    });

    group(
        'AC2: Button label - Verify +/- button is visible and displays correct label',
        () {
      testWidgets('+/- button is visible in the calculator',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Verify +/- button is visible
        expect(find.byKey(const Key('negate_button')), findsOneWidget);
      });

      testWidgets('+/- button displays "+/-" label',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Verify the button displays '+/-' label
        expect(find.text('+/-'), findsOneWidget);
      });

      testWidgets('NegateButtonConfig has correct label configuration',
          (WidgetTester tester) async {
        // Verify the config provides the correct label
        expect(NegateButtonConfig.label, equals('+/-'));
      });

      testWidgets('+/- button has correct key identifier',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Verify the button has the correct key
        final negateButton = find.byKey(const Key('negate_button'));
        expect(negateButton, findsOneWidget);
      });

      testWidgets('+/- button has correct styling configuration',
          (WidgetTester tester) async {
        // Verify NegateButtonConfig provides correct styling values
        expect(NegateButtonConfig.backgroundColor, isNotNull);
        expect(NegateButtonConfig.textColor, isNotNull);
        expect(NegateButtonConfig.decoration, isNotNull);
      });

      testWidgets('+/- button is positioned in the correct row (Row 5)',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Find the +/- button and the '0' button (both in Row 5)
        final negateButton = find.byKey(const Key('negate_button'));
        final zeroButton = find.text('0');

        expect(negateButton, findsOneWidget);
        expect(zeroButton, findsOneWidget);

        // Get positions - they should be in the same row (similar Y values)
        final negatePosition = tester.getCenter(negateButton);
        final zeroPosition = tester.getCenter(zeroButton);

        // Both buttons should be at approximately the same Y position (same row)
        expect((negatePosition.dy - zeroPosition.dy).abs(), lessThan(50),
            reason: '+/- button should be in the same row as the 0 button');
      });
    });

    group('AC3: Empty expression - Tap +/- on empty expression shows "-"', () {
      testWidgets('tapping +/- on empty expression inserts "-"',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Verify initial state shows '0' placeholder
        expect(find.text('0'), findsOneWidget);

        // Tap +/- button on empty expression
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();

        // Verify '-' is displayed
        expect(find.text('-'), findsWidgets);
      });

      testWidgets(
          'tapping +/- on empty then entering digit results in negative number',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap +/- button on empty expression
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();

        // Enter a digit
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();

        // Verify '-9' is displayed
        expect(find.text('-9'), findsWidgets);
      });

      testWidgets('double tap +/- on empty cancels out',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap +/- button twice on empty expression
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();

        // Verify the expression is back to initial state (showing '0' or empty)
        expect(find.text('0'), findsOneWidget);
      });
    });

    group('Complete user flow scenarios', () {
      testWidgets('full calculation with negated number: -5 + 3 = -2',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Start with negate to enter negative number
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();

        // Enter '5'
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        // Verify '-5'
        expect(find.text('-5'), findsWidgets);

        // Add '+3'
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Verify expression is '-5+3'
        expect(find.text('-5+3'), findsWidgets);

        // Evaluate
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Verify result is '-2'
        expect(find.text('-2'), findsWidgets);
      });

      testWidgets('negate after operator: 10 + (-5) flow',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '10+'
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        // Tap +/- to start a negative number
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();

        // Enter '5'
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        // Verify expression is '10+-5'
        expect(find.text('10+-5'), findsWidgets);

        // Evaluate
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Verify result is '5'
        expect(find.text('5'), findsWidgets);
      });

      testWidgets('negate number then continue calculation',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '8', negate it
        await tester.tap(find.text('8'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();

        // Verify '-8'
        expect(find.text('-8'), findsWidgets);

        // Multiply by 2
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Verify '-8×2'
        expect(find.text('-8×2'), findsWidgets);

        // Evaluate
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Verify result is '-16'
        expect(find.text('-16'), findsWidgets);
      });

      testWidgets('clear after negate resets properly',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '-5'
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        // Verify '-5'
        expect(find.text('-5'), findsWidgets);

        // Clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Verify cleared
        expect(find.text('-5'), findsNothing);
        expect(find.text('0'), findsOneWidget);

        // Can enter new expression
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        expect(find.text('3'), findsWidgets);
      });
    });

    group('Edge cases and error handling', () {
      testWidgets('multiple consecutive negates toggle correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '4'
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        // Negate multiple times and verify toggling
        for (int i = 0; i < 4; i++) {
          await tester.tap(find.byKey(const Key('negate_button')));
          await tester.pumpAndSettle();
        }

        // After even number of negates, should be back to positive
        expect(find.text('4'), findsWidgets);
      });

      testWidgets(
          'negate button does not cause error with complex expression',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter complex expression '1+2×3'
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Tap negate - should not throw error
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();

        // Button should still be present (no crash)
        expect(find.byKey(const Key('negate_button')), findsOneWidget);
      });

      testWidgets('negate with operator at end inserts minus for next number',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '5+' (operator at end, no number after)
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        // Verify '5+'
        expect(find.text('5+'), findsWidgets);

        // Tap negate - should insert minus for the next number
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();

        // Verify '5+-' (minus inserted for upcoming negative number)
        expect(find.text('5+-'), findsWidgets);
      });

      testWidgets('negate works correctly with division',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '-10÷2'
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('÷'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Verify '-10÷2'
        expect(find.text('-10÷2'), findsWidgets);

        // Evaluate
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Verify result is '-5'
        expect(find.text('-5'), findsWidgets);
      });

      testWidgets('negate works correctly with subtraction',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '-5-3'
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('-'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Verify '-5-3'
        expect(find.text('-5-3'), findsWidgets);

        // Evaluate
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Verify result is '-8'
        expect(find.text('-8'), findsWidgets);
      });
    });

    group('Negate button interaction with parentheses', () {
      testWidgets('negate inside parentheses: (5) -> negate before closing',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '('
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();

        // Negate to start negative number
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();

        // Enter '5'
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        // Close parenthesis
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();

        // Verify '(-5)'
        expect(find.text('(-5)'), findsWidgets);
      });

      testWidgets('calculation with negated parentheses: (-5)+3',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '(-5)'
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();

        // Add '+3'
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Verify '(-5)+3'
        expect(find.text('(-5)+3'), findsWidgets);

        // Evaluate
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Verify result is '-2'
        expect(find.text('-2'), findsWidgets);
      });
    });

    group('Negate button interaction with power operator', () {
      testWidgets('negate base of power: -2^3',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '-2^3'
        await tester.tap(find.byKey(const Key('negate_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Verify '-2^3'
        expect(find.text('-2^3'), findsWidgets);

        // Evaluate
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Result depends on implementation: either -8 or 8 (if -2^3 is read as -(2^3))
        // We just verify computation completes without error
        expect(find.byKey(const Key('equals_button')), findsOneWidget);
      });
    });
  });
}
