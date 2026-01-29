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

  group('ExpressionDisplayBloc Clear Event Handling', () {
    group('ClearPressed clears expression display', () {
      test('given state with expression "123+456", when ClearPressed is added, then emitted state should have empty expression', () async {
        // Build expression: 123+456
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const NumericPressed('5'));
        bloc.add(const NumericPressed('6'));
        bloc.add(const ClearPressed());

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
              (state) => state.expression.value == '123+',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '123+4',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '123+45',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '123+456',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '',
              'expression should be empty after clear',
            ),
          ]),
        );
      });

      test('ClearPressed clears simple numeric expression', () async {
        // Build expression: 42
        bloc.add(const NumericPressed('4'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const ClearPressed());

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
              (state) => state.expression.value == '',
              'expression should be empty after clear',
            ),
          ]),
        );
      });

      test('ClearPressed clears expression with decimals', () async {
        // Build expression: 3.14
        bloc.add(const NumericPressed('3'));
        bloc.add(const DecimalPressed());
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const ClearPressed());

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
              (state) => state.expression.value == '',
              'expression with decimals should be cleared',
            ),
          ]),
        );
      });

      test('ClearPressed clears expression with parentheses', () async {
        // Build expression: (5+3)
        bloc.add(const ParenthesisPressed());
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const ParenthesisPressed());
        bloc.add(const ClearPressed());

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
              (state) => state.expression.value == '(5+3)',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '',
              'expression with parentheses should be cleared',
            ),
          ]),
        );
      });

      test('ClearPressed clears expression with power operator', () async {
        // Build expression: 2^8
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('8'));
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
              (state) => state.expression.value == '2^8',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '',
              'expression with power operator should be cleared',
            ),
          ]),
        );
      });
    });

    group('ClearPressed clears result display', () {
      test('given state with result "579", when ClearPressed is added, then emitted state should have empty/cleared result', () async {
        // Build expression and evaluate: 123+456 = 579
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const NumericPressed('5'));
        bloc.add(const NumericPressed('6'));
        bloc.add(const EqualsPressed());

        // Wait for evaluation to complete
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.result, '579');

        // Now clear
        bloc.add(const ClearPressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '' &&
                state.result == null,
            'both expression and result should be cleared',
          )),
        );
      });

      test('ClearPressed clears result after multiplication evaluation', () async {
        // Build expression and evaluate: 6×7 = 42
        bloc.add(const NumericPressed('6'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NumericPressed('7'));
        bloc.add(const EqualsPressed());

        // Wait for evaluation to complete
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.result, '42');

        // Now clear
        bloc.add(const ClearPressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '' &&
                state.result == null,
            'result should be null after clear',
          )),
        );
      });

      test('ClearPressed clears result with decimal value', () async {
        // Build expression and evaluate: 5÷2 = 2.5
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('÷'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const EqualsPressed());

        // Wait for evaluation to complete
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.result, '2.5');

        // Now clear
        bloc.add(const ClearPressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '' &&
                state.result == null,
            'decimal result should be cleared',
          )),
        );
      });

      test('ClearPressed clears Infinity result from division by zero', () async {
        // Build expression and evaluate: 5÷0 = Infinity
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('÷'));
        bloc.add(const NumericPressed('0'));
        bloc.add(const EqualsPressed());

        // Wait for evaluation to complete
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.result, 'Infinity');

        // Now clear
        bloc.add(const ClearPressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '' &&
                state.result == null,
            'Infinity result should be cleared',
          )),
        );
      });

      test('ClearPressed clears NaN result', () async {
        // Build expression and evaluate: 0÷0 = NaN
        bloc.add(const NumericPressed('0'));
        bloc.add(const OperatorPressed('÷'));
        bloc.add(const NumericPressed('0'));
        bloc.add(const EqualsPressed());

        // Wait for evaluation to complete
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.result, 'NaN');

        // Now clear
        bloc.add(const ClearPressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '' &&
                state.result == null,
            'NaN result should be cleared',
          )),
        );
      });
    });

    group('ClearPressed resets bracket state', () {
      test('given state with leftBracketNext=false, when ClearPressed is added, then state should have leftBracketNext=true', () async {
        // Press parenthesis once to toggle leftBracket to false
        bloc.add(const ParenthesisPressed()); // ( - toggles to leftBracket = false
        
        // Clear should reset to leftBracket = true
        bloc.add(const ClearPressed());
        
        // Next parenthesis should be ( (indicating reset occurred)
        bloc.add(const ParenthesisPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '',
              'clear resets expression',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(',
              'after clear, parenthesis should be "(" indicating bracket state was reset',
            ),
          ]),
        );
      });

      test('ClearPressed resets bracket state after multiple parenthesis toggles', () async {
        // Toggle bracket state multiple times
        bloc.add(const ParenthesisPressed()); // ( - toggles to )
        bloc.add(const ParenthesisPressed()); // ) - toggles to (
        bloc.add(const ParenthesisPressed()); // ( - toggles to )
        
        // Now leftBracket should be false (next would be ')')
        // Clear should reset to leftBracket = true
        bloc.add(const ClearPressed());
        
        // Next parenthesis should be ( (not ))
        bloc.add(const ParenthesisPressed());

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
              (state) => state.expression.value == '()(',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '',
              'clear resets expression',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(',
              'bracket state should be reset to insert "(" first',
            ),
          ]),
        );
      });

      test('ClearPressed resets bracket state in complex expression', () async {
        // Build: (5+3) - this toggles bracket twice
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const ParenthesisPressed()); // )
        
        // Clear
        bloc.add(const ClearPressed());
        
        // Build new expression with parentheses
        bloc.add(const ParenthesisPressed()); // Should be (
        bloc.add(const NumericPressed('2'));
        bloc.add(const ParenthesisPressed()); // Should be )

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
              (state) => state.expression.value == '(5+3)',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(',
              'first parenthesis after clear should be "("',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(2)',
              'second parenthesis should be ")"',
            ),
          ]),
        );
      });

      test('multiple clear operations maintain correct bracket state', () async {
        // First clear
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const ClearPressed());
        bloc.add(const ParenthesisPressed()); // Should be (
        
        // Second clear
        bloc.add(const ParenthesisPressed()); // Should be )
        bloc.add(const ClearPressed());
        bloc.add(const ParenthesisPressed()); // Should be ( again

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(',
              'after first clear, parenthesis is "("',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '()',
              'second press is ")"',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '',
              'second clear',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(',
              'after second clear, parenthesis is "(" again',
            ),
          ]),
        );
      });
    });

    group('Clear from initial state', () {
      test('given initial state, when ClearPressed is added, then state should remain in cleared initial state', () async {
        // Start from initial state and clear
        bloc.add(const ClearPressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '' &&
                state.expression.cursorPosition == 0 &&
                state.result == null &&
                state.hasError == false &&
                state.errorMessage == null &&
                state.isEvaluationError == false &&
                state.evaluationError == null,
            'state should be in initial cleared state',
          )),
        );
      });

      test('ClearPressed on initial state allows normal operation afterwards', () async {
        bloc.add(const ClearPressed());
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('3'));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '',
              'clear on initial state',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5+',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5+3',
            ),
          ]),
        );
      });

      test('multiple ClearPressed on initial state keeps state stable and allows input', () async {
        // Multiple clears followed by input to verify stability
        bloc.add(const ClearPressed());
        bloc.add(const ClearPressed());
        bloc.add(const ClearPressed());
        bloc.add(const NumericPressed('7'));

        // Wait for all events to process
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify final state is correct after multiple clears and one digit
        expect(bloc.state.expression.value, '7');
        expect(bloc.state.result, null);
        expect(bloc.state.hasError, false);
      });
    });

    group('Clear after evaluation', () {
      test('given state after equals pressed with result, when ClearPressed is added, then both expression and result should be cleared', () async {
        // Build and evaluate: 2+3 = 5
        bloc.add(const NumericPressed('2'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const EqualsPressed());

        // Wait for evaluation
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.result, '5');
        expect(bloc.state.expression.value, '2+3');

        // Clear
        bloc.add(const ClearPressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '' &&
                state.result == null &&
                state.hasError == false &&
                state.isEvaluationError == false,
            'both expression and result should be cleared after evaluation',
          )),
        );
      });

      test('ClearPressed after complex evaluation clears everything', () async {
        // Build and evaluate: (2+3)×4 = 20
        bloc.add(const ParenthesisPressed());
        bloc.add(const NumericPressed('2'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const ParenthesisPressed());
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const EqualsPressed());

        // Wait for evaluation
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.result, '20');

        // Clear
        bloc.add(const ClearPressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '' &&
                state.result == null,
            'complex expression and result should be cleared',
          )),
        );
      });

      test('ClearPressed after power operation evaluation clears everything', () async {
        // Build and evaluate: 2^3 = 8
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('3'));
        bloc.add(const EqualsPressed());

        // Wait for evaluation
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.result, '8');

        // Clear
        bloc.add(const ClearPressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '' &&
                state.result == null,
            'power expression and result should be cleared',
          )),
        );
      });

      test('ClearPressed clears error state after failed evaluation', () async {
        // Build incomplete expression and try to evaluate: 5+
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const EqualsPressed());

        // Wait for error state
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.isEvaluationError, true);
        expect(bloc.state.hasError, true);

        // Clear
        bloc.add(const ClearPressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == '' &&
                state.result == null &&
                state.hasError == false &&
                state.errorMessage == null &&
                state.isEvaluationError == false &&
                state.evaluationError == null,
            'error state should be completely cleared',
          )),
        );
      });

      test('ClearPressed after evaluation allows new calculation', () async {
        // First calculation: 5+5 = 10
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('5'));
        bloc.add(const EqualsPressed());

        // Wait for evaluation
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.result, '10');

        // Clear and do new calculation
        bloc.add(const ClearPressed());
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '' && state.result == null,
              'cleared state',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3×',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3×4',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.expression.value == '3×4' &&
                  state.result == '12',
              'new calculation should work correctly',
            ),
          ]),
        );
      });
    });

    group('ClearPressed state properties', () {
      test('ClearPressed resets cursor position to 0', () async {
        // Build expression
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const NumericPressed('3'));

        // Wait for state update
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.expression.cursorPosition, 3);

        // Clear
        bloc.add(const ClearPressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) => state.expression.cursorPosition == 0,
            'cursor position should be 0 after clear',
          )),
        );
      });

      test('ClearPressed clears all error-related properties', () async {
        // Create an error state
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const EqualsPressed());

        // Wait for error state
        await Future.delayed(const Duration(milliseconds: 50));

        // Clear
        bloc.add(const ClearPressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.hasError == false &&
                state.errorMessage == null &&
                state.isEvaluationError == false &&
                state.evaluationError == null,
            'all error properties should be cleared',
          )),
        );
      });

      test('state after ClearPressed equals initial state', () async {
        // Build complex expression
        bloc.add(const NumericPressed('1'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const EqualsPressed());

        // Wait for evaluation
        await Future.delayed(const Duration(milliseconds: 50));

        // Clear
        bloc.add(const ClearPressed());

        // Get the expected initial state
        final initialState = ExpressionDisplayState.initial();

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.expression.value == initialState.expression.value &&
                state.result == initialState.result &&
                state.hasError == initialState.hasError &&
                state.errorMessage == initialState.errorMessage &&
                state.isEvaluationError == initialState.isEvaluationError &&
                state.evaluationError == initialState.evaluationError,
            'state after clear should match initial state',
          )),
        );
      });
    });
  });
}
