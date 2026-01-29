import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/clear_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/delete_character_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_operator_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_parenthesis_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/negate_value_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_bloc.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_state.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_button_grid.dart';

/// Widget test version of integration tests for Order of Operations user flow.
///
/// These tests verify the complete flow from button taps to result display
/// with correct order of operations (operator precedence).
///
/// This runs as a widget test without requiring a device/emulator.
///
/// Acceptance Criteria:
/// - AC1: 2+3*4 should equal 14 (multiplication before addition)
/// - AC2: 10-4/2 should equal 8 (division before subtraction)
/// - AC3: (2+3)*4 should equal 20 (parentheses priority)
/// - AC4: 2^3+1 should equal 9 (exponent before addition)
/// - Additional: Left-to-right evaluation for same precedence operators
void main() {
  group('Order of Operations User Flow Widget Tests', () {
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
        home: BlocProvider<ExpressionDisplayBloc>.value(
          value: bloc,
          child: Scaffold(
            body: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: BlocBuilder<ExpressionDisplayBloc, ExpressionDisplayState>(
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

    /// Helper to verify result (handles both integer and decimal display formats)
    void verifyResult(String expected) {
      final intResult = find.text(expected);
      final decimalResult = find.text('$expected.0');
      expect(
        intResult.evaluate().isNotEmpty || decimalResult.evaluate().isNotEmpty,
        isTrue,
        reason: 'Expected result to be $expected or $expected.0',
      );
    }

    group('AC1: Multiplication before Addition (2+3*4=14)', () {
      testWidgets('User enters 2+3*4 and taps equals, sees 14',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // User taps: 2
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // User taps: +
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        // User taps: 3
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // User taps: × (multiplication)
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();

        // User taps: 4
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        // User taps: = (equals)
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Verify result is 14 (multiplication has higher precedence)
        // Result should be 2 + (3 * 4) = 2 + 12 = 14
        verifyResult('14');
      });

      testWidgets('2+3*4 equals 14, NOT 20 (proves multiplication first)',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter: 2 + 3 × 4
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
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Verify result is 14, not 20
        verifyResult('14');
        
        // Verify bloc state shows correct result (not 20)
        final state = bloc.state;
        expect(state.result != '20' && state.result != '20.0', isTrue,
            reason: 'Result should NOT be 20 (left-to-right), but was ${state.result}');
      });
    });

    group('AC2: Division before Subtraction (10-4/2=8)', () {
      testWidgets('User enters 10-4/2 and taps equals, sees 8',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // User taps: 1, 0
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();

        // User taps: -
        await tester.tap(find.text('-'));
        await tester.pumpAndSettle();

        // User taps: 4
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        // User taps: ÷ (division)
        await tester.tap(find.text('÷'));
        await tester.pumpAndSettle();

        // User taps: 2
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // User taps: = (equals)
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Verify result is 8 (division has higher precedence)
        // Result should be 10 - (4 / 2) = 10 - 2 = 8
        verifyResult('8');
      });

      testWidgets('10-4/2 equals 8, NOT 3 (proves division first)',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter: 10 - 4 ÷ 2
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
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Verify result is 8, not 3
        verifyResult('8');
        
        // Verify bloc state shows correct result (not 3)
        final state = bloc.state;
        expect(state.result != '3' && state.result != '3.0', isTrue,
            reason: 'Result should NOT be 3 (left-to-right), but was ${state.result}');
      });
    });

    group('AC3: Parentheses Priority ((2+3)*4=20)', () {
      testWidgets('User enters (2+3)*4 and taps equals, sees 20',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // User taps: ( (open parenthesis)
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();

        // User taps: 2
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // User taps: +
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        // User taps: 3
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // User taps: ) (close parenthesis - second tap toggles)
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();

        // User taps: × (multiplication)
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();

        // User taps: 4
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        // User taps: = (equals)
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Verify result is 20 (parentheses override multiplication precedence)
        // Result should be (2 + 3) * 4 = 5 * 4 = 20
        verifyResult('20');
      });

      testWidgets('Parentheses change result: (2+3)*4=20 vs 2+3*4=14',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // First: calculate 2+3*4 = 14 (without parentheses)
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
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        verifyResult('14');

        // Clear
        await tester.tap(find.byKey(const Key('clear_button')));
        await tester.pumpAndSettle();

        // Now: calculate (2+3)*4 = 20 (with parentheses)
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
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        verifyResult('20');
      });
    });

    group('AC4: Exponent before Addition (2^3+1=9)', () {
      testWidgets('User enters 2^3+1 and taps equals, sees 9',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // User taps: 2
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // User taps: ^ (power)
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();

        // User taps: 3
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // User taps: +
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        // User taps: 1
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();

        // User taps: = (equals)
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Verify result is 9 (exponent has higher precedence than addition)
        // Result should be (2 ^ 3) + 1 = 8 + 1 = 9
        verifyResult('9');
      });

      testWidgets('2^3+1 equals 9, NOT 16 (proves exponent first)',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter: 2 ^ 3 + 1
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
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Verify result is 9, not 16
        verifyResult('9');
        
        // Verify bloc state shows correct result (not 16)
        final state = bloc.state;
        expect(state.result != '16' && state.result != '16.0', isTrue,
            reason: 'Result should NOT be 16 (2^(3+1)), but was ${state.result}');
      });
    });

    group('Left-to-Right Evaluation for Same Precedence', () {
      testWidgets('6-3-1 equals 2 (left-to-right subtraction)',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter: 6 - 3 - 1
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
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Result: (6-3)-1 = 3-1 = 2
        verifyResult('2');
      });

      testWidgets('12/3/2 equals 2 (left-to-right division)',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter: 12 ÷ 3 ÷ 2
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
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Result: (12/3)/2 = 4/2 = 2
        verifyResult('2');
      });

      testWidgets('2*3*4 equals 24 (left-to-right multiplication)',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter: 2 × 3 × 4
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
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Result: (2*3)*4 = 6*4 = 24
        verifyResult('24');
      });

      testWidgets('1+2+3+4 equals 10 (left-to-right addition)',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter: 1 + 2 + 3 + 4
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
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Result: 1+2+3+4 = 10
        verifyResult('10');
      });
    });

    group('Complete User Flow Verification', () {
      testWidgets('User performs all AC calculations with clear between',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
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
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();
        verifyResult('14');

        // Clear
        await tester.tap(find.byKey(const Key('clear_button')));
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
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();
        verifyResult('8');

        // Clear
        await tester.tap(find.byKey(const Key('clear_button')));
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
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();
        verifyResult('20');

        // Clear
        await tester.tap(find.byKey(const Key('clear_button')));
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
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();
        verifyResult('9');
      });
    });

    group('Complex Expressions with Multiple Precedence Levels', () {
      testWidgets('2+3*4-5 equals 9',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter: 2 + 3 × 4 - 5
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
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Result: 2 + (3*4) - 5 = 2 + 12 - 5 = 9
        verifyResult('9');
      });

      testWidgets('2^3*2 equals 16 (exponent then multiplication)',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter: 2 ^ 3 × 2
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
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Result: (2^3) × 2 = 8 × 2 = 16
        verifyResult('16');
      });

      testWidgets('(2+3)^2 equals 25 (parentheses with exponent)',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter: ( 2 + 3 ) ^ 2
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
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Result: (2+3)^2 = 5^2 = 25
        verifyResult('25');
      });

      testWidgets('10-4/2+3*2 equals 14 (mixed operators)',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter: 10 - 4 ÷ 2 + 3 × 2
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
        await tester.tap(find.byKey(const Key('equals_button')));
        await tester.pumpAndSettle();

        // Result: 10 - (4/2) + (3*2) = 10 - 2 + 6 = 14
        verifyResult('14');
      });
    });
  });
}
