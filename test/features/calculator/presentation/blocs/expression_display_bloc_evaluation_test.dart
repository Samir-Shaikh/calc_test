import 'package:flutter_test/flutter_test.dart';
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

  setUp(() {
    insertParenthesisUseCase = InsertParenthesisUseCase();
    insertOperatorUseCase = InsertOperatorUseCase();
    evaluateExpressionUseCase = EvaluateExpressionUseCase();
    bloc = ExpressionDisplayBloc(
      insertParenthesisUseCase: insertParenthesisUseCase,
      insertOperatorUseCase: insertOperatorUseCase,
      evaluateExpressionUseCase: evaluateExpressionUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('ExpressionDisplayBloc Evaluation Handling', () {
    group('Successful evaluation state flow', () {
      test('EqualsPressed with valid expression emits state with correct result and no error flag', () async {
        // Build expression: 2+3
        bloc.add(const NumericPressed('2'));
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
              (state) => state.expression.value == '2+3',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.expression.value == '2+3' &&
                  state.result == '5' &&
                  state.hasError == false &&
                  state.errorMessage == null &&
                  state.isEvaluationError == false &&
                  state.evaluationError == null,
              'result should be 5 with no error flags',
            ),
          ]),
        );
      });

      test('EqualsPressed with multiplication expression emits correct result', () async {
        // Build expression: 4×5
        bloc.add(const NumericPressed('4'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NumericPressed('5'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '4',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '4×',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '4×5',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.result == '20' &&
                  state.isEvaluationError == false,
              'result should be 20',
            ),
          ]),
        );
      });

      test('EqualsPressed with division expression emits correct result', () async {
        // Build expression: 10÷2
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('0'));
        bloc.add(const OperatorPressed('÷'));
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
              (state) => state.expression.value == '10÷',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '10÷2',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.result == '5' &&
                  state.isEvaluationError == false,
              'result should be 5',
            ),
          ]),
        );
      });

      test('EqualsPressed with decimal expression emits correct result', () async {
        // Build expression: 1.5+2.5
        bloc.add(const NumericPressed('1'));
        bloc.add(const DecimalPressed());
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const DecimalPressed());
        bloc.add(const NumericPressed('5'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1.',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1.5',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1.5+',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1.5+2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1.5+2.',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1.5+2.5',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.result == '4' &&
                  state.isEvaluationError == false,
              'result should be 4 (1.5+2.5)',
            ),
          ]),
        );
      });

      test('EqualsPressed on empty expression does not emit new state', () async {
        bloc.add(const EqualsPressed());

        // Wait a bit and verify no state change occurred
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.expression.value, '');
        expect(bloc.state.result, null);
        expect(bloc.state.isEvaluationError, false);
      });
    });

    group('Error evaluation state flow', () {
      test('EqualsPressed with incomplete expression emits state with isEvaluationError=true', () async {
        // Build incomplete expression: 5+
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
                  state.hasError == true &&
                  state.isEvaluationError == true &&
                  state.evaluationError != null &&
                  state.result == null,
              'should emit error state with isEvaluationError=true',
            ),
          ]),
        );
      });

      test('EqualsPressed with unbalanced parentheses emits error state', () async {
        // Build expression with unbalanced parentheses: (5+3
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
                  state.isEvaluationError == true &&
                  state.evaluationError != null &&
                  state.hasError == true,
              'should emit error state for unbalanced parentheses',
            ),
          ]),
        );
      });

      test('EqualsPressed with expression ending in power operator emits error state', () async {
        // Build expression: 2^
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());
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
              (state) =>
                  state.isEvaluationError == true &&
                  state.evaluationError != null,
              'should emit error state for incomplete power expression',
            ),
          ]),
        );
      });

      test('error state contains user-friendly error message', () async {
        // Build incomplete expression: 3×
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3×',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.isEvaluationError == true &&
                  state.evaluationError != null &&
                  state.evaluationError!.isNotEmpty &&
                  state.errorMessage != null &&
                  state.errorMessage!.isNotEmpty,
              'error state should contain a non-empty error message',
            ),
          ]),
        );
      });
    });

    group('Error state cleared on next input', () {
      test('NumericPressed after error state clears isEvaluationError', () async {
        // First create an error state
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const EqualsPressed()); // This will fail

        // Wait for error state
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.isEvaluationError, true);

        // Now press a digit
        bloc.add(const NumericPressed('3'));

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '5+3' &&
                state.isEvaluationError == false &&
                state.evaluationError == null &&
                state.hasError == false &&
                state.errorMessage == null &&
                state.result == null,
            'digit press should clear error state',
          )),
        );
      });

      test('OperatorPressed after error state clears isEvaluationError', () async {
        // First create an error state by evaluating incomplete expression
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const EqualsPressed()); // This will fail

        // Wait for error state
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.isEvaluationError, true);

        // Now press an operator (OperatorPressed just appends, doesn't replace)
        bloc.add(const OperatorPressed('-'));

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '5+-' &&
                state.isEvaluationError == false &&
                state.evaluationError == null &&
                state.hasError == false,
            'operator press should clear error state',
          )),
        );
      });

      test('ParenthesisPressed after error state clears isEvaluationError', () async {
        // First create an error state
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const EqualsPressed()); // This will fail

        // Wait for error state
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.isEvaluationError, true);

        // Now press parenthesis
        bloc.add(const ParenthesisPressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.isEvaluationError == false &&
                state.evaluationError == null &&
                state.hasError == false,
            'parenthesis press should clear error state',
          )),
        );
      });

      test('PowerOperatorPressed after error state clears isEvaluationError', () async {
        // First create an error state
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const EqualsPressed()); // This will fail

        // Wait for error state
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.isEvaluationError, true);

        // Now press power operator (PowerOperatorPressed uses InsertOperatorUseCase which replaces +)
        bloc.add(const PowerOperatorPressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '5^' &&
                state.isEvaluationError == false &&
                state.evaluationError == null &&
                state.hasError == false,
            'power operator press should clear error state',
          )),
        );
      });

      test('DecimalPressed after error state clears isEvaluationError', () async {
        // First create an error state
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const EqualsPressed()); // This will fail

        // Wait for error state
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.isEvaluationError, true);

        // Now press decimal
        bloc.add(const DecimalPressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '5+.' &&
                state.isEvaluationError == false &&
                state.evaluationError == null &&
                state.hasError == false,
            'decimal press should clear error state',
          )),
        );
      });

      test('BackspacePressed after error state clears isEvaluationError', () async {
        // First create an error state
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const EqualsPressed()); // This will fail

        // Wait for error state
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.isEvaluationError, true);

        // Now press backspace
        bloc.add(const BackspacePressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '5' &&
                state.isEvaluationError == false &&
                state.evaluationError == null &&
                state.hasError == false,
            'backspace press should clear error state',
          )),
        );
      });

      test('ClearPressed after error state clears isEvaluationError', () async {
        // First create an error state
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const EqualsPressed()); // This will fail

        // Wait for error state
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.isEvaluationError, true);

        // Now press clear
        bloc.add(const ClearPressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '' &&
                state.isEvaluationError == false &&
                state.evaluationError == null &&
                state.hasError == false &&
                state.result == null,
            'clear press should clear error state and expression',
          )),
        );
      });
    });

    group('Complex expression evaluation', () {
      test('(2+3)*4 = 20 (parentheses with multiplication)', () async {
        // Build: (2+3)×4
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const NumericPressed('2'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const ParenthesisPressed()); // )
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NumericPressed('4'));
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
              (state) => state.expression.value == '(2+3)×',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(2+3)×4',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.result == '20' &&
                  state.isEvaluationError == false &&
                  state.hasError == false,
              'result should be 20 ((2+3)×4 = 5×4)',
            ),
          ]),
        );
      });

      test('2^3+1 = 9 (power operator with addition)', () async {
        // Build: 2^3+1
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('1'));
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
              (state) => state.expression.value == '2^3+',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2^3+1',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.result == '9' &&
                  state.isEvaluationError == false,
              'result should be 9 (2^3+1 = 8+1)',
            ),
          ]),
        );
      });

      test('(3+4)^2 = 49 (parentheses with power)', () async {
        // Build: (3+4)^2
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('4'));
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
              (state) => state.expression.value == '(3',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(3+',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(3+4',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(3+4)',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(3+4)^',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(3+4)^2',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.result == '49' &&
                  state.isEvaluationError == false,
              'result should be 49 ((3+4)^2 = 7^2)',
            ),
          ]),
        );
      });

      test('10÷2+3×4 = 17 (operator precedence)', () async {
        // Build: 10÷2+3×4
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('0'));
        bloc.add(const OperatorPressed('÷'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NumericPressed('4'));
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
              (state) => state.expression.value == '10÷',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '10÷2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '10÷2+',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '10÷2+3',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '10÷2+3×',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '10÷2+3×4',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.result == '17' &&
                  state.isEvaluationError == false,
              'result should be 17 (10÷2+3×4 = 5+12)',
            ),
          ]),
        );
      });

      test('2^2^3 = 256 (right-associative power)', () async {
        // Build: 2^2^3 = 2^(2^3) = 2^8 = 256
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());
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
              (state) => state.expression.value == '2^2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2^2^',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2^2^3',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.result == '256' &&
                  state.isEvaluationError == false,
              'result should be 256 (2^(2^3) = 2^8)',
            ),
          ]),
        );
      });

      test('(1+2)×(3+4) = 21 (multiple parentheses groups)', () async {
        // Build: (1+2)×(3+4)
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const NumericPressed('1'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const ParenthesisPressed()); // )
        bloc.add(const OperatorPressed('×'));
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const ParenthesisPressed()); // )
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(1',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(1+',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(1+2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(1+2)',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(1+2)×',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(1+2)×(',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(1+2)×(3',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(1+2)×(3+',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(1+2)×(3+4',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(1+2)×(3+4)',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.result == '21' &&
                  state.isEvaluationError == false,
              'result should be 21 ((1+2)×(3+4) = 3×7)',
            ),
          ]),
        );
      });
    });

    group('Division by zero handling', () {
      test('division by zero shows Infinity result instead of error', () async {
        // Build: 5÷0
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('÷'));
        bloc.add(const NumericPressed('0'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5÷',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5÷0',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.result == 'Infinity' &&
                  state.isEvaluationError == false &&
                  state.hasError == false,
              'result should be Infinity for positive division by zero',
            ),
          ]),
        );
      });

      test('0÷0 shows NaN result', () async {
        // Build: 0÷0
        bloc.add(const NumericPressed('0'));
        bloc.add(const OperatorPressed('÷'));
        bloc.add(const NumericPressed('0'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '0',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '0÷',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '0÷0',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.result == 'NaN' &&
                  state.isEvaluationError == false &&
                  state.hasError == false,
              'result should be NaN for 0÷0',
            ),
          ]),
        );
      });

      test('negative number divided by zero shows -Infinity', () async {
        // Build: -5÷0
        bloc.add(const OperatorPressed('-'));
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('÷'));
        bloc.add(const NumericPressed('0'));
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
              (state) => state.expression.value == '-5÷',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '-5÷0',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.result == '-Infinity' &&
                  state.isEvaluationError == false &&
                  state.hasError == false,
              'result should be -Infinity for negative division by zero',
            ),
          ]),
        );
      });
    });

    group('Single number evaluation', () {
      test('evaluating single digit returns that digit', () async {
        bloc.add(const NumericPressed('5'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.result == '5' &&
                  state.isEvaluationError == false,
              'result should be 5',
            ),
          ]),
        );
      });

      test('evaluating multi-digit number returns that number', () async {
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const EqualsPressed());

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
              (state) =>
                  state.result == '123' &&
                  state.isEvaluationError == false,
              'result should be 123',
            ),
          ]),
        );
      });

      test('evaluating decimal number returns formatted result', () async {
        bloc.add(const NumericPressed('3'));
        bloc.add(const DecimalPressed());
        bloc.add(const NumericPressed('5'));
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
              (state) => state.expression.value == '3.5',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.result == '3.5' &&
                  state.isEvaluationError == false,
              'result should be 3.5',
            ),
          ]),
        );
      });
    });

    group('Result clears on new input after successful evaluation', () {
      test('digit press after successful evaluation clears result', () async {
        // First do a successful evaluation
        bloc.add(const NumericPressed('2'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const EqualsPressed());

        // Wait for evaluation to complete
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.result, '4');

        // Now press a digit
        bloc.add(const NumericPressed('5'));

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '2+25' &&
                state.result == null,
            'result should be cleared after digit press',
          )),
        );
      });

      test('operator press after successful evaluation clears result', () async {
        // First do a successful evaluation
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const EqualsPressed());

        // Wait for evaluation to complete
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.result, '9');

        // Now press an operator
        bloc.add(const OperatorPressed('+'));

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '3×3+' &&
                state.result == null,
            'result should be cleared after operator press',
          )),
        );
      });
    });
  });
}
