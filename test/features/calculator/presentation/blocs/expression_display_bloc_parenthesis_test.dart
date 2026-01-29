import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/clear_expression_use_case.dart';
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

  setUp(() {
    insertParenthesisUseCase = InsertParenthesisUseCase();
    insertOperatorUseCase = InsertOperatorUseCase();
    evaluateExpressionUseCase = EvaluateExpressionUseCase();
    clearExpressionUseCase = ClearExpressionUseCase();
    bloc = ExpressionDisplayBloc(
      insertParenthesisUseCase: insertParenthesisUseCase,
      insertOperatorUseCase: insertOperatorUseCase,
      evaluateExpressionUseCase: evaluateExpressionUseCase,
      clearExpressionUseCase: clearExpressionUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('ExpressionDisplayBloc Parenthesis Handling', () {
    group('ParenthesisPressed inserts left bracket initially', () {
      test('emits state with "(" when ParenthesisPressed is first dispatched', () async {
        bloc.add(const ParenthesisPressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) => state.expression.value == '(',
            'expression should be "("',
          )),
        );
      });

      test('emits state with "(" after digits when ParenthesisPressed is first dispatched', () async {
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const ParenthesisPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5',
              'expression should be "5"',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5+',
              'expression should be "5+"',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5+(',
              'expression should be "5+("',
            ),
          ]),
        );
      });

      test('first ParenthesisPressed on empty expression inserts left bracket', () async {
        bloc.add(const ParenthesisPressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) => state.expression.value == '(',
            'expression should be "("',
          )),
        );
      });
    });

    group('ParenthesisPressed toggles to right bracket', () {
      test('second ParenthesisPressed inserts ")" after first "("', () async {
        bloc.add(const ParenthesisPressed()); // Insert (
        bloc.add(const ParenthesisPressed()); // Insert )

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(',
              'first state should have expression "("',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '()',
              'second state should have expression "()"',
            ),
          ]),
        );
      });

      test('multiple ParenthesisPressed alternates between ( and )', () async {
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const ParenthesisPressed()); // )
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const ParenthesisPressed()); // )

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(',
              'first: "("',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '()',
              'second: "()"',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '()(',
              'third: "()("',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '()()',
              'fourth: "()()"',
            ),
          ]),
        );
      });

      test('six consecutive presses produce correct alternating pattern', () async {
        bloc.add(const NumericPressed('1'));
        bloc.add(const OperatorPressed('+'));
        for (int i = 0; i < 6; i++) {
          bloc.add(const ParenthesisPressed());
        }

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1+',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1+(',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1+()',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1+()(',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1+()()',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1+()()(',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1+()()()',
            ),
          ]),
        );
      });
    });

    group('ClearPressed resets bracket state', () {
      test('ClearPressed resets bracket state so next ParenthesisPressed inserts "("', () async {
        bloc.add(const ParenthesisPressed()); // Insert (
        bloc.add(const ClearPressed()); // Clear and reset bracket state
        bloc.add(const ParenthesisPressed()); // Should insert ( again

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(',
              'first parenthesis should be "("',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '',
              'expression should be empty after clear',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(',
              'parenthesis after clear should be "(" (reset)',
            ),
          ]),
        );
      });

      test('ClearPressed after multiple parentheses resets bracket state', () async {
        // Press parenthesis twice: () -> leftBracket becomes true
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const ParenthesisPressed()); // )
        // Press once more: (() -> leftBracket becomes false
        bloc.add(const ParenthesisPressed()); // (
        // Clear should reset to leftBracket = true
        bloc.add(const ClearPressed());
        // Next parenthesis should be (
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
              'first parenthesis after clear should be "("',
            ),
          ]),
        );
      });

      test('ClearPressed on empty expression still allows correct parenthesis behavior', () async {
        bloc.add(const ClearPressed()); // Clear empty expression
        bloc.add(const ParenthesisPressed()); // Should insert (
        bloc.add(const ParenthesisPressed()); // Should insert )

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '',
              'clear keeps expression empty',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(',
              'first parenthesis is "("',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '()',
              'second parenthesis is ")"',
            ),
          ]),
        );
      });
    });

    group('Parentheses in complex expressions', () {
      test('building expression "(2+3)*4" with appropriate events', () async {
        // Build: (2+3)×4
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const NumericPressed('2')); // (2
        bloc.add(const OperatorPressed('+')); // (2+
        bloc.add(const NumericPressed('3')); // (2+3
        bloc.add(const ParenthesisPressed()); // (2+3)
        bloc.add(const OperatorPressed('×')); // (2+3)×
        bloc.add(const NumericPressed('4')); // (2+3)×4

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
          ]),
        );
      });

      test('building nested parentheses expression with toggle behavior', () async {
        // Due to toggle behavior, alternating pattern is produced
        bloc.add(const ParenthesisPressed()); // ( - toggles to )
        bloc.add(const ParenthesisPressed()); // () - toggles to (
        bloc.add(const NumericPressed('1')); // ()1
        bloc.add(const OperatorPressed('+')); // ()1+
        bloc.add(const NumericPressed('2')); // ()1+2
        bloc.add(const ParenthesisPressed()); // ()1+2( - toggles to )
        bloc.add(const ParenthesisPressed()); // ()1+2()

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
              (state) => state.expression.value == '()1',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '()1+',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '()1+2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '()1+2(',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '()1+2()',
            ),
          ]),
        );
      });

      test('building expression "5×(10÷2)" with display operators', () async {
        // Build: 5×(10÷2)
        bloc.add(const NumericPressed('5')); // 5
        bloc.add(const OperatorPressed('×')); // 5×
        bloc.add(const ParenthesisPressed()); // 5×(
        bloc.add(const NumericPressed('1')); // 5×(1
        bloc.add(const NumericPressed('0')); // 5×(10
        bloc.add(const OperatorPressed('÷')); // 5×(10÷
        bloc.add(const NumericPressed('2')); // 5×(10÷2
        bloc.add(const ParenthesisPressed()); // 5×(10÷2)

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
              (state) => state.expression.value == '5×(',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5×(1',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5×(10',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5×(10÷',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5×(10÷2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '5×(10÷2)',
            ),
          ]),
        );
      });

      test('building expression with decimals "(1.5+2.5)×3"', () async {
        // Build: (1.5+2.5)×3
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const NumericPressed('1')); // (1
        bloc.add(const DecimalPressed()); // (1.
        bloc.add(const NumericPressed('5')); // (1.5
        bloc.add(const OperatorPressed('+')); // (1.5+
        bloc.add(const NumericPressed('2')); // (1.5+2
        bloc.add(const DecimalPressed()); // (1.5+2.
        bloc.add(const NumericPressed('5')); // (1.5+2.5
        bloc.add(const ParenthesisPressed()); // (1.5+2.5)
        bloc.add(const OperatorPressed('×')); // (1.5+2.5)×
        bloc.add(const NumericPressed('3')); // (1.5+2.5)×3

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
              (state) => state.expression.value == '(1.',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(1.5',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(1.5+',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(1.5+2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(1.5+2.',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(1.5+2.5',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(1.5+2.5)',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(1.5+2.5)×',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(1.5+2.5)×3',
            ),
          ]),
        );
      });

      test('clear and rebuild expression with parentheses', () async {
        // First expression: (5+3)
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const NumericPressed('5')); // (5
        bloc.add(const OperatorPressed('+')); // (5+
        bloc.add(const NumericPressed('3')); // (5+3
        bloc.add(const ParenthesisPressed()); // (5+3)
        // Clear and start new expression: (2×4)
        bloc.add(const ClearPressed());
        bloc.add(const ParenthesisPressed()); // ( - should be ( due to reset
        bloc.add(const NumericPressed('2')); // (2
        bloc.add(const OperatorPressed('×')); // (2×
        bloc.add(const NumericPressed('4')); // (2×4
        bloc.add(const ParenthesisPressed()); // (2×4)

        await expectLater(
          bloc.stream,
          emitsInOrder([
            // First expression
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
            // After clear
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '',
            ),
            // Second expression - parenthesis should start with ( again
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(2×',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(2×4',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(2×4)',
            ),
          ]),
        );
      });
    });

    group('State properties after ParenthesisPressed', () {
      test('ParenthesisPressed clears result and error state', () async {
        bloc.add(const ParenthesisPressed());

        await expectLater(
          bloc.stream,
          emits(predicate<ExpressionDisplayState>(
            (state) =>
                state.result == null &&
                state.hasError == false &&
                state.errorMessage == null,
            'result should be null and error state should be cleared',
          )),
        );
      });

      test('cursor position is updated correctly after parenthesis insertion', () async {
        bloc.add(const ParenthesisPressed());
        bloc.add(const ParenthesisPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.cursorPosition == 1,
              'cursor should be at position 1 after first parenthesis',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.cursorPosition == 2,
              'cursor should be at position 2 after second parenthesis',
            ),
          ]),
        );
      });
    });

    group('Edge cases', () {
      test('backspace after parenthesis works correctly', () async {
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const BackspacePressed()); // empty

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '(',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '',
            ),
          ]),
        );
      });

      test('parenthesis after backspace continues toggle sequence', () async {
        bloc.add(const ParenthesisPressed()); // ( - toggles to )
        bloc.add(const BackspacePressed()); // empty - toggle still at )
        bloc.add(const ParenthesisPressed()); // ) - toggles to (

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
              (state) => state.expression.value == ')',
              'backspace does not reset toggle state',
            ),
          ]),
        );
      });

      test('mixed operators and parentheses', () async {
        bloc.add(const NumericPressed('1'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const NumericPressed('2'));
        bloc.add(const OperatorPressed('-'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const ParenthesisPressed()); // )

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1+',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1+(',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1+(2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1+(2-',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1+(2-3',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '1+(2-3)',
            ),
          ]),
        );
      });
    });
  });
}
