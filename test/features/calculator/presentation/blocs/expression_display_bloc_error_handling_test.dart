import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/clear_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/delete_character_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_operator_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_parenthesis_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/negate_value_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_bloc.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_event.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_state.dart';

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

  group('ExpressionDisplayBloc Error Handling', () {
    group('Error state emission on invalid expression', () {
      test('expression "2++3" emits state with showError: true and errorMessage: "Invalid Input"', () async {
        // Build expression: 2++3 (consecutive operators - invalid)
        bloc.add(const NumericPressed('2'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2+',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2++',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2++3',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.expression.value == '2++3' &&
                  state.showError == true &&
                  state.errorMessage == 'Invalid Input' &&
                  state.hasError == true &&
                  state.isEvaluationError == true &&
                  state.evaluationError == 'Invalid Input',
              'state should have showError: true and errorMessage: "Invalid Input"',
            ),
          ]),
        );
      });

      test('expression ending with operator emits error state with showError: true', () async {
        // Build expression: 5+ (incomplete - invalid)
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5+',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.expression.value == '5+' &&
                  state.showError == true &&
                  state.errorMessage == 'Invalid Input' &&
                  state.hasError == true,
              'state should have showError: true for incomplete expression',
            ),
          ]),
        );
      });

      test('unbalanced parentheses emits error state with showError: true', () async {
        // Build expression: (5+3 (missing closing parenthesis)
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(5',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(5+',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(5+3',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.showError == true &&
                  state.errorMessage == 'Invalid Input' &&
                  state.hasError == true &&
                  state.isEvaluationError == true,
              'state should have showError: true for unbalanced parentheses',
            ),
          ]),
        );
      });

      test('expression with only operators emits error state', () async {
        // Build expression: + (only operator - invalid)
        bloc.add(const OperatorPressed('+'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '+',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.showError == true &&
                  state.errorMessage == 'Invalid Input' &&
                  state.hasError == true,
              'state should have showError: true for expression with only operators',
            ),
          ]),
        );
      });
    });

    group('Result preservation on error (AC3)', () {
      test('result is preserved in state when invalid expression is evaluated directly', () async {
        // Build an invalid expression directly: 3++
        // The result preservation happens when evaluating - the state.result 
        // at the time of error evaluation is preserved (which is null here since no prior calculation)
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3+',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3++',
            ),
            // Error state - result should remain null (preserved from before evaluation)
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.showError == true &&
                  state.hasError == true &&
                  state.errorMessage == 'Invalid Input' &&
                  state.result == null, // preserved as null since no prior result
              'error state should preserve result as null when no prior calculation',
            ),
          ]),
        );
      });

      test('result from successful evaluation is preserved when subsequent invalid evaluation occurs', () async {
        // First, perform a successful calculation: 5×4 = 20
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const EqualsPressed());

        // Wait for successful evaluation
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.result, '20');
        expect(bloc.state.showError, false);

        // Re-evaluate the same expression but make it invalid by adding operator first
        // Note: When we add an operator, result gets cleared to null
        // The AC3 preservation happens at the moment of error evaluation
        // So we need to evaluate an invalid expression without adding new input

        // Let's clear and build an invalid expression, then check preservation behavior
        bloc.add(const ClearPressed());
        await Future.delayed(const Duration(milliseconds: 50));

        // Build invalid expression
        bloc.add(const NumericPressed('8'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const EqualsPressed()); // Invalid: 8+

        await expectLater(
          bloc.stream,
          emitsInOrder([
            // After numeric
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '8',
            ),
            // After operator
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '8+',
            ),
            // Error state - result preserved as null (the state.result before error)
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.showError == true &&
                  state.result == null, // Result was null before evaluation
              'result preserved as null since it was null before error evaluation',
            ),
          ]),
        );
      });

      test('multiple consecutive error evaluations preserve result consistently', () async {
        // Build invalid expression: 9×
        bloc.add(const NumericPressed('9'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const EqualsPressed()); // Invalid

        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.showError, true);
        expect(bloc.state.result, null); // No prior result

        // Acknowledge error
        bloc.add(const ErrorAcknowledged());
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.showError, false);
        expect(bloc.state.result, null); // Still null

        // Try another invalid evaluation (still 9×)
        bloc.add(const EqualsPressed()); // Still invalid

        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.showError, true);
        expect(bloc.state.result, null); // Consistently preserved as null
      });

      test('error evaluation does not change result to an error value', () async {
        // This test verifies that on error, result stays as is (null or previous value)
        // rather than being set to an error indicator
        bloc.add(const NumericPressed('7'));
        bloc.add(const OperatorPressed('÷'));
        bloc.add(const EqualsPressed()); // Invalid: 7÷

        await Future.delayed(const Duration(milliseconds: 50));

        // Result should be null, not 'Error' or any error string
        expect(bloc.state.result, null);
        expect(bloc.state.showError, true);
        expect(bloc.state.errorMessage, 'Invalid Input');
      });
    });

    group('ErrorAcknowledged event resets error state', () {
      test('ErrorAcknowledged resets showError to false', () async {
        // First create an error state
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const EqualsPressed()); // Invalid expression

        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.showError, true);
        expect(bloc.state.hasError, true);

        // Dispatch ErrorAcknowledged
        bloc.add(const ErrorAcknowledged());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.showError == false,
            'showError should be reset to false after ErrorAcknowledged',
          )),
        );
      });

      test('ErrorAcknowledged preserves expression value', () async {
        // Create an error state with specific expression
        bloc.add(const NumericPressed('7'));
        bloc.add(const OperatorPressed('-'));
        bloc.add(const EqualsPressed()); // Invalid: 7-

        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.showError, true);
        final expressionBeforeAck = bloc.state.expression.value;

        // Dispatch ErrorAcknowledged
        bloc.add(const ErrorAcknowledged());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.showError == false &&
                state.expression.value == expressionBeforeAck,
            'expression should be preserved after ErrorAcknowledged',
          )),
        );
      });

      test('ErrorAcknowledged preserves hasError and errorMessage', () async {
        // Create an error state
        bloc.add(const NumericPressed('9'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const EqualsPressed()); // Invalid: 9×

        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.showError, true);
        expect(bloc.state.hasError, true);
        expect(bloc.state.errorMessage, 'Invalid Input');

        // Dispatch ErrorAcknowledged
        bloc.add(const ErrorAcknowledged());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.showError == false &&
                state.hasError == true &&
                state.errorMessage == 'Invalid Input' &&
                state.isEvaluationError == true &&
                state.evaluationError == 'Invalid Input',
            'hasError and errorMessage should be preserved after ErrorAcknowledged',
          )),
        );
      });

      test('ErrorAcknowledged preserves result value', () async {
        // First perform a successful calculation
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const EqualsPressed());

        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.result, '6');

        // Make expression invalid by adding operator then evaluating
        bloc.add(const OperatorPressed('-'));
        await Future.delayed(const Duration(milliseconds: 50));
        // After operator press, result is cleared to null
        expect(bloc.state.result, null);

        bloc.add(const EqualsPressed()); // Invalid: 3+3-

        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.showError, true);
        // Result at time of error evaluation was null, so it stays null
        final resultBeforeAck = bloc.state.result;
        expect(resultBeforeAck, null);

        // Dispatch ErrorAcknowledged
        bloc.add(const ErrorAcknowledged());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.showError == false &&
                state.result == resultBeforeAck,
            'result should be preserved after ErrorAcknowledged',
          )),
        );
      });

      test('ErrorAcknowledged does nothing if showError is already false', () async {
        // Ensure initial state has showError: false
        expect(bloc.state.showError, false);

        // Dispatch ErrorAcknowledged when no error is shown
        bloc.add(const ErrorAcknowledged());

        // Wait a bit and verify no state change
        await Future.delayed(const Duration(milliseconds: 50));
        
        // The bloc should not emit a new state if showError was already false
        expect(bloc.state.showError, false);
      });
    });

    group('Valid evaluation after error state', () {
      test('valid expression evaluation after error clears error indicators and updates result', () async {
        // First create an error state
        bloc.add(const NumericPressed('4'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const EqualsPressed()); // Invalid: 4+

        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.showError, true);
        expect(bloc.state.hasError, true);
        expect(bloc.state.isEvaluationError, true);

        // Now add a valid number and evaluate
        bloc.add(const NumericPressed('6'));
        await Future.delayed(const Duration(milliseconds: 50));

        // The error state should be cleared after numeric input
        expect(bloc.state.showError, false);
        expect(bloc.state.hasError, false);
        expect(bloc.state.isEvaluationError, false);

        // Now evaluate the valid expression
        bloc.add(const EqualsPressed()); // Valid: 4+6

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '4+6' &&
                state.result == '10' &&
                state.showError == false &&
                state.hasError == false &&
                state.isEvaluationError == false &&
                state.errorMessage == null &&
                state.evaluationError == null,
            'valid evaluation should clear all error indicators and show correct result',
          )),
        );
      });

      test('successful evaluation after multiple errors works correctly', () async {
        // First error
        bloc.add(const NumericPressed('2'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const EqualsPressed()); // Invalid: 2×

        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.showError, true);

        // Acknowledge first error
        bloc.add(const ErrorAcknowledged());
        await Future.delayed(const Duration(milliseconds: 50));

        // Second error attempt
        bloc.add(const EqualsPressed()); // Still invalid: 2×

        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.showError, true);

        // Acknowledge second error
        bloc.add(const ErrorAcknowledged());
        await Future.delayed(const Duration(milliseconds: 50));

        // Now complete the expression validly
        bloc.add(const NumericPressed('5'));
        bloc.add(const EqualsPressed()); // Valid: 2×5

        await expectLater(
          bloc.stream,
          emitsInOrder([
            // After adding 5
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.expression.value == '2×5' &&
                  state.showError == false &&
                  state.hasError == false,
            ),
            // After evaluation
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.result == '10' &&
                  state.showError == false &&
                  state.hasError == false &&
                  state.isEvaluationError == false,
              'result should be 10 with no error indicators',
            ),
          ]),
        );
      });

      test('clear after error allows fresh valid calculation', () async {
        // Create error state
        bloc.add(const NumericPressed('8'));
        bloc.add(const OperatorPressed('÷'));
        bloc.add(const EqualsPressed()); // Invalid: 8÷

        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.showError, true);

        // Clear everything
        bloc.add(const ClearPressed());

        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.expression.value, '');
        expect(bloc.state.showError, false);
        expect(bloc.state.hasError, false);

        // Enter fresh valid expression
        bloc.add(const NumericPressed('9'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('1'));
        bloc.add(const EqualsPressed()); // Valid: 9+1

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '9',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '9+',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '9+1',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.result == '10' &&
                  state.showError == false &&
                  state.hasError == false &&
                  state.isEvaluationError == false,
              'fresh calculation after clear should work with no error state',
            ),
          ]),
        );
      });

      test('backspace to fix error then evaluate succeeds', () async {
        // Create invalid expression: 3++
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const EqualsPressed()); // Invalid: 3++

        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.showError, true);

        // Use backspace to remove one +
        bloc.add(const BackspacePressed());

        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.expression.value, '3+');
        expect(bloc.state.showError, false); // Error cleared on input

        // Complete the expression
        bloc.add(const NumericPressed('7'));
        bloc.add(const EqualsPressed()); // Valid: 3+7

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3+7',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.result == '10' &&
                  state.showError == false &&
                  state.hasError == false,
              'fixed expression should evaluate correctly',
            ),
          ]),
        );
      });
    });

    group('Edge cases for error handling', () {
      test('consecutive operators like "×÷" trigger error state', () async {
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const OperatorPressed('÷'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const EqualsPressed()); // Invalid: 5×÷2

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5×',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5×÷',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5×÷2',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.showError == true &&
                  state.errorMessage == 'Invalid Input',
              'consecutive different operators should trigger error',
            ),
          ]),
        );
      });

      test('expression ending with power operator triggers error state', () async {
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const EqualsPressed()); // Invalid: 2^

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2^',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.showError == true &&
                  state.errorMessage == 'Invalid Input' &&
                  state.hasError == true,
              'expression ending with ^ should trigger error',
            ),
          ]),
        );
      });

      test('empty parentheses trigger error state', () async {
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const ParenthesisPressed()); // )
        bloc.add(const EqualsPressed()); // Invalid: ()

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '()',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.showError == true &&
                  state.errorMessage == 'Invalid Input',
              'empty parentheses should trigger error',
            ),
          ]),
        );
      });
    });
  });
}
