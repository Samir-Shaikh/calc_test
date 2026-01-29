import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/clear_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/delete_character_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_operator_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_parenthesis_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/negate_value_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_bloc.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_state.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_button_grid.dart';

/// Widget test version of the integration tests for Invalid Input Error Flow.
/// 
/// These tests verify the complete user journey for invalid expressions without
/// requiring a device/emulator, making them suitable for CI/CD pipelines.
/// 
/// Acceptance Criteria verified:
/// - AC1: Expression "2++3" shows "Invalid Input" toast (verified via BLoC error state)
/// - AC2: Expression "2*/3" shows "Invalid Input" toast (verified via BLoC error state)
/// - AC3: Result display remains unchanged after error
/// - AC4: Application stability - no crash on invalid expressions
/// 
/// Note: Toast display is verified via BLoC state emissions (isEvaluationError, evaluationError).
/// The CalculatorScreen uses BlocListener to show toasts when these states are emitted.
/// This is covered by separate widget tests in calculator_screen_test.dart.
void main() {
  late ExpressionDisplayBloc bloc;
  late InsertParenthesisUseCase insertParenthesisUseCase;
  late InsertOperatorUseCase insertOperatorUseCase;
  late EvaluateExpressionUseCase evaluateExpressionUseCase;
  late ClearExpressionUseCase clearExpressionUseCase;
  late DeleteCharacterUseCase deleteCharacterUseCase;
  late NegateValueUseCase negateValueUseCase;

  setUp(() {
    insertParenthesisUseCase = InsertParenthesisUseCase();
    insertOperatorUseCase = InsertOperatorUseCase();
    evaluateExpressionUseCase = EvaluateExpressionUseCase();
    clearExpressionUseCase = ClearExpressionUseCase();
    deleteCharacterUseCase = DeleteCharacterUseCase();
    negateValueUseCase = NegateValueUseCase();
    bloc = ExpressionDisplayBloc(
      insertParenthesisUseCase: insertParenthesisUseCase,
      insertOperatorUseCase: insertOperatorUseCase,
      evaluateExpressionUseCase: evaluateExpressionUseCase,
      clearExpressionUseCase: clearExpressionUseCase,
      deleteCharacterUseCase: deleteCharacterUseCase,
      negateValueUseCase: negateValueUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  Widget createCalculatorWidget() {
    return MaterialApp(
      home: BlocProvider<ExpressionDisplayBloc>.value(
        value: bloc,
        child: Scaffold(
          body: Column(
            children: [
              // Display area
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
                            key: const Key('result_display'),
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

  group('Invalid Input Error Flow - Integration Tests', () {
    group('AC1: Expression "2++3" triggers "Invalid Input" error state', () {
      testWidgets('tapping 2, +, +, 3, = triggers error state with Invalid Input message',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorWidget());
        await tester.pumpAndSettle();

        // Tap: 2
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap: +
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        // Tap: + (second plus - creates consecutive operators)
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        // Tap: 3
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Verify expression is 2++3
        expect(bloc.state.expression.value, equals('2++3'),
            reason: 'Expression should allow consecutive operators to be entered');

        // Tap: =
        await tester.tap(find.text('='));
        await tester.pump();

        // Verify error state is triggered (this triggers toast via BlocListener)
        expect(bloc.state.isEvaluationError, isTrue,
            reason: 'AC1: BLoC should emit evaluation error state for expression 2++3');
        expect(bloc.state.evaluationError, equals('Invalid Input'),
            reason: 'AC1: Error message should be "Invalid Input"');
        expect(bloc.state.showError, isTrue,
            reason: 'AC1: showError flag should be true to trigger toast display');
      });

      testWidgets('consecutive plus operators after number triggers error state',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorWidget());
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

        // Verify error state (AC1)
        expect(bloc.state.isEvaluationError, isTrue,
            reason: 'AC1: Consecutive operators should trigger error state');
        expect(bloc.state.evaluationError, equals('Invalid Input'));
      });
    });

    group('AC2: Expression "2*/3" triggers "Invalid Input" error state', () {
      testWidgets('tapping 2, ×, ÷, 3, = triggers error state with Invalid Input message',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorWidget());
        await tester.pumpAndSettle();

        // Tap: 2
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap: × (multiplication)
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();

        // Tap: ÷ (division - creates consecutive operators)
        await tester.tap(find.text('÷'));
        await tester.pumpAndSettle();

        // Tap: 3
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Verify expression has consecutive operators (2×÷3 is equivalent to 2*/3)
        expect(bloc.state.expression.value, equals('2×÷3'),
            reason: 'Expression should have consecutive operators');

        // Tap: =
        await tester.tap(find.text('='));
        await tester.pump();

        // Verify error state is triggered (AC2)
        expect(bloc.state.isEvaluationError, isTrue,
            reason: 'AC2: BLoC should emit evaluation error state for expression 2×÷3');
        expect(bloc.state.evaluationError, equals('Invalid Input'),
            reason: 'AC2: Error message should be "Invalid Input"');
      });

      testWidgets('mixed consecutive operators (÷×) triggers error state',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorWidget());
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

        // Verify error state (AC2)
        expect(bloc.state.isEvaluationError, isTrue,
            reason: 'AC2: Mixed consecutive operators should trigger error');
        expect(bloc.state.evaluationError, equals('Invalid Input'));
      });

      testWidgets('multiplication followed by plus operators triggers error',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorWidget());
        await tester.pumpAndSettle();

        // Enter: 3 × + 2 =
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

        // Verify error state (AC2)
        expect(bloc.state.isEvaluationError, isTrue,
            reason: 'AC2: Consecutive operators ×+ should trigger error');
      });
    });

    group('AC3: Result display unchanged on error', () {
      testWidgets('after valid calculation 5+5=10, invalid 2++3 preserves result state',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorWidget());
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
        expect(bloc.state.result, equals('10'),
            reason: 'Valid expression 5+5 should produce result 10');

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

        // Verify error state
        expect(bloc.state.isEvaluationError, isTrue,
            reason: 'AC3: Invalid expression should trigger error state');

        // AC3: Result should be preserved (null after clear, not corrupted to an error value)
        expect(bloc.state.result, isNull,
            reason: 'AC3: Result should remain null (preserved state before error)');
        
        // Verify no garbage values are shown
        expect(bloc.state.result, isNot(equals('NaN')));
        expect(bloc.state.result, isNot(equals('Error')));
      });

      testWidgets('invalid expression does not corrupt display',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorWidget());
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
        expect(bloc.state.result, equals('24'));

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

        // Verify error handling (AC3)
        expect(bloc.state.isEvaluationError, isTrue);

        // App should remain stable
        await tester.pumpAndSettle();
        
        // Expression should still be shown, not corrupted
        expect(bloc.state.expression.value, equals('7+'));
      });

      testWidgets('result display shows expression on error, not garbage value',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorWidget());
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

        // Verify error state (AC3)
        expect(bloc.state.isEvaluationError, isTrue);

        // The display should not show an error value like NaN or undefined
        expect(find.text('NaN'), findsNothing,
            reason: 'AC3: Display should not show NaN');
        expect(find.text('undefined'), findsNothing,
            reason: 'AC3: Display should not show undefined');
        expect(find.text('null'), findsNothing,
            reason: 'AC3: Display should not show null');
      });
    });

    group('AC4: Application stability', () {
      testWidgets('multiple invalid expressions in sequence - app remains responsive',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorWidget());
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

        expect(bloc.state.isEvaluationError, isTrue,
            reason: 'AC4: First invalid expression should trigger error');

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

        expect(bloc.state.isEvaluationError, isTrue,
            reason: 'AC4: Second invalid expression should trigger error');

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

        expect(bloc.state.isEvaluationError, isTrue,
            reason: 'AC4: Third invalid expression should trigger error');

        // Clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Now verify app is still responsive with valid calculation (AC4)
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('6'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify valid result after multiple errors (AC4)
        expect(bloc.state.result, equals('10'),
            reason: 'AC4: App should compute valid result after multiple errors');
        expect(bloc.state.isEvaluationError, isFalse,
            reason: 'AC4: No error state for valid expression');
      });

      testWidgets('rapid invalid operations do not crash the app',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorWidget());
        await tester.pumpAndSettle();

        // Rapidly tap multiple operators (AC4 - stress test)
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.text('+'));
          await tester.pump(const Duration(milliseconds: 50));
        }

        await tester.tap(find.text('='));
        await tester.pump();
        await tester.pumpAndSettle();

        // App should still be responsive (AC4)
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Verify app is still functional
        await tester.tap(find.text('7'));
        await tester.pumpAndSettle();

        expect(bloc.state.expression.value, equals('7'),
            reason: 'AC4: App should respond to input after rapid invalid operations');
      });

      testWidgets('valid calculations work correctly after error recovery',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorWidget());
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

        expect(bloc.state.isEvaluationError, isTrue);

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

        // Verify result is correct (AC4)
        expect(bloc.state.result, equals('20'),
            reason: 'AC4: Complex expression should evaluate correctly after error recovery');
        expect(bloc.state.isEvaluationError, isFalse);
      });

      testWidgets('alternating valid and invalid expressions maintains stability',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorWidget());
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
        expect(bloc.state.result, equals('5'),
            reason: 'AC4: First valid expression should work');

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

        expect(bloc.state.isEvaluationError, isTrue,
            reason: 'AC4: Invalid expression should trigger error');

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
        expect(bloc.state.result, equals('42'),
            reason: 'AC4: Second valid expression should work after error');

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

        expect(bloc.state.isEvaluationError, isTrue,
            reason: 'AC4: Empty parentheses should trigger error');

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
        expect(bloc.state.result, equals('5'),
            reason: 'AC4: Third valid expression should work after multiple errors');
      });
    });

    group('Additional error scenarios', () {
      testWidgets('expression starting with multiplication operator shows error',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorWidget());
        await tester.pumpAndSettle();

        // Enter: × 5 =
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pump();

        // Verify error state
        expect(bloc.state.isEvaluationError, isTrue,
            reason: 'Expression starting with × should trigger error');
      });

      testWidgets('expression ending with operator shows error',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorWidget());
        await tester.pumpAndSettle();

        // Enter: 5 + (without operand)
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pump();

        // Verify error state
        expect(bloc.state.isEvaluationError, isTrue,
            reason: 'Expression ending with operator should trigger error');
      });

      testWidgets('deeply nested unbalanced parentheses shows error',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorWidget());
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

        // Verify error state
        expect(bloc.state.isEvaluationError, isTrue,
            reason: 'Unbalanced parentheses should trigger error');
      });
    });
  });
}
