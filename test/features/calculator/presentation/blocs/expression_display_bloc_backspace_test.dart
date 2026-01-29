import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/clear_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/delete_character_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_operator_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_parenthesis_use_case.dart';
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

  setUp(() {
    insertParenthesisUseCase = InsertParenthesisUseCase();
    insertOperatorUseCase = InsertOperatorUseCase();
    evaluateExpressionUseCase = EvaluateExpressionUseCase();
    clearExpressionUseCase = ClearExpressionUseCase();
    deleteCharacterUseCase = DeleteCharacterUseCase();
    bloc = ExpressionDisplayBloc(
      insertParenthesisUseCase: insertParenthesisUseCase,
      insertOperatorUseCase: insertOperatorUseCase,
      evaluateExpressionUseCase: evaluateExpressionUseCase,
      clearExpressionUseCase: clearExpressionUseCase,
      deleteCharacterUseCase: deleteCharacterUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('ExpressionDisplayBloc Backspace Event Handling', () {
    group('BackspacePressed emits correct state', () {
      test('given state with expression "123", when BackspacePressed is added, then emitted state should have expression "12"', () async {
        // Build expression: 123
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const BackspacePressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '12',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '123',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '12',
              'expression should have last character removed after backspace',
            ),
          ]),
        );
      });

      test('BackspacePressed removes operator from expression', () async {
        // Build expression: 5+
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const BackspacePressed());

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
              (state) => state.expression.value == '5',
              'operator should be removed after backspace',
            ),
          ]),
        );
      });

      test('BackspacePressed removes decimal point from expression', () async {
        // Build expression: 3.
        bloc.add(const NumericPressed('3'));
        bloc.add(const DecimalPressed());
        bloc.add(const BackspacePressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3.',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3',
              'decimal point should be removed after backspace',
            ),
          ]),
        );
      });

      test('BackspacePressed removes parenthesis from expression', () async {
        // Build expression: (5)
        bloc.add(const ParenthesisPressed());
        bloc.add(const NumericPressed('5'));
        bloc.add(const ParenthesisPressed());
        bloc.add(const BackspacePressed());

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
              (state) => state.expression.value == '(5)',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(5',
              'closing parenthesis should be removed after backspace',
            ),
          ]),
        );
      });

      test('BackspacePressed removes power operator from expression', () async {
        // Build expression: 2^
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const BackspacePressed());

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
              (state) => state.expression.value == '2',
              'power operator should be removed after backspace',
            ),
          ]),
        );
      });

      test('BackspacePressed updates cursor position correctly', () async {
        // Build expression: 123
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const NumericPressed('3'));
        
        // Wait for state update
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.expression.cursorPosition, 3);
        
        // Backspace
        bloc.add(const BackspacePressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) => state.expression.cursorPosition == 2,
            'cursor position should be decremented after backspace',
          )),
        );
      });

      test('BackspacePressed clears result when present', () async {
        // Build and evaluate: 5+3 = 8
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const EqualsPressed());

        // Wait for evaluation
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.result, '8');

        // Backspace should clear result
        bloc.add(const BackspacePressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '5+' &&
                state.result == null,
            'result should be cleared and character removed after backspace',
          )),
        );
      });

      test('BackspacePressed clears evaluation error state', () async {
        // Create an error state by evaluating incomplete expression
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const EqualsPressed());

        // Wait for error state
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.isEvaluationError, true);

        // Backspace should clear error
        bloc.add(const BackspacePressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '5' &&
                state.hasError == false &&
                state.isEvaluationError == false &&
                state.evaluationError == null,
            'error state should be cleared after backspace',
          )),
        );
      });
    });

    group('BackspacePressed on empty expression', () {
      test('given initial state with empty expression, when BackspacePressed is added, then state should remain unchanged', () async {
        // Backspace on empty expression should not emit a new state
        bloc.add(const BackspacePressed());

        // Wait a bit to ensure no state change occurs
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify state remains initial
        expect(bloc.state.expression.value, '');
        expect(bloc.state.expression.cursorPosition, 0);
      });

      test('BackspacePressed on empty expression does not emit new state', () async {
        // We expect no state changes from backspace on empty expression
        // Add a numeric press after to verify stream is still working
        bloc.add(const BackspacePressed());
        bloc.add(const NumericPressed('5'));

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) => state.expression.value == '5',
            'only numeric press should emit state, not backspace on empty',
          )),
        );
      });

      test('multiple BackspacePressed on empty expression keeps state stable', () async {
        bloc.add(const BackspacePressed());
        bloc.add(const BackspacePressed());
        bloc.add(const BackspacePressed());
        bloc.add(const NumericPressed('7'));

        // Wait for all events to process
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify state is just "7" - no emissions from backspaces on empty
        expect(bloc.state.expression.value, '7');
        expect(bloc.state.expression.cursorPosition, 1);
      });
    });

    group('BackspacePressed with cursor at position 0', () {
      test('given expression with cursor at position 0, when BackspacePressed is added, then state should remain unchanged', () async {
        // Build expression and move cursor to position 0 conceptually
        // Since cursor follows input, we need to test edge case where expression exists
        // but cursor is at 0 - this is handled by the use case returning same expression
        
        // In current implementation, cursor is always at end after input
        // So we test by deleting everything until empty
        bloc.add(const NumericPressed('1'));
        bloc.add(const BackspacePressed()); // Deletes '1', now empty
        bloc.add(const BackspacePressed()); // Should not emit (cursor at 0)
        bloc.add(const NumericPressed('2')); // Verify bloc still works

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '',
              'expression should be empty after first backspace',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2',
              'second backspace should not emit, only numeric press should',
            ),
          ]),
        );
      });
    });

    group('Multiple consecutive backspace events', () {
      test('given expression "12345", when 3 BackspacePressed events are added, then expression should be "12"', () async {
        // Build expression: 12345
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const NumericPressed('5'));
        bloc.add(const BackspacePressed());
        bloc.add(const BackspacePressed());
        bloc.add(const BackspacePressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '12',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '123',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1234',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '12345',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1234',
              'first backspace removes 5',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '123',
              'second backspace removes 4',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '12',
              'third backspace removes 3',
            ),
          ]),
        );
      });

      test('consecutive backspaces delete entire expression one character at a time', () async {
        // Build expression: abc (using digits for simplicity)
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const BackspacePressed());
        bloc.add(const BackspacePressed());
        bloc.add(const BackspacePressed());
        bloc.add(const BackspacePressed()); // Extra backspace on empty - should not emit

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '12',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '123',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '12',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '',
              'expression should be empty after deleting all characters',
            ),
            // No more emissions expected for backspace on empty
          ]),
        );
      });

      test('multiple backspaces on complex expression with mixed characters', () async {
        // Build expression: 5+3×2
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const BackspacePressed());
        bloc.add(const BackspacePressed());
        bloc.add(const BackspacePressed());

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
              (state) => state.expression.value == '5+3',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5+3×',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5+3×2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5+3×',
              'backspace removes digit',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5+3',
              'backspace removes operator',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5+',
              'backspace removes another digit',
            ),
          ]),
        );
      });
    });

    group('Backspace interaction with other events', () {
      test('digit input followed by backspace returns to previous state', () async {
        bloc.add(const NumericPressed('5'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const BackspacePressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '53',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5',
              'backspace should undo last digit input',
            ),
          ]),
        );
      });

      test('backspace then digit input works correctly', () async {
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const BackspacePressed());
        bloc.add(const NumericPressed('9'));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '12',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1',
              'backspace removes 2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '19',
              'new digit 9 is appended',
            ),
          ]),
        );
      });

      test('operator input followed by backspace followed by different operator', () async {
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const BackspacePressed());
        bloc.add(const OperatorPressed('×'));

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
              (state) => state.expression.value == '5',
              'backspace removes +',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5×',
              'new operator × is inserted',
            ),
          ]),
        );
      });

      test('clear followed by backspace on empty expression', () async {
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const ClearPressed());
        bloc.add(const BackspacePressed()); // Should not emit
        bloc.add(const NumericPressed('7'));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '12',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '123',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '',
              'clear empties expression',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '7',
              'backspace on empty does not emit, only numeric press does',
            ),
          ]),
        );
      });

      test('evaluation followed by backspace modifies expression', () async {
        // Build and evaluate: 2+3 = 5
        bloc.add(const NumericPressed('2'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const EqualsPressed());

        // Wait for evaluation
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.result, '5');
        expect(bloc.state.expression.value, '2+3');

        // Backspace
        bloc.add(const BackspacePressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '2+' &&
                state.result == null,
            'backspace should remove last character and clear result',
          )),
        );
      });

      test('parenthesis input followed by backspace removes parenthesis', () async {
        bloc.add(const ParenthesisPressed());
        bloc.add(const NumericPressed('5'));
        bloc.add(const BackspacePressed());
        bloc.add(const BackspacePressed());

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
              (state) => state.expression.value == '(',
              'backspace removes 5',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '',
              'backspace removes opening parenthesis',
            ),
          ]),
        );
      });

      test('power operator input followed by backspace followed by digit', () async {
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const BackspacePressed());
        bloc.add(const NumericPressed('5'));

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
              (state) => state.expression.value == '2',
              'backspace removes ^',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '25',
              'digit 5 is appended instead of power',
            ),
          ]),
        );
      });

      test('decimal input followed by backspace followed by operator', () async {
        bloc.add(const NumericPressed('3'));
        bloc.add(const DecimalPressed());
        bloc.add(const BackspacePressed());
        bloc.add(const OperatorPressed('+'));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3.',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3',
              'backspace removes decimal point',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3+',
              'operator is inserted instead of decimal',
            ),
          ]),
        );
      });

      test('complete workflow: build expression, evaluate, backspace, continue', () async {
        // Build: 10+5 = 15
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('0'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('5'));
        bloc.add(const EqualsPressed());

        // Wait for evaluation
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.result, '15');

        // Backspace to remove 5, then add 8
        bloc.add(const BackspacePressed());
        bloc.add(const NumericPressed('8'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '10+' && state.result == null,
              'backspace removes 5 and clears result',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '10+8',
              'digit 8 is added',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.expression.value == '10+8' &&
                  state.result == '18',
              'new evaluation gives 18',
            ),
          ]),
        );
      });
    });

    group('BackspacePressed state properties', () {
      test('BackspacePressed maintains correct state properties', () async {
        bloc.add(const NumericPressed('5'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const BackspacePressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<ExpressionDisplayState>(),
            isA<ExpressionDisplayState>(),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.expression.value == '5' &&
                  state.expression.cursorPosition == 1 &&
                  state.result == null &&
                  state.hasError == false &&
                  state.errorMessage == null &&
                  state.isEvaluationError == false &&
                  state.evaluationError == null,
              'all state properties should be correctly set after backspace',
            ),
          ]),
        );
      });
    });
  });
}
