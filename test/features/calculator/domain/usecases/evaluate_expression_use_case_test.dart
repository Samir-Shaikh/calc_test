import 'package:flutter_test/flutter_test.dart';
import 'package:samplecalc/features/calculator/domain/usecases/evaluate_expression_use_case.dart';

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
        test('evaluates (2+3)*4 = 20', () {
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
      });

      group('multiple separate parentheses', () {
        test('evaluates (2+3)+(4+5) = 14', () {
          expect(useCase.execute('(2+3)+(4+5)'), equals('14'));
        });

        test('evaluates (2+3)*(4+5) = 45', () {
          expect(useCase.execute('(2+3)*(4+5)'), equals('45'));
        });

        test('evaluates (10-2)/(2+2) = 2', () {
          expect(useCase.execute('(10-2)/(2+2)'), equals('2'));
        });

        test('evaluates (3*2)-(2*1) = 4', () {
          expect(useCase.execute('(3*2)-(2*1)'), equals('4'));
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

    group('malformed parentheses - error handling', () {
      test('unmatched opening parenthesis returns Error', () {
        expect(useCase.execute('(2+3'), equals('Error'));
      });

      test('unmatched closing parenthesis returns Error', () {
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
