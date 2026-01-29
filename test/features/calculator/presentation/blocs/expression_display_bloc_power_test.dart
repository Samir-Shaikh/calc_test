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

  group('ExpressionDisplayBloc Power Operator Handling', () {
    group('PowerOperatorPressed event handling', () {
      test('emits state with "^" when PowerOperatorPressed is dispatched after a digit', () async {
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2',
              'expression should be "2"',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2^',
              'expression should be "2^"',
            ),
          ]),
        );
      });

      test('PowerOperatorPressed adds "^" to expression', () async {
        bloc.add(const NumericPressed('5'));
        bloc.add(const PowerOperatorPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5^',
            ),
          ]),
        );
      });

      test('PowerOperatorPressed on empty expression does nothing (except minus allowed)', () async {
        bloc.add(const PowerOperatorPressed());

        // Since power operator is not allowed on empty expression (only minus is),
        // the stream should not emit any state change
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.expression.value, '');
      });

      test('PowerOperatorPressed replaces previous operator', () async {
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const PowerOperatorPressed());

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
              (state) => state.expression.value == '3^',
              'power operator should replace + operator',
            ),
          ]),
        );
      });

      test('PowerOperatorPressed clears result and error state', () async {
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.expression.value == '2^' &&
                  state.result == null &&
                  state.hasError == false &&
                  state.errorMessage == null,
              'result should be null and error state should be cleared',
            ),
          ]),
        );
      });
    });

    group('Full power calculation flow', () {
      test('2^3 = 8 (basic integer exponentiation)', () async {
        // Sequence: digit(2) -> power -> digit(3) -> equals
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('3'));
        bloc.add(const EqualsPressed());

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
              (state) => state.result == '8',
              'result should be 8 (2^3)',
            ),
          ]),
        );
      });

      test('3^2 = 9', () async {
        bloc.add(const NumericPressed('3'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('2'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3^',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3^2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.result == '9',
              'result should be 9 (3^2)',
            ),
          ]),
        );
      });

      test('10^2 = 100 (multi-digit base)', () async {
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('0'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('2'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '10',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '10^',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '10^2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.result == '100',
              'result should be 100 (10^2)',
            ),
          ]),
        );
      });

      test('5^0 = 1 (any number to power of 0)', () async {
        bloc.add(const NumericPressed('5'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('0'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5^',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5^0',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.result == '1',
              'result should be 1 (5^0)',
            ),
          ]),
        );
      });

      test('2^10 = 1024 (larger exponent)', () async {
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('0'));
        bloc.add(const EqualsPressed());

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
              (state) => state.expression.value == '2^1',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2^10',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.result == '1024',
              'result should be 1024 (2^10)',
            ),
          ]),
        );
      });
    });

    group('Power with decimal exponent', () {
      test('4^0.5 ≈ 2 (square root via power)', () async {
        // Sequence: digit(4) -> power -> decimal -> digit(5) -> equals
        bloc.add(const NumericPressed('4'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('0'));
        bloc.add(const DecimalPressed());
        bloc.add(const NumericPressed('5'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '4',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '4^',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '4^0',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '4^0.',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '4^0.5',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.result == '2',
              'result should be 2 (4^0.5 = sqrt(4))',
            ),
          ]),
        );
      });

      test('2^0.5 ≈ 1.414... (square root of 2)', () async {
        // Sequence: digit(2) -> power -> decimal -> digit(5) -> equals
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('0'));
        bloc.add(const DecimalPressed());
        bloc.add(const NumericPressed('5'));
        bloc.add(const EqualsPressed());

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
              (state) => state.expression.value == '2^0',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2^0.',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2^0.5',
            ),
            predicate<ExpressionDisplayState>(
              (state) {
                if (state.result == null) return false;
                final result = double.tryParse(state.result!);
                if (result == null) return false;
                // sqrt(2) ≈ 1.4142135623730951
                return (result - 1.4142135623730951).abs() < 0.0001;
              },
              'result should be approximately 1.414 (sqrt(2))',
            ),
          ]),
        );
      });

      test('8^0.333... ≈ 2 (cube root approximation)', () async {
        bloc.add(const NumericPressed('8'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('0'));
        bloc.add(const DecimalPressed());
        bloc.add(const NumericPressed('3'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '8',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '8^',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '8^0',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '8^0.',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '8^0.3',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '8^0.33',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '8^0.333',
            ),
            predicate<ExpressionDisplayState>(
              (state) {
                if (state.result == null) return false;
                final result = double.tryParse(state.result!);
                if (result == null) return false;
                // 8^0.333 ≈ 1.9997... (approximately 2)
                return (result - 2.0).abs() < 0.01;
              },
              'result should be approximately 2 (cube root of 8)',
            ),
          ]),
        );
      });

      test('9^1.5 = 27 (9^(3/2) = sqrt(9)^3 = 27)', () async {
        bloc.add(const NumericPressed('9'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('1'));
        bloc.add(const DecimalPressed());
        bloc.add(const NumericPressed('5'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '9',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '9^',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '9^1',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '9^1.',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '9^1.5',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.result == '27',
              'result should be 27 (9^1.5)',
            ),
          ]),
        );
      });
    });

    group('Power with other operators', () {
      test('2+3^2 = 11 (power has higher precedence than addition)', () async {
        bloc.add(const NumericPressed('2'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('2'));
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
              (state) => state.expression.value == '2+3',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2+3^',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2+3^2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.result == '11',
              'result should be 11 (2 + 3^2 = 2 + 9)',
            ),
          ]),
        );
      });

      test('2×3^2 = 18 (power has higher precedence than multiplication)', () async {
        bloc.add(const NumericPressed('2'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('2'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2×',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2×3',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2×3^',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2×3^2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.result == '18',
              'result should be 18 (2 × 3^2 = 2 × 9)',
            ),
          ]),
        );
      });

      test('(2+3)^2 = 25 (parentheses with power)', () async {
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const NumericPressed('2'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const ParenthesisPressed()); // )
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('2'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(2+',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(2+3',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(2+3)',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(2+3)^',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(2+3)^2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.result == '25',
              'result should be 25 ((2+3)^2 = 5^2)',
            ),
          ]),
        );
      });
    });

    group('Power chaining (right-associativity)', () {
      test('2^3^2 = 512 (right-associative: 2^(3^2) = 2^9)', () async {
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('3'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('2'));
        bloc.add(const EqualsPressed());

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
              (state) => state.expression.value == '2^3^',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2^3^2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.result == '512',
              'result should be 512 (2^(3^2) = 2^9)',
            ),
          ]),
        );
      });
    });

    group('Edge cases', () {
      test('backspace after power operator works correctly', () async {
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
              'backspace should remove ^ operator',
            ),
          ]),
        );
      });

      test('clear after power expression works correctly', () async {
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('3'));
        bloc.add(const ClearPressed());

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
              (state) => state.expression.value == '',
              'clear should reset expression',
            ),
          ]),
        );
      });

      test('power after closing parenthesis works correctly', () async {
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const NumericPressed('5'));
        bloc.add(const ParenthesisPressed()); // )
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('2'));
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
              (state) => state.expression.value == '(5)',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(5)^',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(5)^2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.result == '25',
              'result should be 25 ((5)^2)',
            ),
          ]),
        );
      });

      test('1^100 = 1 (1 to any power)', () async {
        bloc.add(const NumericPressed('1'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('0'));
        bloc.add(const NumericPressed('0'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1^',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1^1',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1^10',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1^100',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.result == '1',
              'result should be 1 (1^100)',
            ),
          ]),
        );
      });

      test('0^5 = 0 (0 to positive power)', () async {
        bloc.add(const NumericPressed('0'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('5'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '0',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '0^',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '0^5',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.result == '0',
              'result should be 0 (0^5)',
            ),
          ]),
        );
      });
    });
  });
}
