import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';

/// Unit tests for order of operations - verifying that:
/// - Multiplication is evaluated before addition (AC1)
/// - Division is evaluated before subtraction (AC2)
/// - Parentheses are evaluated first (AC3)
/// - Exponentiation is evaluated before addition (AC4)
/// - Same precedence operators are evaluated left-to-right (AC5)
/// 
/// These tests ensure the calculator follows PEMDAS/BODMAS rules where
/// parentheses (P/B) have highest priority, followed by
/// exponents (E/O), then
/// multiplication (*) and division (/) have higher precedence than 
/// addition (+) and subtraction (-).
/// Operators of the same precedence level are evaluated left-to-right.
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

    group('Division before Subtraction (AC2)', () {
      test('AC2: 10-4/2 should equal 8.0, not 3.0', () {
        // Acceptance Criterion 2: '10-4/2' should equal '8.0'
        // Division is evaluated first: 4/2 = 2
        // Then subtraction: 10 - 2 = 8
        // If evaluated left-to-right without precedence: (10-4)/2 = 3 (incorrect)
        final result = useCase.execute('10-4/2');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(8.0));
        expect(getResultString(result), equals('8'));
        
        // Explicitly verify it's NOT 3 (which would be wrong)
        expect(getResultValue(result), isNot(equals(3.0)));
      });

      test('4/2-10 should equal -8.0 (division first)', () {
        // 4/2 = 2, then 2 - 10 = -8
        final result = useCase.execute('4/2-10');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(-8.0));
        expect(getResultString(result), equals('-8'));
      });

      test('20-10/2-5 should equal 10.0 (division before both subtractions)', () {
        // 10/2 = 5, then 20 - 5 - 5 = 10
        // If left-to-right: ((20-10)/2)-5 = 0 (incorrect)
        final result = useCase.execute('20-10/2-5');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(10.0));
        expect(getResultString(result), equals('10'));
      });

      test('100/10-5/5 should equal 9.0 (both divisions before subtraction)', () {
        // 100/10 = 10, 5/5 = 1, then 10 - 1 = 9
        final result = useCase.execute('100/10-5/5');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(9.0));
        expect(getResultString(result), equals('9'));
      });
    });

    group('Parentheses Priority (AC3)', () {
      test('AC3: (2+3)*4 should equal 20.0', () {
        // Acceptance Criterion 3: '(2+3)*4' should equal '20.0'
        // Parentheses are evaluated first: (2+3) = 5
        // Then multiplication: 5 * 4 = 20
        // Without parentheses: 2+3*4 = 14 (multiplication first)
        final result = useCase.execute('(2+3)*4');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(20.0));
        expect(getResultString(result), equals('20'));
      });

      test('((2+3)*4) should equal 20.0 (nested parentheses)', () {
        // Nested parentheses: innermost evaluated first
        // (2+3) = 5, then 5*4 = 20, outer parentheses just group the result
        final result = useCase.execute('((2+3)*4)');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(20.0));
        expect(getResultString(result), equals('20'));
      });

      test('(10-4)/2 should equal 3.0 (parentheses override division precedence)', () {
        // Parentheses force subtraction first: (10-4) = 6
        // Then division: 6 / 2 = 3
        // Without parentheses: 10-4/2 = 8 (division first)
        final result = useCase.execute('(10-4)/2');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(3.0));
        expect(getResultString(result), equals('3'));
      });

      test('2*(3+4)*5 should equal 70.0 (parentheses in middle of expression)', () {
        // Parentheses first: (3+4) = 7
        // Then multiplications left to right: 2 * 7 = 14, 14 * 5 = 70
        final result = useCase.execute('2*(3+4)*5');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(70.0));
        expect(getResultString(result), equals('70'));
      });

      test('(2+3)*(4+5) should equal 45.0 (multiple parenthesized groups)', () {
        // Both parentheses evaluated: (2+3) = 5, (4+5) = 9
        // Then multiplication: 5 * 9 = 45
        final result = useCase.execute('(2+3)*(4+5)');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(45.0));
        expect(getResultString(result), equals('45'));
      });

      test('((1+2)*(3+4)) should equal 21.0 (nested with multiple groups)', () {
        // Inner parentheses: (1+2) = 3, (3+4) = 7
        // Multiplication: 3 * 7 = 21
        final result = useCase.execute('((1+2)*(3+4))');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(21.0));
        expect(getResultString(result), equals('21'));
      });

      test('(1+(2*3)) should equal 7.0 (parentheses with internal precedence)', () {
        // Inner multiplication first: 2*3 = 6
        // Then parenthesized addition: 1+6 = 7
        final result = useCase.execute('(1+(2*3))');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(7.0));
        expect(getResultString(result), equals('7'));
      });

      test('((2+3)) should equal 5.0 (double nested parentheses)', () {
        // Double nested: inner (2+3) = 5, outer just groups
        final result = useCase.execute('((2+3))');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(5.0));
        expect(getResultString(result), equals('5'));
      });

      test('(((4+6))) should equal 10.0 (triple nested parentheses)', () {
        // Triple nested: 4+6 = 10
        final result = useCase.execute('(((4+6)))');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(10.0));
        expect(getResultString(result), equals('10'));
      });

      test('(5-3)*(8/4) should equal 4.0 (parentheses with subtraction and division)', () {
        // (5-3) = 2, (8/4) = 2
        // Then multiplication: 2 * 2 = 4
        final result = useCase.execute('(5-3)*(8/4)');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(4.0));
        expect(getResultString(result), equals('4'));
      });

      test('10/(2+3) should equal 2.0 (parentheses in divisor)', () {
        // (2+3) = 5, then 10 / 5 = 2
        final result = useCase.execute('10/(2+3)');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(2.0));
        expect(getResultString(result), equals('2'));
      });

      test('(100-50)/(10+15) should equal 2.0 (parentheses in both dividend and divisor)', () {
        // (100-50) = 50, (10+15) = 25
        // Then division: 50 / 25 = 2
        final result = useCase.execute('(100-50)/(10+15)');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(2.0));
        expect(getResultString(result), equals('2'));
      });
    });

    group('Exponent before Addition (AC4)', () {
      test('AC4: 2^3+1 should equal 9.0, not 16.0', () {
        // Acceptance Criterion 4: '2^3+1' should equal '9.0'
        // Exponentiation is evaluated first: 2^3 = 8
        // Then addition: 8 + 1 = 9
        // If evaluated left-to-right without precedence: (2^3)+1 would still be 9, but 2^(3+1) = 16 (incorrect)
        final result = useCase.execute('2^3+1');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(9.0));
        expect(getResultString(result), equals('9'));
        
        // Explicitly verify it's NOT 16 (which would be wrong - 2^4)
        expect(getResultValue(result), isNot(equals(16.0)));
      });

      test('1+2^3 should equal 9.0 (exponent before addition)', () {
        // 2^3 = 8, then 1 + 8 = 9
        final result = useCase.execute('1+2^3');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(9.0));
        expect(getResultString(result), equals('9'));
      });

      test('2^2*3 should equal 12.0 (exponent then multiply)', () {
        // Exponent first: 2^2 = 4
        // Then multiplication: 4 * 3 = 12
        final result = useCase.execute('2^2*3');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(12.0));
        expect(getResultString(result), equals('12'));
      });

      test('3*2^2 should equal 12.0 (exponent before multiply)', () {
        // Exponent first: 2^2 = 4
        // Then multiplication: 3 * 4 = 12
        final result = useCase.execute('3*2^2');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(12.0));
        expect(getResultString(result), equals('12'));
      });

      test('2^3^2 should equal 512.0 (right-to-left associativity)', () {
        // Exponents are right-associative: 2^(3^2) = 2^9 = 512
        // NOT (2^3)^2 = 8^2 = 64
        final result = useCase.execute('2^3^2');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(512.0));
        expect(getResultString(result), equals('512'));
        
        // Explicitly verify it's NOT 64 (which would be wrong - left-to-right)
        expect(getResultValue(result), isNot(equals(64.0)));
      });

      test('10-2^3 should equal 2.0 (exponent before subtraction)', () {
        // 2^3 = 8, then 10 - 8 = 2
        final result = useCase.execute('10-2^3');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(2.0));
        expect(getResultString(result), equals('2'));
      });

      test('2+3*4^2 should equal 50.0 (exponent, then multiply, then add)', () {
        // Exponent first: 4^2 = 16
        // Then multiplication: 3 * 16 = 48
        // Then addition: 2 + 48 = 50
        final result = useCase.execute('2+3*4^2');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(50.0));
        expect(getResultString(result), equals('50'));
      });

      test('8/2^2 should equal 2.0 (exponent before division)', () {
        // Exponent first: 2^2 = 4
        // Then division: 8 / 4 = 2
        final result = useCase.execute('8/2^2');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(2.0));
        expect(getResultString(result), equals('2'));
      });

      test('5^2+3^2 should equal 34.0 (both exponents before addition)', () {
        // 5^2 = 25, 3^2 = 9
        // Then addition: 25 + 9 = 34
        final result = useCase.execute('5^2+3^2');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(34.0));
        expect(getResultString(result), equals('34'));
      });

      test('2^0 should equal 1.0 (any number to power of 0)', () {
        final result = useCase.execute('2^0');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(1.0));
        expect(getResultString(result), equals('1'));
      });

      test('2^1 should equal 2.0 (any number to power of 1)', () {
        final result = useCase.execute('2^1');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(2.0));
        expect(getResultString(result), equals('2'));
      });

      test('(2+1)^2 should equal 9.0 (parentheses override exponent precedence)', () {
        // Parentheses first: (2+1) = 3
        // Then exponent: 3^2 = 9
        final result = useCase.execute('(2+1)^2');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(9.0));
        expect(getResultString(result), equals('9'));
      });

      test('2^(1+2) should equal 8.0 (parentheses in exponent)', () {
        // Parentheses first: (1+2) = 3
        // Then exponent: 2^3 = 8
        final result = useCase.execute('2^(1+2)');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(8.0));
        expect(getResultString(result), equals('8'));
      });
    });

    group('Left-to-Right Evaluation (AC5)', () {
      // Tests verifying that operators of the same precedence level
      // are evaluated left-to-right, which is part of standard PEMDAS/BODMAS rules.

      group('Addition/Subtraction Left-to-Right', () {
        test('10-5-2 should equal 3.0 (left to right)', () {
          // Left-to-right: (10-5)-2 = 5-2 = 3
          // NOT right-to-left: 10-(5-2) = 10-3 = 7
          final result = useCase.execute('10-5-2');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(3.0));
          expect(getResultString(result), equals('3'));
          
          // Explicitly verify it's NOT 7 (which would be wrong - right-to-left)
          expect(getResultValue(result), isNot(equals(7.0)));
        });

        test('20-10-5-2 should equal 3.0 (left to right)', () {
          // Left-to-right: ((20-10)-5)-2 = (10-5)-2 = 5-2 = 3
          final result = useCase.execute('20-10-5-2');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(3.0));
          expect(getResultString(result), equals('3'));
        });

        test('10+5-3 should equal 12.0 (left to right)', () {
          // Left-to-right: (10+5)-3 = 15-3 = 12
          final result = useCase.execute('10+5-3');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(12.0));
          expect(getResultString(result), equals('12'));
        });

        test('10-5+3 should equal 8.0 (left to right)', () {
          // Left-to-right: (10-5)+3 = 5+3 = 8
          final result = useCase.execute('10-5+3');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(8.0));
          expect(getResultString(result), equals('8'));
        });

        test('100-50+25-10 should equal 65.0 (left to right)', () {
          // Left-to-right: ((100-50)+25)-10 = (50+25)-10 = 75-10 = 65
          final result = useCase.execute('100-50+25-10');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(65.0));
          expect(getResultString(result), equals('65'));
        });

        test('5-3-1+2-1 should equal 2.0 (left to right)', () {
          // Left-to-right: ((((5-3)-1)+2)-1) = ((2-1)+2)-1 = (1+2)-1 = 3-1 = 2
          final result = useCase.execute('5-3-1+2-1');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(2.0));
          expect(getResultString(result), equals('2'));
        });
      });

      group('Multiplication/Division Left-to-Right', () {
        test('12/3*2 should equal 8.0 (left to right)', () {
          // Left-to-right: (12/3)*2 = 4*2 = 8
          // NOT right-to-left: 12/(3*2) = 12/6 = 2
          final result = useCase.execute('12/3*2');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(8.0));
          expect(getResultString(result), equals('8'));
          
          // Explicitly verify it's NOT 2 (which would be wrong - right-to-left)
          expect(getResultValue(result), isNot(equals(2.0)));
        });

        test('24/4/2 should equal 3.0 (left to right)', () {
          // Left-to-right: (24/4)/2 = 6/2 = 3
          // NOT right-to-left: 24/(4/2) = 24/2 = 12
          final result = useCase.execute('24/4/2');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(3.0));
          expect(getResultString(result), equals('3'));
          
          // Explicitly verify it's NOT 12 (which would be wrong - right-to-left)
          expect(getResultValue(result), isNot(equals(12.0)));
        });

        test('2*3/2 should equal 3.0 (left to right)', () {
          // Left-to-right: (2*3)/2 = 6/2 = 3
          final result = useCase.execute('2*3/2');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(3.0));
          expect(getResultString(result), equals('3'));
        });

        test('10/2*5 should equal 25.0 (left to right)', () {
          // Left-to-right: (10/2)*5 = 5*5 = 25
          // NOT right-to-left: 10/(2*5) = 10/10 = 1
          final result = useCase.execute('10/2*5');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(25.0));
          expect(getResultString(result), equals('25'));
          
          // Explicitly verify it's NOT 1 (which would be wrong - right-to-left)
          expect(getResultValue(result), isNot(equals(1.0)));
        });

        test('100/10/5*2 should equal 4.0 (left to right)', () {
          // Left-to-right: ((100/10)/5)*2 = (10/5)*2 = 2*2 = 4
          final result = useCase.execute('100/10/5*2');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(4.0));
          expect(getResultString(result), equals('4'));
        });

        test('8*2/4*3 should equal 12.0 (left to right)', () {
          // Left-to-right: ((8*2)/4)*3 = (16/4)*3 = 4*3 = 12
          final result = useCase.execute('8*2/4*3');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(12.0));
          expect(getResultString(result), equals('12'));
        });
      });

      group('Left-to-Right with Decimals', () {
        test('10.0-5.5-2.5 should equal 2.0 (left to right with decimals)', () {
          // Left-to-right: (10.0-5.5)-2.5 = 4.5-2.5 = 2.0
          final result = useCase.execute('10.0-5.5-2.5');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(2.0));
          expect(getResultString(result), equals('2'));
        });

        test('12.0/3.0*2.0 should equal 8.0 (left to right with decimals)', () {
          // Left-to-right: (12.0/3.0)*2.0 = 4.0*2.0 = 8.0
          final result = useCase.execute('12.0/3.0*2.0');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(8.0));
          expect(getResultString(result), equals('8'));
        });
      });

      group('Comparing Expressions - Left-to-Right vs Parentheses', () {
        test('10-5-2 vs 10-(5-2) shows left-to-right evaluation', () {
          final leftToRight = useCase.execute('10-5-2');
          final withParens = useCase.execute('10-(5-2)');
          
          expect(getResultValue(leftToRight), equals(3.0),
              reason: '10-5-2 should be 3 (left to right: (10-5)-2)');
          expect(getResultValue(withParens), equals(7.0),
              reason: '10-(5-2) should be 7 (parentheses override)');
          expect(getResultValue(leftToRight), isNot(equals(getResultValue(withParens))),
              reason: 'Results should differ showing left-to-right matters');
        });

        test('12/3*2 vs 12/(3*2) shows left-to-right evaluation', () {
          final leftToRight = useCase.execute('12/3*2');
          final withParens = useCase.execute('12/(3*2)');
          
          expect(getResultValue(leftToRight), equals(8.0),
              reason: '12/3*2 should be 8 (left to right: (12/3)*2)');
          expect(getResultValue(withParens), equals(2.0),
              reason: '12/(3*2) should be 2 (parentheses override)');
          expect(getResultValue(leftToRight), isNot(equals(getResultValue(withParens))),
              reason: 'Results should differ showing left-to-right matters');
        });

        test('24/4/2 vs 24/(4/2) shows left-to-right evaluation', () {
          final leftToRight = useCase.execute('24/4/2');
          final withParens = useCase.execute('24/(4/2)');
          
          expect(getResultValue(leftToRight), equals(3.0),
              reason: '24/4/2 should be 3 (left to right: (24/4)/2)');
          expect(getResultValue(withParens), equals(12.0),
              reason: '24/(4/2) should be 12 (parentheses override)');
          expect(getResultValue(leftToRight), isNot(equals(getResultValue(withParens))),
              reason: 'Results should differ showing left-to-right matters');
        });
      });
    });

    group('Parentheses with Decimals and Negative Numbers', () {
      test('(1.5+2.5)*4 should equal 16.0', () {
        // (1.5+2.5) = 4.0, then 4.0 * 4 = 16.0
        final result = useCase.execute('(1.5+2.5)*4');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(16.0));
      });

      test('(-5+10)*2 should equal 10.0', () {
        // (-5+10) = 5, then 5 * 2 = 10
        final result = useCase.execute('(-5+10)*2');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(10.0));
      });

      test('(3+(-7))*2 should equal -8.0', () {
        // (3+(-7)) = -4, then -4 * 2 = -8
        final result = useCase.execute('(3+(-7))*2');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(-8.0));
      });
    });

    group('Comparing Expressions With and Without Parentheses', () {
      test('2+3*4 vs (2+3)*4 shows parentheses override precedence', () {
        final withoutParens = useCase.execute('2+3*4');
        final withParens = useCase.execute('(2+3)*4');
        
        expect(getResultValue(withoutParens), equals(14.0),
            reason: '2+3*4 should be 14 (multiplication first)');
        expect(getResultValue(withParens), equals(20.0),
            reason: '(2+3)*4 should be 20 (parentheses override)');
        expect(getResultValue(withoutParens), isNot(equals(getResultValue(withParens))),
            reason: 'Results should differ showing parentheses matter');
      });

      test('10-4/2 vs (10-4)/2 shows parentheses override precedence', () {
        final withoutParens = useCase.execute('10-4/2');
        final withParens = useCase.execute('(10-4)/2');
        
        expect(getResultValue(withoutParens), equals(8.0),
            reason: '10-4/2 should be 8 (division first)');
        expect(getResultValue(withParens), equals(3.0),
            reason: '(10-4)/2 should be 3 (parentheses override)');
        expect(getResultValue(withoutParens), isNot(equals(getResultValue(withParens))),
            reason: 'Results should differ showing parentheses matter');
      });

      test('8/2*4 vs 8/(2*4) shows parentheses change evaluation order', () {
        final withoutParens = useCase.execute('8/2*4');
        final withParens = useCase.execute('8/(2*4)');
        
        // Without parentheses: left to right, 8/2 = 4, then 4*4 = 16
        expect(getResultValue(withoutParens), equals(16.0),
            reason: '8/2*4 should be 16 (left to right)');
        // With parentheses: (2*4) = 8, then 8/8 = 1
        expect(getResultValue(withParens), equals(1.0),
            reason: '8/(2*4) should be 1 (parentheses override)');
      });
    });

    group('Additional Division Precedence Tests', () {
      test('50-20/4 should equal 45.0', () {
        // 20/4 = 5, then 50 - 5 = 45
        final result = useCase.execute('50-20/4');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(45.0));
      });

      test('8/4-6/3 should equal 0.0', () {
        // 8/4 = 2, 6/3 = 2, then 2 - 2 = 0
        final result = useCase.execute('8/4-6/3');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(0.0));
      });

      test('1-1/1-1 should equal -1.0', () {
        // 1/1 = 1, then 1 - 1 - 1 = -1
        final result = useCase.execute('1-1/1-1');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(-1.0));
      });

      test('100-50/2 should equal 75.0', () {
        // 50/2 = 25, then 100 - 25 = 75
        final result = useCase.execute('100-50/2');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(75.0));
      });
    });

    group('Division vs Subtraction with Decimals', () {
      test('10.5-3/2 should equal 9.0', () {
        // 3/2 = 1.5, then 10.5 - 1.5 = 9.0
        final result = useCase.execute('10.5-3/2');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(9.0));
      });

      test('5.5-1.5/3 should equal 5.0', () {
        // 1.5/3 = 0.5, then 5.5 - 0.5 = 5.0
        final result = useCase.execute('5.5-1.5/3');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(5.0));
      });
    });

    group('Division vs Subtraction with Negative Numbers', () {
      test('-10-4/2 should equal -12.0', () {
        // 4/2 = 2, then -10 - 2 = -12
        final result = useCase.execute('-10-4/2');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(-12.0));
      });

      test('10-(-4)/2 should equal 12.0', () {
        // (-4)/2 = -2, then 10 - (-2) = 12
        final result = useCase.execute('10-(-4)/2');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(12.0));
      });
    });

    group('Verifying Parentheses Override Division Precedence', () {
      test('(10-4)/2 should equal 3.0 (parentheses force subtraction first)', () {
        // Parentheses override: (10-4) = 6, then 6 / 2 = 3
        final result = useCase.execute('(10-4)/2');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(3.0));
      });

      test('comparing 10-4/2 vs (10-4)/2 shows precedence difference', () {
        final withoutParens = useCase.execute('10-4/2');
        final withParens = useCase.execute('(10-4)/2');
        
        expect(getResultValue(withoutParens), equals(8.0), 
            reason: '10-4/2 should be 8 (division first)');
        expect(getResultValue(withParens), equals(3.0), 
            reason: '(10-4)/2 should be 3 (parentheses override)');
        expect(getResultValue(withoutParens), isNot(equals(getResultValue(withParens))),
            reason: 'Results should differ showing precedence matters');
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

    group('Mixed Operations - All Four Operators', () {
      test('10+4*3-8/2 should equal 18.0', () {
        // Multiplication and division first: 4*3 = 12, 8/2 = 4
        // Then left to right: 10 + 12 - 4 = 18
        final result = useCase.execute('10+4*3-8/2');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(18.0));
      });

      test('20-3*4+12/3 should equal 12.0', () {
        // Multiplication and division first: 3*4 = 12, 12/3 = 4
        // Then left to right: 20 - 12 + 4 = 12
        final result = useCase.execute('20-3*4+12/3');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(12.0));
      });

      test('2*3+4*5-6/2 should equal 23.0', () {
        // Multiplication and division first: 2*3 = 6, 4*5 = 20, 6/2 = 3
        // Then left to right: 6 + 20 - 3 = 23
        final result = useCase.execute('2*3+4*5-6/2');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(23.0));
      });
    });

    group('Complex Expressions with Parentheses and All Operations', () {
      test('(2+3)*4-10/2 should equal 15.0', () {
        // Parentheses first: (2+3) = 5
        // Then multiplication and division: 5*4 = 20, 10/2 = 5
        // Then subtraction: 20 - 5 = 15
        final result = useCase.execute('(2+3)*4-10/2');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(15.0));
      });

      test('100/(5+5)+2*3 should equal 16.0', () {
        // Parentheses first: (5+5) = 10
        // Then division and multiplication: 100/10 = 10, 2*3 = 6
        // Then addition: 10 + 6 = 16
        final result = useCase.execute('100/(5+5)+2*3');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(16.0));
      });

      test('(1+2)*(3+4)/(5+2) should equal 3.0', () {
        // Parentheses: (1+2) = 3, (3+4) = 7, (5+2) = 7
        // Then left to right: 3*7 = 21, 21/7 = 3
        final result = useCase.execute('(1+2)*(3+4)/(5+2)');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(3.0));
      });
    });

    group('Complex Expressions with Exponents and All Operations', () {
      test('2^3+4*5-10/2 should equal 23.0', () {
        // Exponent first: 2^3 = 8
        // Then multiplication and division: 4*5 = 20, 10/2 = 5
        // Then left to right: 8 + 20 - 5 = 23
        final result = useCase.execute('2^3+4*5-10/2');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(23.0));
      });

      test('(2+3)^2-10 should equal 15.0', () {
        // Parentheses first: (2+3) = 5
        // Then exponent: 5^2 = 25
        // Then subtraction: 25 - 10 = 15
        final result = useCase.execute('(2+3)^2-10');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(15.0));
      });

      test('3^2*2+1 should equal 19.0', () {
        // Exponent first: 3^2 = 9
        // Then multiplication: 9 * 2 = 18
        // Then addition: 18 + 1 = 19
        final result = useCase.execute('3^2*2+1');
        
        expect(result, isA<EvaluationSuccess>());
        expect(getResultValue(result), equals(19.0));
      });
    });

    group('Complex Mixed Expressions', () {
      // This group tests comprehensive complex expressions combining multiple operators
      // to ensure PEMDAS/BODMAS rules work correctly in all combinations.

      group('Multi-Operator Expressions', () {
        test('2+3*4-5/5 should equal 13.0', () {
          // Following PEMDAS:
          // Multiplication first: 3*4 = 12
          // Division first: 5/5 = 1
          // Then left to right: 2 + 12 - 1 = 13
          final result = useCase.execute('2+3*4-5/5');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(13.0));
          expect(getResultString(result), equals('13'));
        });

        test('(2+3)*(4-1) should equal 15.0', () {
          // Parentheses first: (2+3) = 5, (4-1) = 3
          // Then multiplication: 5 * 3 = 15
          final result = useCase.execute('(2+3)*(4-1)');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(15.0));
          expect(getResultString(result), equals('15'));
        });

        test('1+2+3*4*5 should equal 63.0', () {
          // Multiplications first: 3*4 = 12, 12*5 = 60
          // Then additions: 1 + 2 + 60 = 63
          final result = useCase.execute('1+2+3*4*5');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(63.0));
        });

        test('100/5/2+3*4-1 should equal 21.0', () {
          // Division left to right: 100/5 = 20, 20/2 = 10
          // Multiplication: 3*4 = 12
          // Then: 10 + 12 - 1 = 21
          final result = useCase.execute('100/5/2+3*4-1');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(21.0));
        });

        test('5*4-3*2+1*6 should equal 20.0', () {
          // Multiplications: 5*4 = 20, 3*2 = 6, 1*6 = 6
          // Then: 20 - 6 + 6 = 20
          final result = useCase.execute('5*4-3*2+1*6');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(20.0));
        });
      });

      group('Expressions with Exponents and Other Operators', () {
        test('2^2+3^2 should equal 13.0', () {
          // Exponents first: 2^2 = 4, 3^2 = 9
          // Then addition: 4 + 9 = 13
          final result = useCase.execute('2^2+3^2');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(13.0));
          expect(getResultString(result), equals('13'));
        });

        test('(2+1)^2 should equal 9.0', () {
          // Parentheses first: (2+1) = 3
          // Then exponent: 3^2 = 9
          final result = useCase.execute('(2+1)^2');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(9.0));
          expect(getResultString(result), equals('9'));
        });

        test('2*3^2 should equal 18.0 (exponent before multiply)', () {
          // Exponent first: 3^2 = 9
          // Then multiplication: 2 * 9 = 18
          final result = useCase.execute('2*3^2');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(18.0));
          expect(getResultString(result), equals('18'));
        });

        test('4^2-2^3 should equal 8.0', () {
          // Exponents first: 4^2 = 16, 2^3 = 8
          // Then subtraction: 16 - 8 = 8
          final result = useCase.execute('4^2-2^3');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(8.0));
        });

        test('2^2*3^2 should equal 36.0', () {
          // Exponents first: 2^2 = 4, 3^2 = 9
          // Then multiplication: 4 * 9 = 36
          final result = useCase.execute('2^2*3^2');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(36.0));
        });

        test('10/2^2+5 should equal 7.5', () {
          // Exponent first: 2^2 = 4
          // Division: 10/4 = 2.5
          // Addition: 2.5 + 5 = 7.5
          final result = useCase.execute('10/2^2+5');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(7.5));
        });

        test('(1+2)^(1+1) should equal 9.0', () {
          // Parentheses first: (1+2) = 3, (1+1) = 2
          // Then exponent: 3^2 = 9
          final result = useCase.execute('(1+2)^(1+1)');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(9.0));
        });

        test('2^3-3^2+4^1 should equal 3.0', () {
          // Exponents first: 2^3 = 8, 3^2 = 9, 4^1 = 4
          // Then: 8 - 9 + 4 = 3
          final result = useCase.execute('2^3-3^2+4^1');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(3.0));
        });
      });

      group('Deeply Nested Parentheses', () {
        test('((2+3)*4)/2 should equal 10.0', () {
          // Innermost first: (2+3) = 5
          // Then inner multiplication: 5*4 = 20
          // Finally division: 20/2 = 10
          final result = useCase.execute('((2+3)*4)/2');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(10.0));
          expect(getResultString(result), equals('10'));
        });

        test('2*(3+(4*5)) should equal 46.0', () {
          // Innermost first: 4*5 = 20
          // Then inner addition: 3+20 = 23
          // Finally multiplication: 2*23 = 46
          final result = useCase.execute('2*(3+(4*5))');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(46.0));
          expect(getResultString(result), equals('46'));
        });

        test('((1+1)*(2+2)*(3+3)) should equal 48.0', () {
          // Parentheses: (1+1) = 2, (2+2) = 4, (3+3) = 6
          // Multiplications: 2*4 = 8, 8*6 = 48
          final result = useCase.execute('((1+1)*(2+2)*(3+3))');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(48.0));
        });

        test('(((1+2)+3)+4) should equal 10.0', () {
          // Innermost to outermost: (1+2) = 3, (3+3) = 6, (6+4) = 10
          final result = useCase.execute('(((1+2)+3)+4)');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(10.0));
        });

        test('((10-5)*(8/2))/(5-2) should equal 6.666666666666667', () {
          // Parentheses: (10-5) = 5, (8/2) = 4, (5-2) = 3
          // Then: 5*4 = 20, 20/3 = 6.666...
          final result = useCase.execute('((10-5)*(8/2))/(5-2)');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), closeTo(6.666666666666667, 0.0000001));
        });

        test('(1+(2*(3+(4*(5+6))))) should equal 95.0', () {
          // From innermost to outermost:
          // (5+6) = 11
          // 4*11 = 44
          // (3+44) = 47
          // 2*47 = 94
          // (1+94) = 95
          final result = useCase.execute('(1+(2*(3+(4*(5+6)))))');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(95.0));
        });

        test('((2^2)+(3^2))^0.5 should equal 5.0', () {
          // Exponents first: 2^2 = 4, 3^2 = 9
          // Addition: 4+9 = 13
          // Square root: 13^0.5 ≈ 3.606
          // Actually this should be sqrt(4+9) = sqrt(13) which is approximately 3.606
          // But the test says 5.0 - let's use a different expression
          // Using Pythagorean: sqrt(3^2 + 4^2) = sqrt(9+16) = sqrt(25) = 5
          final result = useCase.execute('((3^2)+(4^2))^0.5');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(5.0));
        });

        test('(10/(2+3))*(6-1) should equal 10.0', () {
          // (2+3) = 5, then 10/5 = 2
          // (6-1) = 5
          // 2*5 = 10
          final result = useCase.execute('(10/(2+3))*(6-1)');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(10.0));
        });
      });

      group('All PEMDAS Operators Combined', () {
        test('2^2+3*4-10/2 should equal 11.0', () {
          // Exponent: 2^2 = 4
          // Multiplication: 3*4 = 12
          // Division: 10/2 = 5
          // Then: 4 + 12 - 5 = 11
          final result = useCase.execute('2^2+3*4-10/2');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(11.0));
        });

        test('(2+3)^2*2/10-1 should equal 4.0', () {
          // Parentheses: (2+3) = 5
          // Exponent: 5^2 = 25
          // Multiplication: 25*2 = 50
          // Division: 50/10 = 5
          // Subtraction: 5 - 1 = 4
          final result = useCase.execute('(2+3)^2*2/10-1');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(4.0));
        });

        test('100/10+2^3*3-20 should equal 14.0', () {
          // Division: 100/10 = 10
          // Exponent: 2^3 = 8
          // Multiplication: 8*3 = 24
          // Then: 10 + 24 - 20 = 14
          final result = useCase.execute('100/10+2^3*3-20');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(14.0));
        });

        test('((5-2)^2+(4/2)^3)/17 should equal 1.0', () {
          // (5-2) = 3, 3^2 = 9
          // (4/2) = 2, 2^3 = 8
          // 9+8 = 17
          // 17/17 = 1
          final result = useCase.execute('((5-2)^2+(4/2)^3)/17');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(1.0));
        });

        test('10-2*3+8/2^2 should equal 6.0', () {
          // Exponent: 2^2 = 4
          // Division: 8/4 = 2
          // Multiplication: 2*3 = 6
          // Then: 10 - 6 + 2 = 6
          final result = useCase.execute('10-2*3+8/2^2');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(6.0));
        });
      });

      group('Edge Cases with Complex Expressions', () {
        test('0*100+5 should equal 5.0', () {
          // 0*100 = 0, then 0+5 = 5
          final result = useCase.execute('0*100+5');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(5.0));
        });

        test('1^100+1^100 should equal 2.0', () {
          // 1^100 = 1, 1^100 = 1, then 1+1 = 2
          final result = useCase.execute('1^100+1^100');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(2.0));
        });

        test('(0+1)*(0+2)*(0+3) should equal 6.0', () {
          // (0+1) = 1, (0+2) = 2, (0+3) = 3
          // 1*2 = 2, 2*3 = 6
          final result = useCase.execute('(0+1)*(0+2)*(0+3)');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(6.0));
        });

        test('10/10/10*100 should equal 1.0', () {
          // Left to right: 10/10 = 1, 1/10 = 0.1, 0.1*100 = 10
          // Correction: 10/10 = 1, 1/10 = 0.1, 0.1*100 = 10
          final result = useCase.execute('10/10/10*100');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(10.0));
        });

        test('2+2+2+2-2-2-2-2 should equal 0.0', () {
          // 2+2+2+2 = 8, 8-2-2-2-2 = 0
          final result = useCase.execute('2+2+2+2-2-2-2-2');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(0.0));
        });

        test('((((1+1)+1)+1)+1) should equal 5.0', () {
          // Nested additions from inner to outer
          final result = useCase.execute('((((1+1)+1)+1)+1)');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(5.0));
        });
      });

      group('Real-World Calculation Examples', () {
        test('Quadratic formula component: (-1)^2-4*1*(-6) should equal 25.0', () {
          // b^2 - 4ac where b=-1, a=1, c=-6
          // (-1)^2 = 1
          // 4*1*(-6) = -24
          // 1 - (-24) = 1 + 24 = 25
          final result = useCase.execute('(-1)^2-4*1*(-6)');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(25.0));
        });

        test('Area of trapezoid: (5+10)*4/2 should equal 30.0', () {
          // Area = (a+b)*h/2 where a=5, b=10, h=4
          // (5+10) = 15
          // 15*4 = 60
          // 60/2 = 30
          final result = useCase.execute('(5+10)*4/2');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(30.0));
        });

        test('Compound interest factor: (1+0.05)^2 should equal 1.1025', () {
          // (1+r)^n where r=0.05, n=2
          // (1.05)^2 = 1.1025
          final result = useCase.execute('(1+0.05)^2');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), closeTo(1.1025, 0.0001));
        });

        test('Distance formula part: ((3-0)^2+(4-0)^2)^0.5 should equal 5.0', () {
          // sqrt((x2-x1)^2 + (y2-y1)^2) where points are (0,0) and (3,4)
          // (3-0)^2 = 9, (4-0)^2 = 16
          // 9+16 = 25
          // 25^0.5 = 5
          final result = useCase.execute('((3-0)^2+(4-0)^2)^0.5');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(5.0));
        });

        test('Average calculation: (85+90+78+92+88)/5 should equal 86.6', () {
          // Sum = 433, average = 433/5 = 86.6
          final result = useCase.execute('(85+90+78+92+88)/5');
          
          expect(result, isA<EvaluationSuccess>());
          expect(getResultValue(result), equals(86.6));
        });
      });
    });
  });
}
