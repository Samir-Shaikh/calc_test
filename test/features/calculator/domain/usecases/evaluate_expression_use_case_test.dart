import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';

void main() {
  late EvaluateExpressionUseCase useCase;

  setUp(() {
    useCase = EvaluateExpressionUseCase();
  });

  group('EvaluateExpressionUseCase', () {
    group('basic operations', () {
      test('evaluates addition correctly', () {
        expect(useCase.execute('2+3'), equals('5'));
      });

      test('evaluates subtraction correctly', () {
        expect(useCase.execute('10-4'), equals('6'));
      });

      test('evaluates multiplication correctly', () {
        expect(useCase.execute('3*4'), equals('12'));
      });

      test('evaluates division correctly', () {
        expect(useCase.execute('10/2'), equals('5'));
      });

      test('evaluates division with decimal result', () {
        expect(useCase.execute('10/4'), equals('2.5'));
      });
    });

    group('power operator - exponentiation', () {
      group('basic power operations', () {
        test('evaluates 2^3 = 8', () {
          expect(useCase.execute('2^3'), equals('8'));
        });

        test('evaluates 3^2 = 9', () {
          expect(useCase.execute('3^2'), equals('9'));
        });

        test('evaluates 5^2 = 25', () {
          expect(useCase.execute('5^2'), equals('25'));
        });

        test('evaluates 10^3 = 1000', () {
          expect(useCase.execute('10^3'), equals('1000'));
        });

        test('evaluates 2^10 = 1024', () {
          expect(useCase.execute('2^10'), equals('1024'));
        });
      });

      group('zero exponent - x^0 = 1', () {
        test('evaluates 2^0 = 1', () {
          expect(useCase.execute('2^0'), equals('1'));
        });

        test('evaluates 5^0 = 1', () {
          expect(useCase.execute('5^0'), equals('1'));
        });

        test('evaluates 100^0 = 1', () {
          expect(useCase.execute('100^0'), equals('1'));
        });

        test('evaluates 1^0 = 1', () {
          expect(useCase.execute('1^0'), equals('1'));
        });
      });

      group('exponent of 1', () {
        test('evaluates 2^1 = 2', () {
          expect(useCase.execute('2^1'), equals('2'));
        });

        test('evaluates 10^1 = 10', () {
          expect(useCase.execute('10^1'), equals('10'));
        });
      });

      group('zero base', () {
        test('evaluates 0^2 = 0', () {
          expect(useCase.execute('0^2'), equals('0'));
        });

        test('evaluates 0^5 = 0', () {
          expect(useCase.execute('0^5'), equals('0'));
        });

        test('evaluates 0^1 = 0', () {
          expect(useCase.execute('0^1'), equals('0'));
        });

        test('evaluates 0^0 = 1 (mathematical convention)', () {
          // In most mathematical contexts and programming languages, 0^0 = 1
          expect(useCase.execute('0^0'), equals('1'));
        });
      });

      group('fractional exponents - roots', () {
        test('evaluates 4^0.5 = 2 (square root of 4)', () {
          expect(useCase.execute('4^0.5'), equals('2'));
        });

        test('evaluates 9^0.5 = 3 (square root of 9)', () {
          expect(useCase.execute('9^0.5'), equals('3'));
        });

        test('evaluates 8^0.5 (square root of 8)', () {
          final result = double.parse(useCase.execute('8^0.5'));
          expect(result, closeTo(2.8284271247461903, 0.0001));
        });

        test('evaluates 27^0.333333 (approximate cube root of 27)', () {
          final result = double.parse(useCase.execute('27^0.333333'));
          expect(result, closeTo(3.0, 0.001));
        });

        test('evaluates 16^0.25 = 2 (fourth root of 16)', () {
          expect(useCase.execute('16^0.25'), equals('2'));
        });
      });

      group('negative exponents', () {
        test('evaluates 2^-1 = 0.5', () {
          expect(useCase.execute('2^-1'), equals('0.5'));
        });

        test('evaluates 2^-2 = 0.25', () {
          expect(useCase.execute('2^-2'), equals('0.25'));
        });

        test('evaluates 10^-1 = 0.1', () {
          expect(useCase.execute('10^-1'), equals('0.1'));
        });

        test('evaluates 4^-0.5 = 0.5', () {
          expect(useCase.execute('4^-0.5'), equals('0.5'));
        });
      });

      group('chained powers - right associativity', () {
        test('evaluates 2^3^2 = 512 (right-to-left: 2^(3^2) = 2^9)', () {
          // Power is right-associative: 2^3^2 = 2^(3^2) = 2^9 = 512
          // NOT (2^3)^2 = 8^2 = 64
          expect(useCase.execute('2^3^2'), equals('512'));
        });

        test('evaluates 2^2^3 = 256 (right-to-left: 2^(2^3) = 2^8)', () {
          expect(useCase.execute('2^2^3'), equals('256'));
        });

        test('evaluates 3^2^1 = 9 (right-to-left: 3^(2^1) = 3^2)', () {
          expect(useCase.execute('3^2^1'), equals('9'));
        });
      });

      group('power operator precedence', () {
        test('power has higher precedence than multiplication: 2*3^2 = 18', () {
          // 3^2 = 9, then 2*9 = 18
          expect(useCase.execute('2*3^2'), equals('18'));
        });

        test('power has higher precedence than division: 8/2^2 = 2', () {
          // 2^2 = 4, then 8/4 = 2
          expect(useCase.execute('8/2^2'), equals('2'));
        });

        test('power has higher precedence than addition: 1+2^3 = 9', () {
          // 2^3 = 8, then 1+8 = 9
          expect(useCase.execute('1+2^3'), equals('9'));
        });

        test('power has higher precedence than subtraction: 10-2^3 = 2', () {
          // 2^3 = 8, then 10-8 = 2
          expect(useCase.execute('10-2^3'), equals('2'));
        });

        test('complex expression: 2+3*4^2 = 50', () {
          // 4^2 = 16, 3*16 = 48, 2+48 = 50
          expect(useCase.execute('2+3*4^2'), equals('50'));
        });

        test('complex expression: 2^3+4*5 = 28', () {
          // 2^3 = 8, 4*5 = 20, 8+20 = 28
          expect(useCase.execute('2^3+4*5'), equals('28'));
        });
      });

      group('power with parentheses', () {
        test('evaluates (2+3)^2 = 25', () {
          expect(useCase.execute('(2+3)^2'), equals('25'));
        });

        test('evaluates 2^(3+1) = 16', () {
          expect(useCase.execute('2^(3+1)'), equals('16'));
        });

        test('evaluates (2^3)^2 = 64', () {
          // Parentheses override right-associativity
          expect(useCase.execute('(2^3)^2'), equals('64'));
        });

        test('evaluates (1+1)^(2+1) = 8', () {
          // (1+1) = 2, (2+1) = 3, 2^3 = 8
          expect(useCase.execute('(1+1)^(2+1)'), equals('8'));
        });

        test('evaluates ((2+1)^2)*2 = 18', () {
          // (2+1) = 3, 3^2 = 9, 9*2 = 18
          expect(useCase.execute('((2+1)^2)*2'), equals('18'));
        });

        test('evaluates 2*((3+1)^2) = 32', () {
          // (3+1) = 4, 4^2 = 16, 2*16 = 32
          expect(useCase.execute('2*((3+1)^2)'), equals('32'));
        });
      });

      group('power with decimals', () {
        test('evaluates 1.5^2 = 2.25', () {
          expect(useCase.execute('1.5^2'), equals('2.25'));
        });

        test('evaluates 2.5^2 = 6.25', () {
          expect(useCase.execute('2.5^2'), equals('6.25'));
        });

        test('evaluates 2^1.5', () {
          final result = double.parse(useCase.execute('2^1.5'));
          expect(result, closeTo(2.8284271247461903, 0.0001));
        });

        test('evaluates 1.5^1.5', () {
          final result = double.parse(useCase.execute('1.5^1.5'));
          expect(result, closeTo(1.8371173070873836, 0.0001));
        });
      });

      group('power with negative bases', () {
        test('evaluates (-2)^2 = 4', () {
          expect(useCase.execute('(-2)^2'), equals('4'));
        });

        test('evaluates (-2)^3 = -8', () {
          expect(useCase.execute('(-2)^3'), equals('-8'));
        });

        test('evaluates (-3)^2 = 9', () {
          expect(useCase.execute('(-3)^2'), equals('9'));
        });

        test('evaluates (-1)^0 = 1', () {
          expect(useCase.execute('(-1)^0'), equals('1'));
        });
      });

      group('power mixed with other operators', () {
        test('evaluates 2^3*2^2 = 32', () {
          // 2^3 = 8, 2^2 = 4, 8*4 = 32
          expect(useCase.execute('2^3*2^2'), equals('32'));
        });

        test('evaluates 2^3+2^2 = 12', () {
          // 2^3 = 8, 2^2 = 4, 8+4 = 12
          expect(useCase.execute('2^3+2^2'), equals('12'));
        });

        test('evaluates 2^3-2^2 = 4', () {
          // 2^3 = 8, 2^2 = 4, 8-4 = 4
          expect(useCase.execute('2^3-2^2'), equals('4'));
        });

        test('evaluates 2^3/2^2 = 2', () {
          // 2^3 = 8, 2^2 = 4, 8/4 = 2
          expect(useCase.execute('2^3/2^2'), equals('2'));
        });

        test('evaluates 10-3^2+2 = 3', () {
          // 3^2 = 9, 10-9 = 1, 1+2 = 3
          expect(useCase.execute('10-3^2+2'), equals('3'));
        });
      });

      group('large power results', () {
        test('evaluates 2^20 = 1048576', () {
          expect(useCase.execute('2^20'), equals('1048576'));
        });

        test('evaluates 10^6 = 1000000', () {
          expect(useCase.execute('10^6'), equals('1000000'));
        });
      });
    });

    group('division by zero - AC4 compliance', () {
      test('division by zero returns Infinity', () {
        final result = useCase.execute('10/0');
        expect(result, equals('Infinity'));
      });

      test('simple division by zero: 1/0 returns Infinity', () {
        final result = useCase.execute('1/0');
        expect(result, equals('Infinity'));
      });

      test('large number division by zero returns Infinity', () {
        final result = useCase.execute('999999/0');
        expect(result, equals('Infinity'));
      });

      test('chained division by zero: 10/5/0 returns Infinity', () {
        final result = useCase.execute('10/5/0');
        expect(result, equals('Infinity'));
      });

      test('negative number division by zero returns -Infinity', () {
        final result = useCase.execute('-10/0');
        expect(result, equals('-Infinity'));
      });

      test('negative one division by zero returns -Infinity', () {
        final result = useCase.execute('-1/0');
        expect(result, equals('-Infinity'));
      });

      test('zero divided by zero returns NaN', () {
        final result = useCase.execute('0/0');
        expect(result, equals('NaN'));
      });

      test('complex expression with division by zero', () {
        // 5 + 10/0 should result in Infinity (Infinity dominates)
        final result = useCase.execute('5+10/0');
        expect(result, equals('Infinity'));
      });

      test('multiplication then division by zero', () {
        // 2*5/0 = 10/0 = Infinity
        final result = useCase.execute('2*5/0');
        expect(result, equals('Infinity'));
      });
    });

    group('operator precedence', () {
      test('multiplication before addition', () {
        expect(useCase.execute('2+3*4'), equals('14'));
      });

      test('division before subtraction', () {
        expect(useCase.execute('10-6/2'), equals('7'));
      });

      test('complex expression with mixed operators', () {
        expect(useCase.execute('2+3*4-6/2'), equals('11'));
      });
    });

    group('negative numbers', () {
      test('evaluates negative number at start', () {
        expect(useCase.execute('-5+3'), equals('-2'));
      });

      test('evaluates subtraction resulting in negative', () {
        expect(useCase.execute('3-10'), equals('-7'));
      });
    });

    group('decimal numbers', () {
      test('evaluates decimal addition', () {
        expect(useCase.execute('1.5+2.5'), equals('4'));
      });

      test('evaluates decimal multiplication', () {
        expect(useCase.execute('2.5*4'), equals('10'));
      });
    });

    group('display operator conversion', () {
      test('converts × to * for multiplication', () {
        expect(useCase.execute('3×4'), equals('12'));
      });

      test('converts ÷ to / for division', () {
        expect(useCase.execute('10÷2'), equals('5'));
      });

      test('division by zero with ÷ operator returns Infinity', () {
        final result = useCase.execute('10÷0');
        expect(result, equals('Infinity'));
      });
    });

    group('parentheses evaluation', () {
      group('basic parentheses', () {
        test('AC3: evaluates (2+3)*4 = 20', () {
          // This is the specific AC3 acceptance criteria test
          expect(useCase.execute('(2+3)*4'), equals('20'));
        });

        test('evaluates 2*(3+4) = 14', () {
          expect(useCase.execute('2*(3+4)'), equals('14'));
        });

        test('evaluates (5-2)*3 = 9', () {
          expect(useCase.execute('(5-2)*3'), equals('9'));
        });

        test('evaluates 10/(2+3) = 2', () {
          expect(useCase.execute('10/(2+3)'), equals('2'));
        });

        test('evaluates (10+5)/3 = 5', () {
          expect(useCase.execute('(10+5)/3'), equals('5'));
        });

        test('evaluates (6*2)+5 = 17', () {
          expect(useCase.execute('(6*2)+5'), equals('17'));
        });

        test('evaluates 5+(6*2) = 17', () {
          expect(useCase.execute('5+(6*2)'), equals('17'));
        });
      });

      group('nested parentheses', () {
        test('evaluates ((2+3)*2) = 10', () {
          expect(useCase.execute('((2+3)*2)'), equals('10'));
        });

        test('evaluates ((2+3)*(4-1)) = 15', () {
          expect(useCase.execute('((2+3)*(4-1))'), equals('15'));
        });

        test('evaluates (2*(3+4))+1 = 15', () {
          expect(useCase.execute('(2*(3+4))+1'), equals('15'));
        });

        test('evaluates ((10-5)*2)/5 = 2', () {
          expect(useCase.execute('((10-5)*2)/5'), equals('2'));
        });

        test('evaluates (((2+3))) = 5', () {
          expect(useCase.execute('(((2+3)))'), equals('5'));
        });

        test('evaluates ((1+2)*(3+4))*(5-3) = 42', () {
          // (1+2) = 3, (3+4) = 7, (5-3) = 2
          // 3 * 7 = 21, 21 * 2 = 42
          expect(useCase.execute('((1+2)*(3+4))*(5-3)'), equals('42'));
        });

        test('evaluates ((2+3)*2)+1 = 11 (nested parentheses per implementation step 3)', () {
          // (2+3) = 5, 5*2 = 10, 10+1 = 11
          expect(useCase.execute('((2+3)*2)+1'), equals('11'));
        });
      });

      group('multiple separate parentheses', () {
        test('evaluates (2+3)+(4+5) = 14', () {
          expect(useCase.execute('(2+3)+(4+5)'), equals('14'));
        });

        test('evaluates (2+3)*(4+5) = 45', () {
          expect(useCase.execute('(2+3)*(4+5)'), equals('45'));
        });

        test('evaluates (2+3)*(4+1) = 25 (multiple groups per implementation step 4)', () {
          // (2+3) = 5, (4+1) = 5
          // 5 * 5 = 25
          expect(useCase.execute('(2+3)*(4+1)'), equals('25'));
        });

        test('evaluates (10-2)/(2+2) = 2', () {
          expect(useCase.execute('(10-2)/(2+2)'), equals('2'));
        });

        test('evaluates (3*2)-(2*1) = 4', () {
          expect(useCase.execute('(3*2)-(2*1)'), equals('4'));
        });
      });

      group('order of operations verification (implementation step 5)', () {
        test('without parentheses: 2+3*4 = 14 (multiplication first)', () {
          // Standard precedence: 3*4 = 12, then 2+12 = 14
          expect(useCase.execute('2+3*4'), equals('14'));
        });

        test('with parentheses: (2+3)*4 = 20 (parentheses override precedence)', () {
          // Parentheses force: 2+3 = 5, then 5*4 = 20
          expect(useCase.execute('(2+3)*4'), equals('20'));
        });

        test('demonstrates parentheses change result from 14 to 20', () {
          // This test explicitly shows how parentheses change the order of operations
          final withoutParens = useCase.execute('2+3*4');
          final withParens = useCase.execute('(2+3)*4');
          
          expect(withoutParens, equals('14'), reason: '2+3*4 should be 14 (multiplication first)');
          expect(withParens, equals('20'), reason: '(2+3)*4 should be 20 (parentheses first)');
          expect(withoutParens, isNot(equals(withParens)), reason: 'Results should differ');
        });
      });

      group('parentheses with negative numbers', () {
        test('evaluates (-5)+3 in parentheses style', () {
          expect(useCase.execute('(-5)+3'), equals('-2'));
        });

        test('evaluates 2*(-3) = -6', () {
          expect(useCase.execute('2*(-3)'), equals('-6'));
        });

        test('evaluates (-2)*(-3) = 6', () {
          expect(useCase.execute('(-2)*(-3)'), equals('6'));
        });

        test('evaluates (5-10)*2 = -10', () {
          expect(useCase.execute('(5-10)*2'), equals('-10'));
        });
      });

      group('parentheses with decimals', () {
        test('evaluates (1.5+2.5)*2 = 8', () {
          expect(useCase.execute('(1.5+2.5)*2'), equals('8'));
        });

        test('evaluates 10/(2.5+2.5) = 2', () {
          expect(useCase.execute('10/(2.5+2.5)'), equals('2'));
        });
      });

      group('parentheses with division by zero', () {
        test('evaluates (10+5)/0 = Infinity', () {
          expect(useCase.execute('(10+5)/0'), equals('Infinity'));
        });

        test('evaluates 1/(2-2) = Infinity (0 in denominator)', () {
          expect(useCase.execute('1/(2-2)'), equals('Infinity'));
        });

        test('evaluates (0-0)/(0+0) = NaN', () {
          expect(useCase.execute('(0-0)/(0+0)'), equals('NaN'));
        });
      });

      group('parentheses with display operators', () {
        test('evaluates (2+3)×4 = 20', () {
          expect(useCase.execute('(2+3)×4'), equals('20'));
        });

        test('evaluates 10÷(2+3) = 2', () {
          expect(useCase.execute('10÷(2+3)'), equals('2'));
        });

        test('evaluates (6×2)+5 = 17', () {
          expect(useCase.execute('(6×2)+5'), equals('17'));
        });
      });
    });

    group('malformed parentheses - error handling (implementation step 6)', () {
      test('unmatched opening parenthesis returns Error: (2+3', () {
        expect(useCase.execute('(2+3'), equals('Error'));
      });

      test('unmatched closing parenthesis returns Error: 2+3)', () {
        expect(useCase.execute('2+3)'), equals('Error'));
      });

      test('extra opening parenthesis returns Error', () {
        expect(useCase.execute('((2+3)*4'), equals('Error'));
      });

      test('extra closing parenthesis returns Error', () {
        expect(useCase.execute('(2+3)*4)'), equals('Error'));
      });

      test('mismatched parentheses order returns Error', () {
        expect(useCase.execute(')(2+3)('), equals('Error'));
      });

      test('empty parentheses returns Error', () {
        expect(useCase.execute('2+()'), equals('Error'));
      });

      test('nested empty parentheses returns Error', () {
        expect(useCase.execute('2+(())'), equals('Error'));
      });

      test('multiple unmatched parentheses returns Error', () {
        expect(useCase.execute('((2+3'), equals('Error'));
      });

      test('closing before opening returns Error', () {
        expect(useCase.execute(')2+3('), equals('Error'));
      });
    });

    group('complex expressions with parentheses', () {
      test('evaluates 2+3*(4+5)-6/2 correctly', () {
        // 4+5 = 9, 3*9 = 27, 6/2 = 3
        // 2 + 27 - 3 = 26
        expect(useCase.execute('2+3*(4+5)-6/2'), equals('26'));
      });

      test('evaluates (2+3)*4/(5-3) correctly', () {
        // 2+3 = 5, 5-3 = 2
        // 5*4 = 20, 20/2 = 10
        expect(useCase.execute('(2+3)*4/(5-3)'), equals('10'));
      });

      test('evaluates ((2+3)*4+5)*2 correctly', () {
        // 2+3 = 5, 5*4 = 20, 20+5 = 25, 25*2 = 50
        expect(useCase.execute('((2+3)*4+5)*2'), equals('50'));
      });

      test('evaluates 100/(2*(3+2)) correctly', () {
        // 3+2 = 5, 2*5 = 10, 100/10 = 10
        expect(useCase.execute('100/(2*(3+2))'), equals('10'));
      });
    });
  });
}
