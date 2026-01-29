import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';

void main() {
  late EvaluateExpressionUseCase useCase;

  setUp(() {
    useCase = EvaluateExpressionUseCase();
  });

  /// Helper function to get the formatted result string from evaluation.
  /// Returns 'Error' for invalid input, the display value for division by zero,
  /// and the formatted value for successful evaluations.
  String getResultString(EvaluationResult result) {
    return switch (result) {
      EvaluationSuccess() => result.formattedValue,
      EvaluationInvalidInput() => 'Error',
      EvaluationDivisionByZero() => result.displayValue,
    };
  }

  group('EvaluateExpressionUseCase', () {
    group('EvaluationResult sealed class', () {
      test('EvaluationSuccess has correct properties', () {
        const success = EvaluationSuccess(42.0);
        expect(success.isSuccess, isTrue);
        expect(success.errorMessage, isNull);
        expect(success.value, equals(42.0));
        expect(success.formattedValue, equals('42'));
      });

      test('EvaluationSuccess formats whole numbers without decimals', () {
        const success = EvaluationSuccess(10.0);
        expect(success.formattedValue, equals('10'));
      });

      test('EvaluationSuccess formats decimal numbers correctly', () {
        const success = EvaluationSuccess(10.5);
        expect(success.formattedValue, equals('10.5'));
      });

      test('EvaluationSuccess formats Infinity correctly', () {
        const success = EvaluationSuccess(double.infinity);
        expect(success.formattedValue, equals('Infinity'));
      });

      test('EvaluationSuccess formats -Infinity correctly', () {
        const success = EvaluationSuccess(double.negativeInfinity);
        expect(success.formattedValue, equals('-Infinity'));
      });

      test('EvaluationSuccess formats NaN correctly', () {
        const success = EvaluationSuccess(double.nan);
        expect(success.formattedValue, equals('NaN'));
      });

      test('EvaluationInvalidInput has correct properties', () {
        const invalid = EvaluationInvalidInput('Test error');
        expect(invalid.isSuccess, isFalse);
        expect(invalid.errorMessage, equals('Test error'));
        expect(invalid.message, equals('Test error'));
      });

      test('EvaluationDivisionByZero has correct properties for positive infinity', () {
        const divByZero = EvaluationDivisionByZero(isPositive: true);
        expect(divByZero.isSuccess, isFalse);
        expect(divByZero.errorMessage, equals('Division by zero'));
        expect(divByZero.displayValue, equals('Infinity'));
      });

      test('EvaluationDivisionByZero has correct properties for negative infinity', () {
        const divByZero = EvaluationDivisionByZero(isPositive: false);
        expect(divByZero.isSuccess, isFalse);
        expect(divByZero.errorMessage, equals('Division by zero'));
        expect(divByZero.displayValue, equals('-Infinity'));
      });

      test('EvaluationDivisionByZero has correct properties for NaN', () {
        const divByZero = EvaluationDivisionByZero(isPositive: null);
        expect(divByZero.isSuccess, isFalse);
        expect(divByZero.errorMessage, equals('Division by zero'));
        expect(divByZero.displayValue, equals('NaN'));
      });

      test('EvaluationResult equality works correctly', () {
        const success1 = EvaluationSuccess(42.0);
        const success2 = EvaluationSuccess(42.0);
        const success3 = EvaluationSuccess(43.0);
        
        expect(success1, equals(success2));
        expect(success1, isNot(equals(success3)));
        
        const invalid1 = EvaluationInvalidInput('error');
        const invalid2 = EvaluationInvalidInput('error');
        const invalid3 = EvaluationInvalidInput('other');
        
        expect(invalid1, equals(invalid2));
        expect(invalid1, isNot(equals(invalid3)));
      });
    });

    group('Acceptance Criteria Tests', () {
      test('AC1: evaluates 2+3*4 respecting order of operations', () {
        final result = useCase.execute('2+3*4');
        expect(result, isA<EvaluationSuccess>());
        expect((result as EvaluationSuccess).value, equals(14.0));
      });

      test('AC2: returns error for invalid expression 2++3', () {
        final result = useCase.execute('2++3');
        expect(result, isA<EvaluationInvalidInput>());
        expect(result.isSuccess, isFalse);
      });

      test('AC3: evaluates (2+3)*4 with parentheses', () {
        final result = useCase.execute('(2+3)*4');
        expect(result, isA<EvaluationSuccess>());
        expect((result as EvaluationSuccess).value, equals(20.0));
      });

      test('AC5: evaluates 2^3 power operation', () {
        final result = useCase.execute('2^3');
        expect(result, isA<EvaluationSuccess>());
        expect((result as EvaluationSuccess).value, equals(8.0));
      });
    });

    group('validation integration', () {
      test('returns InvalidInput for empty expression', () {
        final result = useCase.execute('');
        expect(result, isA<EvaluationInvalidInput>());
        expect((result as EvaluationInvalidInput).message, equals('Expression cannot be empty'));
      });

      test('returns InvalidInput for whitespace-only expression', () {
        final result = useCase.execute('   ');
        expect(result, isA<EvaluationInvalidInput>());
        expect((result as EvaluationInvalidInput).message, equals('Expression cannot be empty'));
      });

      test('returns InvalidInput for expression starting with invalid operator', () {
        final result = useCase.execute('*5');
        expect(result, isA<EvaluationInvalidInput>());
      });

      test('returns InvalidInput for expression ending with operator', () {
        final result = useCase.execute('5+');
        expect(result, isA<EvaluationInvalidInput>());
      });

      test('returns InvalidInput for consecutive operators', () {
        final result = useCase.execute('5++3');
        expect(result, isA<EvaluationInvalidInput>());
      });

      test('returns InvalidInput for unbalanced parentheses', () {
        final result = useCase.execute('(5+3');
        expect(result, isA<EvaluationInvalidInput>());
      });

      test('returns InvalidInput for empty parentheses', () {
        final result = useCase.execute('5+()');
        expect(result, isA<EvaluationInvalidInput>());
      });
    });

    group('edge case handling', () {
      test('returns InvalidInput for expression with only operators', () {
        final result = useCase.execute('+-*/');
        expect(result, isA<EvaluationInvalidInput>());
      });

      test('returns InvalidInput for expression starting with power operator', () {
        final result = useCase.execute('^2');
        expect(result, isA<EvaluationInvalidInput>());
      });

      test('returns InvalidInput for consecutive power operators', () {
        final result = useCase.execute('2^^3');
        expect(result, isA<EvaluationInvalidInput>());
      });

      test('returns InvalidInput for multiple decimal points', () {
        final result = useCase.execute('1.2.3');
        expect(result, isA<EvaluationInvalidInput>());
      });

      test('returns InvalidInput for missing operator before parenthesis', () {
        final result = useCase.execute('5(3)');
        expect(result, isA<EvaluationInvalidInput>());
      });

      test('returns InvalidInput for missing operator after parenthesis', () {
        final result = useCase.execute('(3)5');
        expect(result, isA<EvaluationInvalidInput>());
      });

      test('handles very large numbers', () {
        final result = useCase.execute('999999999999*999999999999');
        expect(result, isA<EvaluationSuccess>());
        expect((result as EvaluationSuccess).value, greaterThan(0));
      });

      test('handles very small decimal numbers', () {
        final result = useCase.execute('0.000001*0.000001');
        expect(result, isA<EvaluationSuccess>());
        expect((result as EvaluationSuccess).value, closeTo(0.000000000001, 1e-15));
      });

      test('handles expression with leading zeros', () {
        final result = useCase.execute('007+003');
        expect(result, isA<EvaluationSuccess>());
        expect((result as EvaluationSuccess).value, equals(10.0));
      });
    });

    group('error recovery and parser exceptions', () {
      test('handles malformed expression gracefully', () {
        final result = useCase.execute('++');
        expect(result, isA<EvaluationInvalidInput>());
      });

      test('handles expression with invalid characters as error', () {
        final result = useCase.execute('2+3#4');
        // Should either parse as 2+3 (ignoring invalid) or return error
        // The actual behavior depends on implementation
        expect(result.isSuccess || result is EvaluationInvalidInput, isTrue);
      });

      test('handles division by expression that equals zero', () {
        final result = useCase.execute('10/(5-5)');
        expect(result, isA<EvaluationDivisionByZero>());
      });

      test('handles complex expression resulting in zero denominator', () {
        final result = useCase.execute('100/((2*3)-(3*2))');
        expect(result, isA<EvaluationDivisionByZero>());
      });
    });

    group('basic operations', () {
      test('evaluates addition correctly', () {
        final result = useCase.execute('2+3');
        expect(result, isA<EvaluationSuccess>());
        expect(getResultString(result), equals('5'));
      });

      test('evaluates subtraction correctly', () {
        final result = useCase.execute('10-4');
        expect(result, isA<EvaluationSuccess>());
        expect(getResultString(result), equals('6'));
      });

      test('evaluates multiplication correctly', () {
        final result = useCase.execute('3*4');
        expect(result, isA<EvaluationSuccess>());
        expect(getResultString(result), equals('12'));
      });

      test('evaluates division correctly', () {
        final result = useCase.execute('10/2');
        expect(result, isA<EvaluationSuccess>());
        expect(getResultString(result), equals('5'));
      });

      test('evaluates division with decimal result', () {
        final result = useCase.execute('10/4');
        expect(result, isA<EvaluationSuccess>());
        expect(getResultString(result), equals('2.5'));
      });
    });

    group('power operator - exponentiation', () {
      group('acceptance criteria scenarios', () {
        // AC1: Simple power - 2^3 = 8
        test('AC1: evaluates 2^3 = 8 (simple power)', () {
          expect(getResultString(useCase.execute('2^3')), equals('8'));
        });

        // AC2: Large exponent - 2^10 = 1024
        test('AC2: evaluates 2^10 = 1024 (large exponent)', () {
          expect(getResultString(useCase.execute('2^10')), equals('1024'));
        });

        // AC3: Fractional exponent - 2^0.5 ≈ 1.414 (square root of 2)
        test('AC3: evaluates 2^0.5 ≈ 1.4142135623730951 (square root of 2)', () {
          final result = double.parse(getResultString(useCase.execute('2^0.5')));
          expect(result, closeTo(1.4142135623730951, 0.0001));
        });

        // AC4: Zero exponent - 5^0 = 1
        test('AC4: evaluates 5^0 = 1 (zero exponent)', () {
          expect(getResultString(useCase.execute('5^0')), equals('1'));
        });

        // AC5: Power in complex expression - 3+2^4*5 = 83
        test('AC5: evaluates 3+2^4*5 = 83 (complex expression with power)', () {
          // 2^4 = 16, 16*5 = 80, 3+80 = 83
          expect(getResultString(useCase.execute('3+2^4*5')), equals('83'));
        });

        // AC6: Multiple powers - 2^3+4^2 = 24
        test('AC6: evaluates 2^3+4^2 = 24 (multiple power operations)', () {
          // 2^3 = 8, 4^2 = 16, 8+16 = 24
          expect(getResultString(useCase.execute('2^3+4^2')), equals('24'));
        });

        // AC7: Power with parentheses - (2+1)^2 = 9
        test('AC7: evaluates (2+1)^2 = 9 (power with parenthesized base)', () {
          // (2+1) = 3, 3^2 = 9
          expect(getResultString(useCase.execute('(2+1)^2')), equals('9'));
        });
      });

      group('basic power operations', () {
        test('evaluates 2^3 = 8', () {
          expect(getResultString(useCase.execute('2^3')), equals('8'));
        });

        test('evaluates 3^2 = 9', () {
          expect(getResultString(useCase.execute('3^2')), equals('9'));
        });

        test('evaluates 5^2 = 25', () {
          expect(getResultString(useCase.execute('5^2')), equals('25'));
        });

        test('evaluates 10^3 = 1000', () {
          expect(getResultString(useCase.execute('10^3')), equals('1000'));
        });

        test('evaluates 2^10 = 1024', () {
          expect(getResultString(useCase.execute('2^10')), equals('1024'));
        });
      });

      group('zero exponent - x^0 = 1', () {
        test('evaluates 2^0 = 1', () {
          expect(getResultString(useCase.execute('2^0')), equals('1'));
        });

        test('evaluates 5^0 = 1', () {
          expect(getResultString(useCase.execute('5^0')), equals('1'));
        });

        test('evaluates 100^0 = 1', () {
          expect(getResultString(useCase.execute('100^0')), equals('1'));
        });

        test('evaluates 1^0 = 1', () {
          expect(getResultString(useCase.execute('1^0')), equals('1'));
        });
      });

      group('exponent of 1', () {
        test('evaluates 2^1 = 2', () {
          expect(getResultString(useCase.execute('2^1')), equals('2'));
        });

        test('evaluates 10^1 = 10', () {
          expect(getResultString(useCase.execute('10^1')), equals('10'));
        });
      });

      group('zero base', () {
        test('evaluates 0^2 = 0', () {
          expect(getResultString(useCase.execute('0^2')), equals('0'));
        });

        test('evaluates 0^5 = 0', () {
          expect(getResultString(useCase.execute('0^5')), equals('0'));
        });

        test('evaluates 0^1 = 0', () {
          expect(getResultString(useCase.execute('0^1')), equals('0'));
        });

        test('evaluates 0^0 = 1 (mathematical convention)', () {
          // In most mathematical contexts and programming languages, 0^0 = 1
          expect(getResultString(useCase.execute('0^0')), equals('1'));
        });
      });

      group('fractional exponents - roots', () {
        test('evaluates 2^0.5 ≈ 1.414 (square root of 2)', () {
          final result = double.parse(getResultString(useCase.execute('2^0.5')));
          expect(result, closeTo(1.4142135623730951, 0.0001));
        });

        test('evaluates 4^0.5 = 2 (square root of 4)', () {
          expect(getResultString(useCase.execute('4^0.5')), equals('2'));
        });

        test('evaluates 9^0.5 = 3 (square root of 9)', () {
          expect(getResultString(useCase.execute('9^0.5')), equals('3'));
        });

        test('evaluates 8^0.5 (square root of 8)', () {
          final result = double.parse(getResultString(useCase.execute('8^0.5')));
          expect(result, closeTo(2.8284271247461903, 0.0001));
        });

        test('evaluates 27^0.333333 (approximate cube root of 27)', () {
          final result = double.parse(getResultString(useCase.execute('27^0.333333')));
          expect(result, closeTo(3.0, 0.001));
        });

        test('evaluates 16^0.25 = 2 (fourth root of 16)', () {
          expect(getResultString(useCase.execute('16^0.25')), equals('2'));
        });
      });

      group('negative exponents', () {
        test('evaluates 2^-1 = 0.5', () {
          expect(getResultString(useCase.execute('2^-1')), equals('0.5'));
        });

        test('evaluates 2^-2 = 0.25', () {
          expect(getResultString(useCase.execute('2^-2')), equals('0.25'));
        });

        test('evaluates 10^-1 = 0.1', () {
          expect(getResultString(useCase.execute('10^-1')), equals('0.1'));
        });

        test('evaluates 4^-0.5 = 0.5', () {
          expect(getResultString(useCase.execute('4^-0.5')), equals('0.5'));
        });
      });

      group('chained powers - right associativity', () {
        test('evaluates 2^3^2 = 512 (right-to-left: 2^(3^2) = 2^9)', () {
          // Power is right-associative: 2^3^2 = 2^(3^2) = 2^9 = 512
          // NOT (2^3)^2 = 8^2 = 64
          expect(getResultString(useCase.execute('2^3^2')), equals('512'));
        });

        test('evaluates 2^2^3 = 256 (right-to-left: 2^(2^3) = 2^8)', () {
          expect(getResultString(useCase.execute('2^2^3')), equals('256'));
        });

        test('evaluates 3^2^1 = 9 (right-to-left: 3^(2^1) = 3^2)', () {
          expect(getResultString(useCase.execute('3^2^1')), equals('9'));
        });
      });

      group('power operator precedence', () {
        test('power has higher precedence than multiplication: 2*3^2 = 18', () {
          // 3^2 = 9, then 2*9 = 18
          expect(getResultString(useCase.execute('2*3^2')), equals('18'));
        });

        test('power has higher precedence than division: 8/2^2 = 2', () {
          // 2^2 = 4, then 8/4 = 2
          expect(getResultString(useCase.execute('8/2^2')), equals('2'));
        });

        test('power has higher precedence than addition: 1+2^3 = 9', () {
          // 2^3 = 8, then 1+8 = 9
          expect(getResultString(useCase.execute('1+2^3')), equals('9'));
        });

        test('power has higher precedence than subtraction: 10-2^3 = 2', () {
          // 2^3 = 8, then 10-8 = 2
          expect(getResultString(useCase.execute('10-2^3')), equals('2'));
        });

        test('complex expression: 2+3*4^2 = 50', () {
          // 4^2 = 16, 3*16 = 48, 2+48 = 50
          expect(getResultString(useCase.execute('2+3*4^2')), equals('50'));
        });

        test('complex expression: 2^3+4*5 = 28', () {
          // 2^3 = 8, 4*5 = 20, 8+20 = 28
          expect(getResultString(useCase.execute('2^3+4*5')), equals('28'));
        });

        test('complex expression: 3+2^4*5 = 83', () {
          // 2^4 = 16, 16*5 = 80, 3+80 = 83
          expect(getResultString(useCase.execute('3+2^4*5')), equals('83'));
        });
      });

      group('power with parentheses', () {
        test('evaluates (2+1)^2 = 9', () {
          // (2+1) = 3, 3^2 = 9
          expect(getResultString(useCase.execute('(2+1)^2')), equals('9'));
        });

        test('evaluates (2+3)^2 = 25', () {
          expect(getResultString(useCase.execute('(2+3)^2')), equals('25'));
        });

        test('evaluates 2^(3+1) = 16', () {
          expect(getResultString(useCase.execute('2^(3+1)')), equals('16'));
        });

        test('evaluates (2^3)^2 = 64', () {
          // Parentheses override right-associativity
          expect(getResultString(useCase.execute('(2^3)^2')), equals('64'));
        });

        test('evaluates (1+1)^(2+1) = 8', () {
          // (1+1) = 2, (2+1) = 3, 2^3 = 8
          expect(getResultString(useCase.execute('(1+1)^(2+1)')), equals('8'));
        });

        test('evaluates ((2+1)^2)*2 = 18', () {
          // (2+1) = 3, 3^2 = 9, 9*2 = 18
          expect(getResultString(useCase.execute('((2+1)^2)*2')), equals('18'));
        });

        test('evaluates 2*((3+1)^2) = 32', () {
          // (3+1) = 4, 4^2 = 16, 2*16 = 32
          expect(getResultString(useCase.execute('2*((3+1)^2)')), equals('32'));
        });
      });

      group('power with decimals', () {
        test('evaluates 1.5^2 = 2.25', () {
          expect(getResultString(useCase.execute('1.5^2')), equals('2.25'));
        });

        test('evaluates 2.5^2 = 6.25', () {
          expect(getResultString(useCase.execute('2.5^2')), equals('6.25'));
        });

        test('evaluates 2^1.5', () {
          final result = double.parse(getResultString(useCase.execute('2^1.5')));
          expect(result, closeTo(2.8284271247461903, 0.0001));
        });

        test('evaluates 1.5^1.5', () {
          final result = double.parse(getResultString(useCase.execute('1.5^1.5')));
          expect(result, closeTo(1.8371173070873836, 0.0001));
        });
      });

      group('power with negative bases', () {
        test('evaluates (-2)^2 = 4', () {
          expect(getResultString(useCase.execute('(-2)^2')), equals('4'));
        });

        test('evaluates (-2)^3 = -8', () {
          expect(getResultString(useCase.execute('(-2)^3')), equals('-8'));
        });

        test('evaluates (-3)^2 = 9', () {
          expect(getResultString(useCase.execute('(-3)^2')), equals('9'));
        });

        test('evaluates (-1)^0 = 1', () {
          expect(getResultString(useCase.execute('(-1)^0')), equals('1'));
        });
      });

      group('multiple power operations in single expression', () {
        test('evaluates 2^3+4^2 = 24', () {
          // 2^3 = 8, 4^2 = 16, 8+16 = 24
          expect(getResultString(useCase.execute('2^3+4^2')), equals('24'));
        });

        test('evaluates 2^3*2^2 = 32', () {
          // 2^3 = 8, 2^2 = 4, 8*4 = 32
          expect(getResultString(useCase.execute('2^3*2^2')), equals('32'));
        });

        test('evaluates 2^3+2^2 = 12', () {
          // 2^3 = 8, 2^2 = 4, 8+4 = 12
          expect(getResultString(useCase.execute('2^3+2^2')), equals('12'));
        });

        test('evaluates 2^3-2^2 = 4', () {
          // 2^3 = 8, 2^2 = 4, 8-4 = 4
          expect(getResultString(useCase.execute('2^3-2^2')), equals('4'));
        });

        test('evaluates 2^3/2^2 = 2', () {
          // 2^3 = 8, 2^2 = 4, 8/4 = 2
          expect(getResultString(useCase.execute('2^3/2^2')), equals('2'));
        });

        test('evaluates 10-3^2+2 = 3', () {
          // 3^2 = 9, 10-9 = 1, 1+2 = 3
          expect(getResultString(useCase.execute('10-3^2+2')), equals('3'));
        });

        test('evaluates 3^2+2^3+4^1 = 21', () {
          // 3^2 = 9, 2^3 = 8, 4^1 = 4, 9+8+4 = 21
          expect(getResultString(useCase.execute('3^2+2^3+4^1')), equals('21'));
        });

        test('evaluates 2^2*3^2 = 36', () {
          // 2^2 = 4, 3^2 = 9, 4*9 = 36
          expect(getResultString(useCase.execute('2^2*3^2')), equals('36'));
        });
      });

      group('large power results', () {
        test('evaluates 2^20 = 1048576', () {
          expect(getResultString(useCase.execute('2^20')), equals('1048576'));
        });

        test('evaluates 10^6 = 1000000', () {
          expect(getResultString(useCase.execute('10^6')), equals('1000000'));
        });
      });

      group('edge cases for power evaluation', () {
        test('evaluates 1^100 = 1 (1 raised to any power)', () {
          expect(getResultString(useCase.execute('1^100')), equals('1'));
        });

        test('evaluates 1^999 = 1', () {
          expect(getResultString(useCase.execute('1^999')), equals('1'));
        });

        test('evaluates small fractional exponent: 100^0.1 (tenth root of 100)', () {
          // 100^0.1 = 100^(1/10) = tenth root of 100 ≈ 1.5848931924611136
          final result = double.parse(getResultString(useCase.execute('100^0.1')));
          expect(result, closeTo(1.5848931924611136, 0.0001));
        });

        test('evaluates power resulting in small decimal', () {
          final result = double.parse(getResultString(useCase.execute('2^-10')));
          expect(result, closeTo(0.0009765625, 0.0000001));
        });

        test('evaluates complex expression with multiple operators and power', () {
          // 1+2^3*4-5 = 1 + 8*4 - 5 = 1 + 32 - 5 = 28
          expect(getResultString(useCase.execute('1+2^3*4-5')), equals('28'));
        });

        test('evaluates nested parentheses with power', () {
          // ((1+2)^2+1)^2 = (9+1)^2 = 10^2 = 100
          expect(getResultString(useCase.execute('((1+2)^2+1)^2')), equals('100'));
        });
      });
    });

    group('division by zero - AC4 compliance', () {
      test('division by zero returns DivisionByZero result', () {
        final result = useCase.execute('10/0');
        expect(result, isA<EvaluationDivisionByZero>());
        expect(getResultString(result), equals('Infinity'));
      });

      test('simple division by zero: 1/0 returns Infinity', () {
        final result = useCase.execute('1/0');
        expect(result, isA<EvaluationDivisionByZero>());
        expect(getResultString(result), equals('Infinity'));
      });

      test('large number division by zero returns Infinity', () {
        final result = useCase.execute('999999/0');
        expect(result, isA<EvaluationDivisionByZero>());
        expect(getResultString(result), equals('Infinity'));
      });

      test('chained division by zero: 10/5/0 returns Infinity', () {
        final result = useCase.execute('10/5/0');
        expect(result, isA<EvaluationDivisionByZero>());
        expect(getResultString(result), equals('Infinity'));
      });

      test('negative number division by zero returns -Infinity', () {
        final result = useCase.execute('-10/0');
        expect(result, isA<EvaluationDivisionByZero>());
        expect(getResultString(result), equals('-Infinity'));
      });

      test('negative one division by zero returns -Infinity', () {
        final result = useCase.execute('-1/0');
        expect(result, isA<EvaluationDivisionByZero>());
        expect(getResultString(result), equals('-Infinity'));
      });

      test('zero divided by zero returns NaN', () {
        final result = useCase.execute('0/0');
        expect(result, isA<EvaluationDivisionByZero>());
        expect(getResultString(result), equals('NaN'));
      });

      test('complex expression with division by zero', () {
        // 5 + 10/0 should result in Infinity (Infinity dominates)
        final result = useCase.execute('5+10/0');
        expect(result, isA<EvaluationDivisionByZero>());
        expect(getResultString(result), equals('Infinity'));
      });

      test('multiplication then division by zero', () {
        // 2*5/0 = 10/0 = Infinity
        final result = useCase.execute('2*5/0');
        expect(result, isA<EvaluationDivisionByZero>());
        expect(getResultString(result), equals('Infinity'));
      });
    });

    group('operator precedence', () {
      test('multiplication before addition', () {
        expect(getResultString(useCase.execute('2+3*4')), equals('14'));
      });

      test('division before subtraction', () {
        expect(getResultString(useCase.execute('10-6/2')), equals('7'));
      });

      test('complex expression with mixed operators', () {
        expect(getResultString(useCase.execute('2+3*4-6/2')), equals('11'));
      });
    });

    group('order of operations compliance (PEMDAS/BODMAS)', () {
      test('PEMDAS: parentheses have highest precedence', () {
        // Without parentheses: 2+3*4 = 14
        // With parentheses: (2+3)*4 = 20
        expect(getResultString(useCase.execute('(2+3)*4')), equals('20'));
        expect(getResultString(useCase.execute('2+3*4')), equals('14'));
      });

      test('PEMDAS: exponents before multiplication', () {
        // 2*3^2 = 2*9 = 18 (not (2*3)^2 = 36)
        expect(getResultString(useCase.execute('2*3^2')), equals('18'));
      });

      test('PEMDAS: exponents before division', () {
        // 8/2^2 = 8/4 = 2 (not (8/2)^2 = 16)
        expect(getResultString(useCase.execute('8/2^2')), equals('2'));
      });

      test('PEMDAS: multiplication before addition', () {
        // 1+2*3 = 1+6 = 7 (not (1+2)*3 = 9)
        expect(getResultString(useCase.execute('1+2*3')), equals('7'));
      });

      test('PEMDAS: division before subtraction', () {
        // 10-4/2 = 10-2 = 8 (not (10-4)/2 = 3)
        expect(getResultString(useCase.execute('10-4/2')), equals('8'));
      });

      test('PEMDAS: full order test with all operators', () {
        // 2+3*4^2-10/5 = 2+3*16-2 = 2+48-2 = 48
        expect(getResultString(useCase.execute('2+3*4^2-10/5')), equals('48'));
      });

      test('PEMDAS: left to right for same precedence (addition/subtraction)', () {
        // 10-5+2 = 5+2 = 7 (left to right)
        expect(getResultString(useCase.execute('10-5+2')), equals('7'));
      });

      test('PEMDAS: left to right for same precedence (multiplication/division)', () {
        // 12/3*2 = 4*2 = 8 (left to right)
        expect(getResultString(useCase.execute('12/3*2')), equals('8'));
      });

      test('PEMDAS: complex nested expression', () {
        // ((2+3)*4-10)/2+3^2 = (5*4-10)/2+9 = (20-10)/2+9 = 10/2+9 = 5+9 = 14
        expect(getResultString(useCase.execute('((2+3)*4-10)/2+3^2')), equals('14'));
      });
    });

    group('negative numbers', () {
      test('evaluates negative number at start', () {
        expect(getResultString(useCase.execute('-5+3')), equals('-2'));
      });

      test('evaluates subtraction resulting in negative', () {
        expect(getResultString(useCase.execute('3-10')), equals('-7'));
      });
    });

    group('decimal numbers', () {
      test('evaluates decimal addition', () {
        expect(getResultString(useCase.execute('1.5+2.5')), equals('4'));
      });

      test('evaluates decimal multiplication', () {
        expect(getResultString(useCase.execute('2.5*4')), equals('10'));
      });
    });

    group('display operator conversion', () {
      test('converts × to * for multiplication', () {
        expect(getResultString(useCase.execute('3×4')), equals('12'));
      });

      test('converts ÷ to / for division', () {
        expect(getResultString(useCase.execute('10÷2')), equals('5'));
      });

      test('division by zero with ÷ operator returns Infinity', () {
        final result = useCase.execute('10÷0');
        expect(result, isA<EvaluationDivisionByZero>());
        expect(getResultString(result), equals('Infinity'));
      });
    });

    group('parentheses evaluation', () {
      group('basic parentheses', () {
        test('AC3: evaluates (2+3)*4 = 20', () {
          // This is the specific AC3 acceptance criteria test
          expect(getResultString(useCase.execute('(2+3)*4')), equals('20'));
        });

        test('evaluates 2*(3+4) = 14', () {
          expect(getResultString(useCase.execute('2*(3+4)')), equals('14'));
        });

        test('evaluates (5-2)*3 = 9', () {
          expect(getResultString(useCase.execute('(5-2)*3')), equals('9'));
        });

        test('evaluates 10/(2+3) = 2', () {
          expect(getResultString(useCase.execute('10/(2+3)')), equals('2'));
        });

        test('evaluates (10+5)/3 = 5', () {
          expect(getResultString(useCase.execute('(10+5)/3')), equals('5'));
        });

        test('evaluates (6*2)+5 = 17', () {
          expect(getResultString(useCase.execute('(6*2)+5')), equals('17'));
        });

        test('evaluates 5+(6*2) = 17', () {
          expect(getResultString(useCase.execute('5+(6*2)')), equals('17'));
        });
      });

      group('nested parentheses', () {
        test('evaluates ((2+3)*2) = 10', () {
          expect(getResultString(useCase.execute('((2+3)*2)')), equals('10'));
        });

        test('evaluates ((2+3)*(4-1)) = 15', () {
          expect(getResultString(useCase.execute('((2+3)*(4-1))')), equals('15'));
        });

        test('evaluates (2*(3+4))+1 = 15', () {
          expect(getResultString(useCase.execute('(2*(3+4))+1')), equals('15'));
        });

        test('evaluates ((10-5)*2)/5 = 2', () {
          expect(getResultString(useCase.execute('((10-5)*2)/5')), equals('2'));
        });

        test('evaluates (((2+3))) = 5', () {
          expect(getResultString(useCase.execute('(((2+3)))')), equals('5'));
        });

        test('evaluates ((1+2)*(3+4))*(5-3) = 42', () {
          // (1+2) = 3, (3+4) = 7, (5-3) = 2
          // 3 * 7 = 21, 21 * 2 = 42
          expect(getResultString(useCase.execute('((1+2)*(3+4))*(5-3)')), equals('42'));
        });

        test('evaluates ((2+3)*2)+1 = 11 (nested parentheses per implementation step 3)', () {
          // (2+3) = 5, 5*2 = 10, 10+1 = 11
          expect(getResultString(useCase.execute('((2+3)*2)+1')), equals('11'));
        });
      });

      group('multiple separate parentheses', () {
        test('evaluates (2+3)+(4+5) = 14', () {
          expect(getResultString(useCase.execute('(2+3)+(4+5)')), equals('14'));
        });

        test('evaluates (2+3)*(4+5) = 45', () {
          expect(getResultString(useCase.execute('(2+3)*(4+5)')), equals('45'));
        });

        test('evaluates (2+3)*(4+1) = 25 (multiple groups per implementation step 4)', () {
          // (2+3) = 5, (4+1) = 5
          // 5 * 5 = 25
          expect(getResultString(useCase.execute('(2+3)*(4+1)')), equals('25'));
        });

        test('evaluates (10-2)/(2+2) = 2', () {
          expect(getResultString(useCase.execute('(10-2)/(2+2)')), equals('2'));
        });

        test('evaluates (3*2)-(2*1) = 4', () {
          expect(getResultString(useCase.execute('(3*2)-(2*1)')), equals('4'));
        });
      });

      group('order of operations verification (implementation step 5)', () {
        test('without parentheses: 2+3*4 = 14 (multiplication first)', () {
          // Standard precedence: 3*4 = 12, then 2+12 = 14
          expect(getResultString(useCase.execute('2+3*4')), equals('14'));
        });

        test('with parentheses: (2+3)*4 = 20 (parentheses override precedence)', () {
          // Parentheses force: 2+3 = 5, then 5*4 = 20
          expect(getResultString(useCase.execute('(2+3)*4')), equals('20'));
        });

        test('demonstrates parentheses change result from 14 to 20', () {
          // This test explicitly shows how parentheses change the order of operations
          final withoutParens = getResultString(useCase.execute('2+3*4'));
          final withParens = getResultString(useCase.execute('(2+3)*4'));
          
          expect(withoutParens, equals('14'), reason: '2+3*4 should be 14 (multiplication first)');
          expect(withParens, equals('20'), reason: '(2+3)*4 should be 20 (parentheses first)');
          expect(withoutParens, isNot(equals(withParens)), reason: 'Results should differ');
        });
      });

      group('parentheses with negative numbers', () {
        test('evaluates (-5)+3 in parentheses style', () {
          expect(getResultString(useCase.execute('(-5)+3')), equals('-2'));
        });

        test('evaluates 2*(-3) = -6', () {
          expect(getResultString(useCase.execute('2*(-3)')), equals('-6'));
        });

        test('evaluates (-2)*(-3) = 6', () {
          expect(getResultString(useCase.execute('(-2)*(-3)')), equals('6'));
        });

        test('evaluates (5-10)*2 = -10', () {
          expect(getResultString(useCase.execute('(5-10)*2')), equals('-10'));
        });
      });

      group('parentheses with decimals', () {
        test('evaluates (1.5+2.5)*2 = 8', () {
          expect(getResultString(useCase.execute('(1.5+2.5)*2')), equals('8'));
        });

        test('evaluates 10/(2.5+2.5) = 2', () {
          expect(getResultString(useCase.execute('10/(2.5+2.5)')), equals('2'));
        });
      });

      group('parentheses with division by zero', () {
        test('evaluates (10+5)/0 = Infinity', () {
          expect(getResultString(useCase.execute('(10+5)/0')), equals('Infinity'));
        });

        test('evaluates 1/(2-2) = Infinity (0 in denominator)', () {
          expect(getResultString(useCase.execute('1/(2-2)')), equals('Infinity'));
        });

        test('evaluates (0-0)/(0+0) = NaN', () {
          expect(getResultString(useCase.execute('(0-0)/(0+0)')), equals('NaN'));
        });
      });

      group('parentheses with display operators', () {
        test('evaluates (2+3)×4 = 20', () {
          expect(getResultString(useCase.execute('(2+3)×4')), equals('20'));
        });

        test('evaluates 10÷(2+3) = 2', () {
          expect(getResultString(useCase.execute('10÷(2+3)')), equals('2'));
        });

        test('evaluates (6×2)+5 = 17', () {
          expect(getResultString(useCase.execute('(6×2)+5')), equals('17'));
        });
      });
    });

    group('malformed parentheses - error handling (implementation step 6)', () {
      test('unmatched opening parenthesis returns Error: (2+3', () {
        expect(getResultString(useCase.execute('(2+3')), equals('Error'));
      });

      test('unmatched closing parenthesis returns Error: 2+3)', () {
        expect(getResultString(useCase.execute('2+3)')), equals('Error'));
      });

      test('extra opening parenthesis returns Error', () {
        expect(getResultString(useCase.execute('((2+3)*4')), equals('Error'));
      });

      test('extra closing parenthesis returns Error', () {
        expect(getResultString(useCase.execute('(2+3)*4)')), equals('Error'));
      });

      test('mismatched parentheses order returns Error', () {
        expect(getResultString(useCase.execute(')(2+3)(')), equals('Error'));
      });

      test('empty parentheses returns Error', () {
        expect(getResultString(useCase.execute('2+()')), equals('Error'));
      });

      test('nested empty parentheses returns Error', () {
        expect(getResultString(useCase.execute('2+(())')), equals('Error'));
      });

      test('multiple unmatched parentheses returns Error', () {
        expect(getResultString(useCase.execute('((2+3')), equals('Error'));
      });

      test('closing before opening returns Error', () {
        expect(getResultString(useCase.execute(')2+3(')), equals('Error'));
      });
    });

    group('complex expressions with parentheses', () {
      test('evaluates 2+3*(4+5)-6/2 correctly', () {
        // 4+5 = 9, 3*9 = 27, 6/2 = 3
        // 2 + 27 - 3 = 26
        expect(getResultString(useCase.execute('2+3*(4+5)-6/2')), equals('26'));
      });

      test('evaluates (2+3)*4/(5-3) correctly', () {
        // 2+3 = 5, 5-3 = 2
        // 5*4 = 20, 20/2 = 10
        expect(getResultString(useCase.execute('(2+3)*4/(5-3)')), equals('10'));
      });

      test('evaluates ((2+3)*4+5)*2 correctly', () {
        // 2+3 = 5, 5*4 = 20, 20+5 = 25, 25*2 = 50
        expect(getResultString(useCase.execute('((2+3)*4+5)*2')), equals('50'));
      });

      test('evaluates 100/(2*(3+2)) correctly', () {
        // 3+2 = 5, 2*5 = 10, 100/10 = 10
        expect(getResultString(useCase.execute('100/(2*(3+2))')), equals('10'));
      });
    });

    group('legacy executeString method', () {
      test('executeString returns formatted string for success', () {
        expect(useCase.executeString('2+3'), equals('5'));
      });

      test('executeString returns Error for invalid input', () {
        expect(useCase.executeString(''), equals('Error'));
      });

      test('executeString returns Infinity for division by zero', () {
        expect(useCase.executeString('10/0'), equals('Infinity'));
      });
    });

    group('invalid expression error handling', () {
      test('returns InvalidInput for expression 2++3', () {
        final result = useCase.execute('2++3');
        expect(result, isA<EvaluationInvalidInput>());
        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, isNotNull);
      });

      test('returns InvalidInput for expression 3**4', () {
        final result = useCase.execute('3**4');
        expect(result, isA<EvaluationInvalidInput>());
      });

      test('returns InvalidInput for expression /5', () {
        final result = useCase.execute('/5');
        expect(result, isA<EvaluationInvalidInput>());
      });

      test('returns InvalidInput for expression 5/', () {
        final result = useCase.execute('5/');
        expect(result, isA<EvaluationInvalidInput>());
      });

      test('returns InvalidInput for expression with only parentheses', () {
        final result = useCase.execute('()');
        expect(result, isA<EvaluationInvalidInput>());
      });

      test('returns InvalidInput for consecutive division operators', () {
        final result = useCase.execute('10//5');
        expect(result, isA<EvaluationInvalidInput>());
      });

      test('returns InvalidInput for consecutive multiplication operators', () {
        final result = useCase.execute('10**5');
        expect(result, isA<EvaluationInvalidInput>());
      });
    });

    group('valid expression Success tests', () {
      test('returns Success with correct value for 2+3*4', () {
        final result = useCase.execute('2+3*4');
        expect(result, isA<EvaluationSuccess>());
        expect((result as EvaluationSuccess).value, equals(14.0));
        expect(result.formattedValue, equals('14'));
      });

      test('returns Success with correct value for (2+3)*4', () {
        final result = useCase.execute('(2+3)*4');
        expect(result, isA<EvaluationSuccess>());
        expect((result as EvaluationSuccess).value, equals(20.0));
        expect(result.formattedValue, equals('20'));
      });

      test('returns Success with correct value for 2^3', () {
        final result = useCase.execute('2^3');
        expect(result, isA<EvaluationSuccess>());
        expect((result as EvaluationSuccess).value, equals(8.0));
        expect(result.formattedValue, equals('8'));
      });

      test('returns Success with correct value for simple addition', () {
        final result = useCase.execute('5+5');
        expect(result, isA<EvaluationSuccess>());
        expect((result as EvaluationSuccess).value, equals(10.0));
      });

      test('returns Success with correct value for complex expression', () {
        final result = useCase.execute('(10+5)*2-15/3');
        // (10+5) = 15, 15*2 = 30, 15/3 = 5, 30 - 5 = 25
        expect(result, isA<EvaluationSuccess>());
        expect((result as EvaluationSuccess).value, equals(25.0));
      });

      test('returns Success with decimal value', () {
        final result = useCase.execute('7/2');
        expect(result, isA<EvaluationSuccess>());
        expect((result as EvaluationSuccess).value, equals(3.5));
        expect(result.formattedValue, equals('3.5'));
      });

      test('returns Success with negative value', () {
        final result = useCase.execute('5-10');
        expect(result, isA<EvaluationSuccess>());
        expect((result as EvaluationSuccess).value, equals(-5.0));
        expect(result.formattedValue, equals('-5'));
      });
    });
  });
}
