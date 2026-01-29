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

  group('ExpressionDisplayBloc Negate Event Handling', () {
    group('NegatePressed with empty state', () {
      test('given empty state, when NegatePressed is added, then emitted state should have minus sign', () async {
        bloc.add(const NegatePressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) => state.expression.value == '-',
            'expression should be "-" after negate on empty state',
          )),
        );
      });

      test('given empty state, when NegatePressed is added, then cursor should be at position 1', () async {
        bloc.add(const NegatePressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '-' &&
                state.expression.cursorPosition == 1,
            'cursor should be at position 1 after negate',
          )),
        );
      });

      test('given empty state, when NegatePressed is added, then result and error state should be cleared', () async {
        bloc.add(const NegatePressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.result == null &&
                state.hasError == false &&
                state.errorMessage == null &&
                state.isEvaluationError == false &&
                state.evaluationError == null,
            'result and error state should be cleared',
          )),
        );
      });
    });

    group('NegatePressed with positive number', () {
      test('given state with positive number "5", when NegatePressed is added, then emitted state should have "-5"', () async {
        bloc.add(const NumericPressed('5'));
        bloc.add(const NegatePressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '-5',
              'expression should be "-5" after negate',
            ),
          ]),
        );
      });

      test('given state with multi-digit positive number "123", when NegatePressed is added, then emitted state should have "-123"', () async {
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const NegatePressed());

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
              (state) => state.expression.value == '-123',
              'expression should be "-123" after negate',
            ),
          ]),
        );
      });

      test('given state with decimal number "3.14", when NegatePressed is added, then emitted state should have "-3.14"', () async {
        bloc.add(const NumericPressed('3'));
        bloc.add(const DecimalPressed());
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const NegatePressed());

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
              (state) => state.expression.value == '3.1',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3.14',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '-3.14',
              'expression should be "-3.14" after negate',
            ),
          ]),
        );
      });
    });

    group('NegatePressed with negative number', () {
      test('given state with negative number "-5", when NegatePressed is added, then emitted state should have "5"', () async {
        bloc.add(const NumericPressed('5'));
        bloc.add(const NegatePressed()); // Makes it -5
        bloc.add(const NegatePressed()); // Makes it 5

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '-5',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5',
              'expression should be "5" after double negate',
            ),
          ]),
        );
      });

      test('given state with negative multi-digit number "-123", when NegatePressed is added, then emitted state should have "123"', () async {
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const NegatePressed()); // Makes it -123
        bloc.add(const NegatePressed()); // Makes it 123

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
              (state) => state.expression.value == '-123',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '123',
              'expression should be "123" after double negate',
            ),
          ]),
        );
      });

      test('given state with negative decimal "-3.14", when NegatePressed is added, then emitted state should have "3.14"', () async {
        bloc.add(const NumericPressed('3'));
        bloc.add(const DecimalPressed());
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const NegatePressed()); // Makes it -3.14
        bloc.add(const NegatePressed()); // Makes it 3.14

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
              (state) => state.expression.value == '3.1',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3.14',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '-3.14',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3.14',
              'expression should be "3.14" after double negate',
            ),
          ]),
        );
      });
    });

    group('NegatePressed after operator', () {
      test('given state with "5+", when NegatePressed is added, then emitted state should have "5+-"', () async {
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NegatePressed());

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
              (state) => state.expression.value == '5+-',
              'expression should be "5+-" after negate',
            ),
          ]),
        );
      });

      test('given state with "5×", when NegatePressed is added, then emitted state should have "5×-"', () async {
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NegatePressed());

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
              (state) => state.expression.value == '5×-',
              'expression should be "5×-" after negate',
            ),
          ]),
        );
      });

      test('given state with "2^", when NegatePressed is added, then emitted state should have "2^-"', () async {
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NegatePressed());

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
              (state) => state.expression.value == '2^-',
              'expression should be "2^-" after negate',
            ),
          ]),
        );
      });
    });

    group('NegatePressed in complex expressions', () {
      test('given state with "3+5", when NegatePressed is added, then emitted state should negate the second operand', () async {
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('5'));
        bloc.add(const NegatePressed());

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
              (state) => state.expression.value == '3+5',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3+-5',
              'expression should be "3+-5" after negate',
            ),
          ]),
        );
      });

      test('given state with "3+-5", when NegatePressed is added, then emitted state should remove the negation', () async {
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('5'));
        bloc.add(const NegatePressed()); // Makes it 3+-5
        bloc.add(const NegatePressed()); // Makes it 3+5

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
              (state) => state.expression.value == '3+5',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3+-5',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3+5',
              'expression should be "3+5" after double negate',
            ),
          ]),
        );
      });

      test('given state with "2^3", when NegatePressed is added, then emitted state should negate the exponent', () async {
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('3'));
        bloc.add(const NegatePressed());

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
              (state) => state.expression.value == '2^3',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2^-3',
              'expression should be "2^-3" after negate',
            ),
          ]),
        );
      });
    });

    group('NegatePressed with parentheses', () {
      test('given state with "(", when NegatePressed is added, then emitted state should have "(-"', () async {
        bloc.add(const ParenthesisPressed());
        bloc.add(const NegatePressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(-',
              'expression should be "(-" after negate',
            ),
          ]),
        );
      });

      test('given state with "2+(", when NegatePressed is added, then emitted state should have "2+(-"', () async {
        bloc.add(const NumericPressed('2'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const ParenthesisPressed());
        bloc.add(const NegatePressed());

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
              (state) => state.expression.value == '2+(',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2+(-',
              'expression should be "2+(-" after negate',
            ),
          ]),
        );
      });
    });

    group('NegatePressed clears error state', () {
      test('given state with evaluation error, when NegatePressed is added, then error state should be cleared', () async {
        // Build incomplete expression and try to evaluate: 5+
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const EqualsPressed());

        // Wait for error state
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.isEvaluationError, true);
        expect(bloc.state.hasError, true);

        // Negate should clear the error state
        bloc.add(const NegatePressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.hasError == false &&
                state.errorMessage == null &&
                state.isEvaluationError == false &&
                state.evaluationError == null,
            'error state should be cleared after negate',
          )),
        );
      });

      test('given state with result, when NegatePressed is added, then result should be cleared', () async {
        // Build and evaluate: 2+3 = 5
        bloc.add(const NumericPressed('2'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const EqualsPressed());

        // Wait for evaluation
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.result, '5');

        // Negate should clear the result
        bloc.add(const NegatePressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) => state.result == null,
            'result should be cleared after negate',
          )),
        );
      });
    });

    group('NegatePressed toggle sign multiple times', () {
      test('toggling sign 4 times returns to original value', () async {
        bloc.add(const NumericPressed('4'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const NegatePressed()); // -42
        bloc.add(const NegatePressed()); // 42
        bloc.add(const NegatePressed()); // -42
        bloc.add(const NegatePressed()); // 42

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '4',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '42',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '-42',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '42',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '-42',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '42',
              'expression should be "42" after 4 negations',
            ),
          ]),
        );
      });
    });

    group('NegatePressed followed by continued input', () {
      test('given negated state "-", when numeric is pressed, then complete negative number is formed', () async {
        bloc.add(const NegatePressed());
        bloc.add(const NumericPressed('5'));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '-',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '-5',
              'expression should be "-5" after negate and digit',
            ),
          ]),
        );
      });

      test('given negated expression "5+-", when numeric is pressed, then expression continues correctly', () async {
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NegatePressed());
        bloc.add(const NumericPressed('3'));

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
              (state) => state.expression.value == '5+-',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5+-3',
              'expression should be "5+-3" after building negative second operand',
            ),
          ]),
        );
      });

      test('given simple negative number "-5", when equals is pressed, then evaluation should work correctly', () async {
        // Test that a simple negated number can be evaluated
        bloc.add(const NegatePressed());
        bloc.add(const NumericPressed('5'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '-',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '-5',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.expression.value == '-5' &&
                  state.result == '-5',
              'result should be "-5" for simple negative number',
            ),
          ]),
        );
      });
    });

    group('NegatePressed after clear', () {
      test('given cleared state, when NegatePressed is added, then state should have minus sign', () async {
        // Build some expression
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const NumericPressed('3'));
        
        // Clear
        bloc.add(const ClearPressed());
        
        // Negate on fresh state
        bloc.add(const NegatePressed());

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
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '-',
              'expression should be "-" after clear and negate',
            ),
          ]),
        );
      });
    });

    group('NegatePressed evaluation with single negated value', () {
      test('negated single number evaluates correctly', () async {
        // Build and evaluate: -42
        bloc.add(const NumericPressed('4'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const NegatePressed());
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '4',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '42',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '-42',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.expression.value == '-42' &&
                  state.result == '-42',
              'result should be "-42"',
            ),
          ]),
        );
      });

      test('negated decimal number evaluates correctly', () async {
        // Build and evaluate: -3.14
        bloc.add(const NumericPressed('3'));
        bloc.add(const DecimalPressed());
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const NegatePressed());
        bloc.add(const EqualsPressed());

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
              (state) => state.expression.value == '3.1',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3.14',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '-3.14',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.expression.value == '-3.14' &&
                  state.result == '-3.14',
              'result should be "-3.14"',
            ),
          ]),
        );
      });
    });
  });
}
