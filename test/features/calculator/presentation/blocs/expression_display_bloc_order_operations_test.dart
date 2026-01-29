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

  group('ExpressionDisplayBloc Order of Operations', () {
    group('AC1: Multiplication before Addition', () {
      test('emits state with result 14 when evaluating 2+3×4 (multiplication before addition)', () async {
        // Build expression: 2+3×4
        // Expected: 2 + (3×4) = 2 + 12 = 14
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
              (state) => state.expression.value == '2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2+',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2+3',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2+3×',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2+3×4',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.expression.value == '2+3×4' &&
                  state.result == '14' &&
                  state.isEvaluationError == false &&
                  state.hasError == false,
              'result should be 14 (multiplication before addition: 2+3×4 = 2+12 = 14)',
            ),
          ]),
        );
      });

      test('emits state with result 14 when evaluating 3×4+2 (multiplication first, then addition)', () async {
        // Build expression: 3×4+2
        // Expected: (3×4) + 2 = 12 + 2 = 14
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('2'));
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
              (state) => state.expression.value == '3×4',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3×4+',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '3×4+2',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.result == '14' &&
                  state.isEvaluationError == false,
              'result should be 14 (3×4+2 = 12+2 = 14)',
            ),
          ]),
        );
      });

      test('emits state with result 25 when evaluating 1+2×3+4×5-2 (multiple multiplications with additions)', () async {
        // Build expression: 1+2×3+4×5-2
        // Expected: 1 + (2×3) + (4×5) - 2 = 1 + 6 + 20 - 2 = 25
        bloc.add(const NumericPressed('1'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('-'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const EqualsPressed());

        // Wait for all states to be emitted
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(bloc.state.result, '25');
        expect(bloc.state.isEvaluationError, false);
      });
    });

    group('AC2: Division before Subtraction', () {
      test('emits state with result 8 when evaluating 10-4÷2 (division before subtraction)', () async {
        // Build expression: 10-4÷2
        // Expected: 10 - (4÷2) = 10 - 2 = 8
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('0'));
        bloc.add(const OperatorPressed('-'));
        bloc.add(const NumericPressed('4'));
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
              (state) => state.expression.value == '10-',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '10-4',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '10-4÷',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '10-4÷2',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.expression.value == '10-4÷2' &&
                  state.result == '8' &&
                  state.isEvaluationError == false &&
                  state.hasError == false,
              'result should be 8 (division before subtraction: 10-4÷2 = 10-2 = 8)',
            ),
          ]),
        );
      });

      test('emits state with result 3 when evaluating 20÷4-2 (division first, then subtraction)', () async {
        // Build expression: 20÷4-2
        // Expected: (20÷4) - 2 = 5 - 2 = 3
        bloc.add(const NumericPressed('2'));
        bloc.add(const NumericPressed('0'));
        bloc.add(const OperatorPressed('÷'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const OperatorPressed('-'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '20',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '20÷',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '20÷4',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '20÷4-',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '20÷4-2',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.result == '3' &&
                  state.isEvaluationError == false,
              'result should be 3 (20÷4-2 = 5-2 = 3)',
            ),
          ]),
        );
      });

      test('emits state with result 8 when evaluating 10-6÷2+1 (division before subtraction and addition)', () async {
        // Build expression: 10-6÷2+1
        // Expected: 10 - (6÷2) + 1 = 10 - 3 + 1 = 8
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('0'));
        bloc.add(const OperatorPressed('-'));
        bloc.add(const NumericPressed('6'));
        bloc.add(const OperatorPressed('÷'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('1'));
        bloc.add(const EqualsPressed());

        // Wait for all states to be emitted
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(bloc.state.result, '8');
        expect(bloc.state.isEvaluationError, false);
      });
    });

    group('AC3: Parentheses Priority', () {
      test('emits state with result 20 when evaluating (2+3)×4 (parentheses override default precedence)', () async {
        // Build expression: (2+3)×4
        // Expected: (2+3) × 4 = 5 × 4 = 20
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
                  state.expression.value == '(2+3)×4' &&
                  state.result == '20' &&
                  state.isEvaluationError == false &&
                  state.hasError == false,
              'result should be 20 (parentheses priority: (2+3)×4 = 5×4 = 20)',
            ),
          ]),
        );
      });

      test('emits state with result 24 when evaluating (10-4)÷2×8 (parentheses with division and multiplication)', () async {
        // Build expression: (10-4)÷2×8
        // Expected: ((10-4) ÷ 2) × 8 = (6 ÷ 2) × 8 = 3 × 8 = 24
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('0'));
        bloc.add(const OperatorPressed('-'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const ParenthesisPressed()); // )
        bloc.add(const OperatorPressed('÷'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NumericPressed('8'));
        bloc.add(const EqualsPressed());

        // Wait for all states to be emitted
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(bloc.state.result, '24');
        expect(bloc.state.isEvaluationError, false);
      });

      test('emits state with result 35 when evaluating (1+2)×(3+4)+14 (multiple parentheses groups)', () async {
        // Build expression: (1+2)×(3+4)+14
        // Expected: (1+2) × (3+4) + 14 = 3 × 7 + 14 = 21 + 14 = 35
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
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const EqualsPressed());

        // Wait for all states to be emitted
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(bloc.state.result, '35');
        expect(bloc.state.isEvaluationError, false);
      });

      test('emits state with result 2 when evaluating (8-2)÷3 (parentheses with division)', () async {
        // Build expression: (8-2)÷3
        // Expected: (8-2) ÷ 3 = 6 ÷ 3 = 2
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const NumericPressed('8'));
        bloc.add(const OperatorPressed('-'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const ParenthesisPressed()); // )
        bloc.add(const OperatorPressed('÷'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const EqualsPressed());

        // Wait for all states to be emitted
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(bloc.state.result, '2');
        expect(bloc.state.isEvaluationError, false);
      });
    });

    group('AC4: Exponent before Addition', () {
      test('emits state with result 9 when evaluating 2^3+1 (exponent before addition)', () async {
        // Build expression: 2^3+1
        // Expected: (2^3) + 1 = 8 + 1 = 9
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
                  state.expression.value == '2^3+1' &&
                  state.result == '9' &&
                  state.isEvaluationError == false &&
                  state.hasError == false,
              'result should be 9 (exponent before addition: 2^3+1 = 8+1 = 9)',
            ),
          ]),
        );
      });

      test('emits state with result 11 when evaluating 1+2^3+2 (exponent in middle of additions)', () async {
        // Build expression: 1+2^3+2
        // Expected: 1 + (2^3) + 2 = 1 + 8 + 2 = 11
        bloc.add(const NumericPressed('1'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const EqualsPressed());

        // Wait for all states to be emitted
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(bloc.state.result, '11');
        expect(bloc.state.isEvaluationError, false);
      });

      test('emits state with result 6 when evaluating 10-2^2 (exponent before subtraction)', () async {
        // Build expression: 10-2^2
        // Expected: 10 - (2^2) = 10 - 4 = 6
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('0'));
        bloc.add(const OperatorPressed('-'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('2'));
        bloc.add(const EqualsPressed());

        // Wait for all states to be emitted
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(bloc.state.result, '6');
        expect(bloc.state.isEvaluationError, false);
      });

      test('emits state with result 16 when evaluating 2^3×2 (exponent before multiplication)', () async {
        // Build expression: 2^3×2
        // Expected: (2^3) × 2 = 8 × 2 = 16
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const EqualsPressed());

        // Wait for all states to be emitted
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(bloc.state.result, '16');
        expect(bloc.state.isEvaluationError, false);
      });
    });

    group('AC5: Left-to-Right Evaluation of Same Precedence', () {
      test('emits state with result 5 when evaluating 10-3-2 (left-to-right subtraction)', () async {
        // Build expression: 10-3-2
        // Expected: (10-3) - 2 = 7 - 2 = 5 (left-to-right)
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('0'));
        bloc.add(const OperatorPressed('-'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('-'));
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
              (state) => state.expression.value == '10-',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '10-3',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '10-3-',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '10-3-2',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.result == '5' &&
                  state.isEvaluationError == false,
              'result should be 5 (left-to-right: (10-3)-2 = 7-2 = 5)',
            ),
          ]),
        );
      });

      test('emits state with result 2 when evaluating 20÷2÷5 (left-to-right division)', () async {
        // Build expression: 20÷2÷5
        // Expected: (20÷2) ÷ 5 = 10 ÷ 5 = 2 (left-to-right)
        bloc.add(const NumericPressed('2'));
        bloc.add(const NumericPressed('0'));
        bloc.add(const OperatorPressed('÷'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const OperatorPressed('÷'));
        bloc.add(const NumericPressed('5'));
        bloc.add(const EqualsPressed());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '20',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '20÷',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '20÷2',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '20÷2÷',
            ),
            predicate<ExpressionDisplayState>(
              (state) => state.expression.value == '20÷2÷5',
            ),
            predicate<ExpressionDisplayState>(
              (state) =>
                  state.result == '2' &&
                  state.isEvaluationError == false,
              'result should be 2 (left-to-right: (20÷2)÷5 = 10÷5 = 2)',
            ),
          ]),
        );
      });

      test('emits state with result 12 when evaluating 2×3×2 (left-to-right multiplication)', () async {
        // Build expression: 2×3×2
        // Expected: (2×3) × 2 = 6 × 2 = 12 (left-to-right)
        bloc.add(const NumericPressed('2'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const EqualsPressed());

        // Wait for all states to be emitted
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(bloc.state.result, '12');
        expect(bloc.state.isEvaluationError, false);
      });

      test('emits state with result 6 when evaluating 1+2+3 (left-to-right addition)', () async {
        // Build expression: 1+2+3
        // Expected: (1+2) + 3 = 3 + 3 = 6 (left-to-right)
        bloc.add(const NumericPressed('1'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const EqualsPressed());

        // Wait for all states to be emitted
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(bloc.state.result, '6');
        expect(bloc.state.isEvaluationError, false);
      });
    });

    group('Complex Order of Operations', () {
      test('emits state with result 17 when evaluating 10÷2+3×4 (mixed operators)', () async {
        // Build expression: 10÷2+3×4
        // Expected: (10÷2) + (3×4) = 5 + 12 = 17
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('0'));
        bloc.add(const OperatorPressed('÷'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const EqualsPressed());

        // Wait for all states to be emitted
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(bloc.state.result, '17');
        expect(bloc.state.isEvaluationError, false);
      });

      test('emits state with result 49 when evaluating (3+4)^2 (parentheses with exponent)', () async {
        // Build expression: (3+4)^2
        // Expected: (3+4)^2 = 7^2 = 49
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const ParenthesisPressed()); // )
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('2'));
        bloc.add(const EqualsPressed());

        // Wait for all states to be emitted
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(bloc.state.result, '49');
        expect(bloc.state.isEvaluationError, false);
      });

      test('emits state with result 256 when evaluating 2^2^3 (right-associative exponents)', () async {
        // Build expression: 2^2^3
        // Expected: 2^(2^3) = 2^8 = 256 (exponents are right-associative)
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('3'));
        bloc.add(const EqualsPressed());

        // Wait for all states to be emitted
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(bloc.state.result, '256');
        expect(bloc.state.isEvaluationError, false);
      });

      test('emits state with result 90 when evaluating 2^3+4×5+6^2+26 (complex expression)', () async {
        // Build expression: 2^3+4×5+6^2+26
        // Expected: (2^3) + (4×5) + (6^2) + 26 = 8 + 20 + 36 + 26 = 90
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('6'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('2'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const NumericPressed('6'));
        bloc.add(const EqualsPressed());

        // Wait for all states to be emitted
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(bloc.state.result, '90');
        expect(bloc.state.isEvaluationError, false);
      });
    });
  });
}
