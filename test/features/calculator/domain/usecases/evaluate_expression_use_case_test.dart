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
  });
}
