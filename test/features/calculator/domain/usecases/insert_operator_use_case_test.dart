import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/domain/entities/expression.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_operator_use_case.dart';

void main() {
  late InsertOperatorUseCase useCase;

  setUp(() {
    useCase = InsertOperatorUseCase();
  });

  group('InsertOperatorUseCase', () {
    group('power operator (^) - basic insertion', () {
      test('inserts ^ after a single digit', () {
        final expression = Expression('2');
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('2^'));
      });

      test('inserts ^ after multiple digits', () {
        final expression = Expression('123');
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('123^'));
      });

      test('inserts ^ after a decimal number', () {
        final expression = Expression('3.14');
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('3.14^'));
      });

      test('inserts ^ in complex expression after number', () {
        final expression = Expression('2+3');
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('2+3^'));
      });

      test('cursor position updates correctly after ^ insertion', () {
        final expression = Expression('5');
        final result = useCase.execute(expression, '^');
        
        expect(result.cursorPosition, equals(2));
      });
    });

    group('power operator (^) - preventing insertion at expression start', () {
      test('does not insert ^ at start of empty expression', () {
        final expression = Expression.empty();
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals(''));
        expect(result.isEmpty, isTrue);
      });

      test('empty expression remains unchanged when ^ is attempted', () {
        final expression = Expression('');
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals(''));
      });

      test('allows minus at start of empty expression (for negative numbers)', () {
        final expression = Expression.empty();
        final result = useCase.execute(expression, '-');
        
        expect(result.value, equals('-'));
      });
    });

    group('power operator (^) - operator replacement', () {
      test('replaces + with ^ when ^ pressed after +', () {
        final expression = Expression('2+');
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('2^'));
      });

      test('replaces - with ^ when ^ pressed after -', () {
        final expression = Expression('5-');
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('5^'));
      });

      test('replaces * with ^ when ^ pressed after *', () {
        final expression = Expression('3*');
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('3^'));
      });

      test('replaces / with ^ when ^ pressed after /', () {
        final expression = Expression('10/');
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('10^'));
      });

      test('replaces × with ^ when ^ pressed after ×', () {
        final expression = Expression('4×');
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('4^'));
      });

      test('replaces ÷ with ^ when ^ pressed after ÷', () {
        final expression = Expression('8÷');
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('8^'));
      });

      test('replaces ^ with another operator', () {
        final expression = Expression('2^');
        final result = useCase.execute(expression, '+');
        
        expect(result.value, equals('2+'));
      });

      test('replaces ^ with ^ (no change in value)', () {
        final expression = Expression('2^');
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('2^'));
      });
    });

    group('power operator (^) - after closing parenthesis', () {
      test('inserts ^ after closing parenthesis', () {
        final expression = Expression('(2+3)');
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('(2+3)^'));
      });

      test('inserts ^ after nested closing parenthesis', () {
        final expression = Expression('((2+3)*4)');
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('((2+3)*4)^'));
      });

      test('inserts ^ after complex parenthesized expression', () {
        final expression = Expression('(5-2)*(3+1)');
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('(5-2)*(3+1)^'));
      });

      test('inserts ^ after simple grouped expression', () {
        final expression = Expression('(10)');
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('(10)^'));
      });
    });

    group('power operator (^) - after opening parenthesis', () {
      test('does not insert ^ immediately after opening parenthesis', () {
        final expression = Expression('(');
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('('));
      });

      test('does not insert ^ after opening parenthesis in expression', () {
        final expression = Expression('2+(');
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('2+('));
      });

      test('allows minus after opening parenthesis (for negative numbers)', () {
        final expression = Expression('2+(');
        final result = useCase.execute(expression, '-');
        
        expect(result.value, equals('2+(-'));
      });
    });

    group('power operator (^) - cursor positioning', () {
      test('inserts ^ at cursor position in middle of expression', () {
        // Expression "2+3" with cursor after "2"
        final expression = Expression('2+3', 1);
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('2^+3'));
        expect(result.cursorPosition, equals(2));
      });

      test('inserts ^ at cursor position and moves cursor forward', () {
        final expression = Expression('123', 2);
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('12^3'));
        expect(result.cursorPosition, equals(3));
      });
    });

    group('all operators - basic functionality', () {
      test('inserts + after number', () {
        final expression = Expression('5');
        final result = useCase.execute(expression, '+');
        
        expect(result.value, equals('5+'));
      });

      test('inserts - after number', () {
        final expression = Expression('5');
        final result = useCase.execute(expression, '-');
        
        expect(result.value, equals('5-'));
      });

      test('inserts * after number', () {
        final expression = Expression('5');
        final result = useCase.execute(expression, '*');
        
        expect(result.value, equals('5*'));
      });

      test('inserts / after number', () {
        final expression = Expression('5');
        final result = useCase.execute(expression, '/');
        
        expect(result.value, equals('5/'));
      });

      test('inserts × after number', () {
        final expression = Expression('5');
        final result = useCase.execute(expression, '×');
        
        expect(result.value, equals('5×'));
      });

      test('inserts ÷ after number', () {
        final expression = Expression('5');
        final result = useCase.execute(expression, '÷');
        
        expect(result.value, equals('5÷'));
      });
    });

    group('operator validation', () {
      test('throws ArgumentError for invalid operator', () {
        final expression = Expression('5');
        
        expect(
          () => useCase.execute(expression, 'x'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws ArgumentError for number as operator', () {
        final expression = Expression('5');
        
        expect(
          () => useCase.execute(expression, '1'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws ArgumentError for empty string operator', () {
        final expression = Expression('5');
        
        expect(
          () => useCase.execute(expression, ''),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws ArgumentError for parenthesis as operator', () {
        final expression = Expression('5');
        
        expect(
          () => useCase.execute(expression, '('),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('consecutive operator prevention', () {
      test('prevents ++ by replacing first + with second +', () {
        final expression = Expression('5+');
        final result = useCase.execute(expression, '+');
        
        expect(result.value, equals('5+'));
      });

      test('replaces + with - when - pressed after +', () {
        final expression = Expression('5+');
        final result = useCase.execute(expression, '-');
        
        expect(result.value, equals('5-'));
      });

      test('replaces * with / when / pressed after *', () {
        final expression = Expression('5*');
        final result = useCase.execute(expression, '/');
        
        expect(result.value, equals('5/'));
      });

      test('replaces × with ÷ when ÷ pressed after ×', () {
        final expression = Expression('5×');
        final result = useCase.execute(expression, '÷');
        
        expect(result.value, equals('5÷'));
      });
    });

    group('empty expression handling', () {
      test('does not insert + at start', () {
        final expression = Expression.empty();
        final result = useCase.execute(expression, '+');
        
        expect(result.value, equals(''));
      });

      test('does not insert * at start', () {
        final expression = Expression.empty();
        final result = useCase.execute(expression, '*');
        
        expect(result.value, equals(''));
      });

      test('does not insert / at start', () {
        final expression = Expression.empty();
        final result = useCase.execute(expression, '/');
        
        expect(result.value, equals(''));
      });

      test('does not insert × at start', () {
        final expression = Expression.empty();
        final result = useCase.execute(expression, '×');
        
        expect(result.value, equals(''));
      });

      test('does not insert ÷ at start', () {
        final expression = Expression.empty();
        final result = useCase.execute(expression, '÷');
        
        expect(result.value, equals(''));
      });

      test('allows - at start for negative numbers', () {
        final expression = Expression.empty();
        final result = useCase.execute(expression, '-');
        
        expect(result.value, equals('-'));
      });
    });

    group('integration scenarios with power operator', () {
      test('building expression 2^3 step by step', () {
        var expression = Expression('2');
        expression = useCase.execute(expression, '^');
        
        expect(expression.value, equals('2^'));
        
        // User would then add '3' via digit insertion (not part of this use case)
        expression = Expression(expression.value + '3');
        expect(expression.value, equals('2^3'));
      });

      test('building expression (2+3)^2 step by step', () {
        // Start with completed parenthesized expression
        var expression = Expression('(2+3)');
        expression = useCase.execute(expression, '^');
        
        expect(expression.value, equals('(2+3)^'));
      });

      test('changing operator from + to ^ in expression', () {
        var expression = Expression('2+');
        expression = useCase.execute(expression, '^');
        
        expect(expression.value, equals('2^'));
      });

      test('chained power operations setup', () {
        // Build 2^3^ (user would complete with another number)
        var expression = Expression('2');
        expression = useCase.execute(expression, '^');
        expression = Expression(expression.value + '3');
        expression = useCase.execute(expression, '^');
        
        expect(expression.value, equals('2^3^'));
      });

      test('complex expression with power and other operators', () {
        // Build 2*3^ (power after multiplication)
        var expression = Expression('2*3');
        expression = useCase.execute(expression, '^');
        
        expect(expression.value, equals('2*3^'));
      });

      test('power after decimal number', () {
        var expression = Expression('1.5');
        expression = useCase.execute(expression, '^');
        
        expect(expression.value, equals('1.5^'));
      });
    });

    group('edge cases', () {
      test('long expression with power at end', () {
        final expression = Expression('123456789');
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('123456789^'));
      });

      test('expression with multiple operators ending in number accepts ^', () {
        final expression = Expression('1+2*3-4/5');
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('1+2*3-4/5^'));
      });

      test('single digit expression accepts ^', () {
        final expression = Expression('9');
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('9^'));
      });

      test('zero accepts ^', () {
        final expression = Expression('0');
        final result = useCase.execute(expression, '^');
        
        expect(result.value, equals('0^'));
      });
    });
  });
}
