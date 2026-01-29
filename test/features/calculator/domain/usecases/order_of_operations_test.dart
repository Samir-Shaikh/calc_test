import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';

/// Unit tests for order of operations - specifically verifying that 
/// multiplication is evaluated before addition (AC1).
/// 
/// These tests ensure the calculator follows PEMDAS/BODMAS rules where
/// multiplication (*) has higher precedence than addition (+).
void main() {
  late EvaluateExpressionUseCase useCase;

  setUp(() {
    useCase = EvaluateExpressionUseCase();
  });

  /// Helper function to get the numeric result from evaluation.
  double? getResultValue(EvaluationResult result) {
    return switch (result) {
      EvaluationSuccess() => result.value,
      _ => null,
    };
  }

  /// Helper function to get the formatted result string from evaluation.
  String getResultString(EvaluationResult result) {
    return switch (result) {
      EvaluationSuccess() => result.formattedValue,
      EvaluationInvalidInput() => 'Error',
      EvaluationDivisionByZero() => result.displayValue,
    };
  }

  group('Order of Operations Tests', () {
    group('Multiplication before Addition (AC1)', () {
      test('AC1: 2+3*4 should equal 14.0, not 20.0', () {
        // Acceptance Criterion 1: '2+3*4' should equal '14.0'
        // Multiplication is evaluated first: 3*4 = 12
        // Then addition: 2 + 12 = 14
        // If evaluated left-to-right without precedence: (2+3)*4 = 20 (incorrect)
        final result = useCase.execute('2+3*4');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(14.0));
        expect(getResultString(result), equals('14'));
        
        // Explicitly verify it's NOT 20 (which would be wrong)
        expect(getResultValue(result), isNot(equals(20.0)));
      });

      test('3*4+2 should equal 14.0 (multiplication first)', () {
        // 3*4 = 12, then 12 + 2 = 14
        final result = useCase.execute('3*4+2');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(14.0));
        expect(getResultString(result), equals('14'));
      });

      test('1+2*3+4 should equal 11.0 (multiplication before both additions)', () {
        // 2*3 = 6, then 1 + 6 + 4 = 11
        // If left-to-right: ((1+2)*3)+4 = 13 (incorrect)
        final result = useCase.execute('1+2*3+4');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(11.0));
        expect(getResultString(result), equals('11'));
      });

      test('5*2+3*4 should equal 22.0 (both multiplications before addition)', () {
        // 5*2 = 10, 3*4 = 12, then 10 + 12 = 22
        final result = useCase.execute('5*2+3*4');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(22.0));
        expect(getResultString(result), equals('22'));
      });
    });

    group('Additional Multiplication Precedence Tests', () {
      test('10+5*2 should equal 20.0', () {
        // 5*2 = 10, then 10 + 10 = 20
        final result = useCase.execute('10+5*2');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(20.0));
      });

      test('2*3+4*5 should equal 26.0', () {
        // 2*3 = 6, 4*5 = 20, then 6 + 20 = 26
        final result = useCase.execute('2*3+4*5');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(26.0));
      });

      test('1+1*1+1 should equal 3.0', () {
        // 1*1 = 1, then 1 + 1 + 1 = 3
        final result = useCase.execute('1+1*1+1');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(3.0));
      });

      test('0+3*4 should equal 12.0', () {
        // 3*4 = 12, then 0 + 12 = 12
        final result = useCase.execute('0+3*4');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(12.0));
      });

      test('100+10*10 should equal 200.0', () {
        // 10*10 = 100, then 100 + 100 = 200
        final result = useCase.execute('100+10*10');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(200.0));
      });
    });

    group('Multiplication vs Addition with Decimals', () {
      test('1.5+2*3 should equal 7.5', () {
        // 2*3 = 6, then 1.5 + 6 = 7.5
        final result = useCase.execute('1.5+2*3');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(7.5));
      });

      test('0.5+0.5*2 should equal 1.5', () {
        // 0.5*2 = 1, then 0.5 + 1 = 1.5
        final result = useCase.execute('0.5+0.5*2');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(1.5));
      });
    });

    group('Multiplication vs Addition with Negative Numbers', () {
      test('-1+2*3 should equal 5.0', () {
        // 2*3 = 6, then -1 + 6 = 5
        final result = useCase.execute('-1+2*3');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(5.0));
      });

      test('1+(-2)*3 should equal -5.0', () {
        // (-2)*3 = -6, then 1 + (-6) = -5
        final result = useCase.execute('1+(-2)*3');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(-5.0));
      });
    });

    group('Verifying Parentheses Override Multiplication Precedence', () {
      test('(2+3)*4 should equal 20.0 (parentheses force addition first)', () {
        // Parentheses override: (2+3) = 5, then 5 * 4 = 20
        final result = useCase.execute('(2+3)*4');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(20.0));
      });

      test('comparing 2+3*4 vs (2+3)*4 shows precedence difference', () {
        final withoutParens = useCase.execute('2+3*4');
        final withParens = useCase.execute('(2+3)*4');
        
        expect(getResultValue(withoutParens), equals(14.0), 
            reason: '2+3*4 should be 14 (multiplication first)');
        expect(getResultValue(withParens), equals(20.0), 
            reason: '(2+3)*4 should be 20 (parentheses override)');
        expect(getResultValue(withoutParens), isNot(equals(getResultValue(withParens))),
            reason: 'Results should differ showing precedence matters');
      });
    });

    group('Complex Expressions with Multiple Operations', () {
      test('1+2*3+4*5+6 should equal 33.0', () {
        // 2*3 = 6, 4*5 = 20, then 1 + 6 + 20 + 6 = 33
        final result = useCase.execute('1+2*3+4*5+6');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(33.0));
      });

      test('2*3+4*5+6*7 should equal 68.0', () {
        // 2*3 = 6, 4*5 = 20, 6*7 = 42, then 6 + 20 + 42 = 68
        final result = useCase.execute('2*3+4*5+6*7');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(68.0));
      });
    });
  });
}
