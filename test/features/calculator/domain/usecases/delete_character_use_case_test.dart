import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/domain/entities/expression.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/delete_character_use_case.dart';

void main() {
  late DeleteCharacterUseCase useCase;

  setUp(() {
    useCase = DeleteCharacterUseCase();
  });

  group('DeleteCharacterUseCase', () {
    group('AC1: deletion from end of expression', () {
      test('deleting from "123" with cursor at end results in "12" with cursor at 2', () {
        final expression = Expression('123', 3);
        
        final result = useCase.execute(expression);
        
        expect(result.value, equals('12'));
        expect(result.cursorPosition, equals(2));
      });

      test('deleting from "456" with cursor at end results in "45"', () {
        final expression = Expression('456', 3);
        
        final result = useCase.execute(expression);
        
        expect(result.value, equals('45'));
        expect(result.cursorPosition, equals(2));
      });

      test('deleting single character from end leaves empty expression', () {
        final expression = Expression('5', 1);
        
        final result = useCase.execute(expression);
        
        expect(result.value, equals(''));
        expect(result.cursorPosition, equals(0));
        expect(result.isEmpty, isTrue);
      });

      test('successive deletions from end work correctly', () {
        var expression = Expression('123', 3);
        
        expression = useCase.execute(expression);
        expect(expression.value, equals('12'));
        expect(expression.cursorPosition, equals(2));
        
        expression = useCase.execute(expression);
        expect(expression.value, equals('1'));
        expect(expression.cursorPosition, equals(1));
        
        expression = useCase.execute(expression);
        expect(expression.value, equals(''));
        expect(expression.cursorPosition, equals(0));
      });

      test('deleting from expression with operators at end', () {
        final expression = Expression('12+', 3);
        
        final result = useCase.execute(expression);
        
        expect(result.value, equals('12'));
        expect(result.cursorPosition, equals(2));
      });
    });

    group('AC2: deletion at mid-cursor position', () {
      test('deleting from "1+2" with cursor after "+" (position 2) results in "12" with cursor at 1', () {
        final expression = Expression('1+2', 2); // cursor after '+'
        
        final result = useCase.execute(expression);
        
        expect(result.value, equals('12'));
        expect(result.cursorPosition, equals(1));
      });

      test('deleting from "123" with cursor at position 2 results in "13"', () {
        final expression = Expression('123', 2); // cursor after '2'
        
        final result = useCase.execute(expression);
        
        expect(result.value, equals('13'));
        expect(result.cursorPosition, equals(1));
      });

      test('deleting from "abcde" with cursor at position 3 results in "abde"', () {
        final expression = Expression('12345', 3); // cursor after '3'
        
        final result = useCase.execute(expression);
        
        expect(result.value, equals('1245'));
        expect(result.cursorPosition, equals(2));
      });

      test('deleting from position 1 removes first character', () {
        final expression = Expression('123', 1); // cursor after '1'
        
        final result = useCase.execute(expression);
        
        expect(result.value, equals('23'));
        expect(result.cursorPosition, equals(0));
      });

      test('deleting in middle of complex expression preserves surrounding content', () {
        final expression = Expression('10+20*30', 5); // cursor after '0' in '20'
        
        final result = useCase.execute(expression);
        
        expect(result.value, equals('10+2*30'));
        expect(result.cursorPosition, equals(4));
      });
    });

    group('AC3: empty expression case', () {
      test('backspace on empty expression returns unchanged empty expression', () {
        final expression = Expression.empty();
        
        final result = useCase.execute(expression);
        
        expect(result.value, equals(''));
        expect(result.cursorPosition, equals(0));
        expect(result.isEmpty, isTrue);
      });

      test('backspace on empty expression with explicit cursor at 0', () {
        final expression = Expression('', 0);
        
        final result = useCase.execute(expression);
        
        expect(result.value, equals(''));
        expect(result.cursorPosition, equals(0));
      });

      test('empty expression remains equal to Expression.empty() after backspace', () {
        final expression = Expression.empty();
        
        final result = useCase.execute(expression);
        
        expect(result, equals(Expression.empty()));
      });

      test('multiple backspaces on empty expression have no effect', () {
        var expression = Expression.empty();
        
        expression = useCase.execute(expression);
        expression = useCase.execute(expression);
        expression = useCase.execute(expression);
        
        expect(expression.value, equals(''));
        expect(expression.cursorPosition, equals(0));
      });
    });

    group('AC4: cursor at position 0', () {
      test('backspace with cursor at position 0 returns unchanged expression', () {
        final expression = Expression('123', 0); // cursor at start
        
        final result = useCase.execute(expression);
        
        expect(result.value, equals('123'));
        expect(result.cursorPosition, equals(0));
      });

      test('cursor at position 0 preserves entire expression', () {
        final expression = Expression('1+2*3', 0);
        
        final result = useCase.execute(expression);
        
        expect(result.value, equals('1+2*3'));
        expect(result.cursorPosition, equals(0));
      });

      test('returns same expression object when cursor at position 0', () {
        final expression = Expression('test', 0);
        
        final result = useCase.execute(expression);
        
        expect(result, equals(expression));
      });

      test('cursor at 0 with complex expression returns unchanged', () {
        final expression = Expression('(1+2)*3/4', 0);
        
        final result = useCase.execute(expression);
        
        expect(result.value, equals('(1+2)*3/4'));
        expect(result.cursorPosition, equals(0));
      });
    });

    group('deletion of various character types', () {
      group('digit deletion', () {
        test('deletes digit 0', () {
          final expression = Expression('10', 2);
          final result = useCase.execute(expression);
          expect(result.value, equals('1'));
        });

        test('deletes digit 5', () {
          final expression = Expression('25', 2);
          final result = useCase.execute(expression);
          expect(result.value, equals('2'));
        });

        test('deletes digit 9', () {
          final expression = Expression('89', 2);
          final result = useCase.execute(expression);
          expect(result.value, equals('8'));
        });
      });

      group('operator deletion', () {
        test('deletes plus operator', () {
          final expression = Expression('1+', 2);
          final result = useCase.execute(expression);
          expect(result.value, equals('1'));
        });

        test('deletes minus operator', () {
          final expression = Expression('5-', 2);
          final result = useCase.execute(expression);
          expect(result.value, equals('5'));
        });

        test('deletes multiplication operator', () {
          final expression = Expression('3*', 2);
          final result = useCase.execute(expression);
          expect(result.value, equals('3'));
        });

        test('deletes division operator', () {
          final expression = Expression('8/', 2);
          final result = useCase.execute(expression);
          expect(result.value, equals('8'));
        });

        test('deletes multiplication symbol ×', () {
          final expression = Expression('4×', 2);
          final result = useCase.execute(expression);
          expect(result.value, equals('4'));
        });

        test('deletes division symbol ÷', () {
          final expression = Expression('6÷', 2);
          final result = useCase.execute(expression);
          expect(result.value, equals('6'));
        });

        test('deletes power operator ^', () {
          final expression = Expression('2^', 2);
          final result = useCase.execute(expression);
          expect(result.value, equals('2'));
        });
      });

      group('decimal point deletion', () {
        test('deletes decimal point at end', () {
          final expression = Expression('3.', 2);
          final result = useCase.execute(expression);
          expect(result.value, equals('3'));
        });

        test('deletes decimal point in middle', () {
          final expression = Expression('3.14', 2); // cursor after '.'
          final result = useCase.execute(expression);
          expect(result.value, equals('314'));
          expect(result.cursorPosition, equals(1));
        });

        test('deletes digit after decimal', () {
          final expression = Expression('3.14', 4);
          final result = useCase.execute(expression);
          expect(result.value, equals('3.1'));
        });
      });

      group('parenthesis deletion', () {
        test('deletes opening parenthesis', () {
          final expression = Expression('(', 1);
          final result = useCase.execute(expression);
          expect(result.value, equals(''));
        });

        test('deletes closing parenthesis', () {
          final expression = Expression('(1)', 3);
          final result = useCase.execute(expression);
          expect(result.value, equals('(1'));
        });

        test('deletes opening parenthesis in expression', () {
          final expression = Expression('1+(2', 3); // cursor after '('
          final result = useCase.execute(expression);
          expect(result.value, equals('1+2'));
          expect(result.cursorPosition, equals(2));
        });

        test('deletes closing parenthesis in complex expression', () {
          final expression = Expression('(1+2)*3', 5); // cursor after ')'
          final result = useCase.execute(expression);
          expect(result.value, equals('(1+2*3'));
          expect(result.cursorPosition, equals(4));
        });
      });
    });

    group('use case consistency', () {
      test('execute is stateless - same input produces same output', () {
        final expression = Expression('123', 3);
        
        final result1 = useCase.execute(expression);
        final result2 = useCase.execute(expression);
        
        expect(result1.value, equals(result2.value));
        expect(result1.cursorPosition, equals(result2.cursorPosition));
      });

      test('multiple use case instances produce same result', () {
        final useCase1 = DeleteCharacterUseCase();
        final useCase2 = DeleteCharacterUseCase();
        final expression = Expression('abc', 3);
        
        final result1 = useCase1.execute(expression);
        final result2 = useCase2.execute(expression);
        
        expect(result1, equals(result2));
      });

      test('original expression is not mutated', () {
        final expression = Expression('123', 3);
        final originalValue = expression.value;
        final originalCursor = expression.cursorPosition;
        
        useCase.execute(expression);
        
        expect(expression.value, equals(originalValue));
        expect(expression.cursorPosition, equals(originalCursor));
      });
    });

    group('edge cases and boundary conditions', () {
      test('handles very long expression', () {
        final longExpression = '1' * 100;
        final expression = Expression(longExpression, 100);
        
        final result = useCase.execute(expression);
        
        expect(result.value.length, equals(99));
        expect(result.cursorPosition, equals(99));
      });

      test('handles expression with only operators', () {
        final expression = Expression('+-*/', 4);
        
        final result = useCase.execute(expression);
        
        expect(result.value, equals('+-*'));
        expect(result.cursorPosition, equals(3));
      });

      test('handles mixed characters', () {
        final expression = Expression('1+2.5*(3-4)/5^2', 15);
        
        final result = useCase.execute(expression);
        
        expect(result.value, equals('1+2.5*(3-4)/5^'));
        expect(result.cursorPosition, equals(14));
      });

      test('complete deletion sequence to empty', () {
        var expression = Expression('12', 2);
        
        expression = useCase.execute(expression);
        expect(expression.value, equals('1'));
        
        expression = useCase.execute(expression);
        expect(expression.value, equals(''));
        expect(expression.isEmpty, isTrue);
        
        // Additional backspace on empty should be safe
        expression = useCase.execute(expression);
        expect(expression.value, equals(''));
      });
    });

    group('integration with Expression entity', () {
      test('result can be used for further operations', () {
        final expression = Expression('123', 3);
        
        final afterDelete = useCase.execute(expression);
        final afterInsert = afterDelete.insertAt('9');
        
        expect(afterInsert.value, equals('129'));
        expect(afterInsert.cursorPosition, equals(3));
      });

      test('result maintains valid Expression properties', () {
        final expression = Expression('test', 4);
        
        final result = useCase.execute(expression);
        
        expect(result.length, equals(3));
        expect(result.isNotEmpty, isTrue);
        expect(result.cursorPosition, lessThanOrEqualTo(result.length));
      });

      test('deleted result can be cleared', () {
        final expression = Expression('123', 3);
        
        final afterDelete = useCase.execute(expression);
        final afterClear = afterDelete.clear();
        
        expect(afterClear, equals(Expression.empty()));
      });
    });
  });
}
