import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/domain/entities/expression.dart';

void main() {
  group('Expression', () {
    group('constructor and basic properties', () {
      test('creates expression with value and default cursor at end', () {
        final expression = Expression('123');
        
        expect(expression.value, equals('123'));
        expect(expression.cursorPosition, equals(3));
      });

      test('creates expression with explicit cursor position', () {
        final expression = Expression('abc', 1);
        
        expect(expression.value, equals('abc'));
        expect(expression.cursorPosition, equals(1));
      });

      test('empty factory creates empty expression with cursor at 0', () {
        final expression = Expression.empty();
        
        expect(expression.value, equals(''));
        expect(expression.cursorPosition, equals(0));
        expect(expression.isEmpty, isTrue);
      });
    });

    group('deleteCharacterAtCursor', () {
      group('basic deletion scenarios', () {
        test('deletes character at end of expression', () {
          final expression = Expression('123', 3);
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(result.value, equals('12'));
          expect(result.cursorPosition, equals(2));
        });

        test('deletes character in middle of expression', () {
          final expression = Expression('123', 2);
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(result.value, equals('13'));
          expect(result.cursorPosition, equals(1));
        });

        test('deletes first character when cursor at position 1', () {
          final expression = Expression('123', 1);
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(result.value, equals('23'));
          expect(result.cursorPosition, equals(0));
        });

        test('deletes single character leaving empty expression', () {
          final expression = Expression('x', 1);
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(result.value, equals(''));
          expect(result.cursorPosition, equals(0));
          expect(result.isEmpty, isTrue);
        });
      });

      group('edge cases - cursor at position 0', () {
        test('returns same expression when cursor at position 0', () {
          final expression = Expression('123', 0);
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(result.value, equals('123'));
          expect(result.cursorPosition, equals(0));
          expect(result, equals(expression));
        });

        test('returns same expression for single character with cursor at 0', () {
          final expression = Expression('a', 0);
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(result.value, equals('a'));
          expect(result.cursorPosition, equals(0));
        });
      });

      group('edge cases - empty expression', () {
        test('returns same expression when expression is empty', () {
          final expression = Expression.empty();
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(result.value, equals(''));
          expect(result.cursorPosition, equals(0));
          expect(result, equals(expression));
        });

        test('returns empty expression for explicit empty string', () {
          final expression = Expression('', 0);
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(result.isEmpty, isTrue);
        });
      });

      group('character type deletions', () {
        test('deletes digit correctly', () {
          final expression = Expression('5', 1);
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(result.value, equals(''));
        });

        test('deletes operator correctly', () {
          final expression = Expression('+', 1);
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(result.value, equals(''));
        });

        test('deletes decimal point correctly', () {
          final expression = Expression('.', 1);
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(result.value, equals(''));
        });

        test('deletes opening parenthesis correctly', () {
          final expression = Expression('(', 1);
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(result.value, equals(''));
        });

        test('deletes closing parenthesis correctly', () {
          final expression = Expression(')', 1);
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(result.value, equals(''));
        });

        test('deletes power operator correctly', () {
          final expression = Expression('^', 1);
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(result.value, equals(''));
        });
      });

      group('complex expression deletions', () {
        test('deletes from complex arithmetic expression', () {
          final expression = Expression('1+2*3', 3); // cursor after '2'
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(result.value, equals('1+*3'));
          expect(result.cursorPosition, equals(2));
        });

        test('deletes from expression with parentheses', () {
          final expression = Expression('(1+2)', 5);
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(result.value, equals('(1+2'));
          expect(result.cursorPosition, equals(4));
        });

        test('deletes from expression with decimals', () {
          final expression = Expression('3.14', 4);
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(result.value, equals('3.1'));
          expect(result.cursorPosition, equals(3));
        });

        test('deletes decimal point from number', () {
          final expression = Expression('3.14', 2); // cursor after '.'
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(result.value, equals('314'));
          expect(result.cursorPosition, equals(1));
        });
      });

      group('successive deletions', () {
        test('successive deletions from end work correctly', () {
          var expression = Expression('abc', 3);
          
          expression = expression.deleteCharacterAtCursor();
          expect(expression.value, equals('ab'));
          expect(expression.cursorPosition, equals(2));
          
          expression = expression.deleteCharacterAtCursor();
          expect(expression.value, equals('a'));
          expect(expression.cursorPosition, equals(1));
          
          expression = expression.deleteCharacterAtCursor();
          expect(expression.value, equals(''));
          expect(expression.cursorPosition, equals(0));
        });

        test('deletion stops at position 0', () {
          var expression = Expression('a', 1);
          
          expression = expression.deleteCharacterAtCursor();
          expect(expression.value, equals(''));
          
          // Further deletions should have no effect
          expression = expression.deleteCharacterAtCursor();
          expect(expression.value, equals(''));
          expect(expression.cursorPosition, equals(0));
        });
      });

      group('immutability', () {
        test('original expression is not modified', () {
          final original = Expression('test', 4);
          
          original.deleteCharacterAtCursor();
          
          expect(original.value, equals('test'));
          expect(original.cursorPosition, equals(4));
        });

        test('returns new Expression instance', () {
          final expression = Expression('ab', 2);
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(identical(expression, result), isFalse);
        });

        test('returns same instance when no deletion possible (cursor at 0)', () {
          final expression = Expression('test', 0);
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(identical(expression, result), isTrue);
        });

        test('returns same instance when no deletion possible (empty)', () {
          final expression = Expression.empty();
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(identical(expression, result), isTrue);
        });
      });

      group('cursor position validation', () {
        test('cursor position decrements by exactly 1 after deletion', () {
          final expression = Expression('12345', 5);
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(result.cursorPosition, equals(4));
        });

        test('cursor position is within valid bounds after deletion', () {
          final expression = Expression('abc', 2);
          
          final result = expression.deleteCharacterAtCursor();
          
          expect(result.cursorPosition, greaterThanOrEqualTo(0));
          expect(result.cursorPosition, lessThanOrEqualTo(result.length));
        });

        test('cursor at various positions deletes correct character', () {
          // Cursor at position 1 deletes character at index 0
          var expr = Expression('abcde', 1);
          expect(expr.deleteCharacterAtCursor().value, equals('bcde'));
          
          // Cursor at position 2 deletes character at index 1
          expr = Expression('abcde', 2);
          expect(expr.deleteCharacterAtCursor().value, equals('acde'));
          
          // Cursor at position 3 deletes character at index 2
          expr = Expression('abcde', 3);
          expect(expr.deleteCharacterAtCursor().value, equals('abde'));
          
          // Cursor at position 4 deletes character at index 3
          expr = Expression('abcde', 4);
          expect(expr.deleteCharacterAtCursor().value, equals('abce'));
          
          // Cursor at position 5 deletes character at index 4
          expr = Expression('abcde', 5);
          expect(expr.deleteCharacterAtCursor().value, equals('abcd'));
        });
      });
    });

    group('deleteBeforeCursor (alias behavior)', () {
      test('deleteBeforeCursor behaves same as deleteCharacterAtCursor', () {
        final expression = Expression('123', 3);
        
        final resultDelete = expression.deleteBeforeCursor();
        final resultCharDelete = expression.deleteCharacterAtCursor();
        
        expect(resultDelete.value, equals(resultCharDelete.value));
        expect(resultDelete.cursorPosition, equals(resultCharDelete.cursorPosition));
      });

      test('deleteBeforeCursor returns same expression at position 0', () {
        final expression = Expression('abc', 0);
        
        final result = expression.deleteBeforeCursor();
        
        expect(result, equals(expression));
      });
    });

    group('Expression equality and hashCode', () {
      test('expressions with same value and cursor are equal', () {
        final expr1 = Expression('test', 2);
        final expr2 = Expression('test', 2);
        
        expect(expr1, equals(expr2));
      });

      test('expressions with different values are not equal', () {
        final expr1 = Expression('abc', 2);
        final expr2 = Expression('xyz', 2);
        
        expect(expr1, isNot(equals(expr2)));
      });

      test('expressions with different cursor positions are not equal', () {
        final expr1 = Expression('test', 1);
        final expr2 = Expression('test', 2);
        
        expect(expr1, isNot(equals(expr2)));
      });

      test('hashCode is consistent for equal expressions', () {
        final expr1 = Expression('hello', 3);
        final expr2 = Expression('hello', 3);
        
        expect(expr1.hashCode, equals(expr2.hashCode));
      });
    });

    group('integration with other Expression methods', () {
      test('delete then insert works correctly', () {
        final expression = Expression('123', 3);
        
        final afterDelete = expression.deleteCharacterAtCursor();
        final afterInsert = afterDelete.insertAt('9');
        
        expect(afterInsert.value, equals('129'));
        expect(afterInsert.cursorPosition, equals(3));
      });

      test('delete then append works correctly', () {
        final expression = Expression('abc', 3);
        
        final afterDelete = expression.deleteCharacterAtCursor();
        final afterAppend = afterDelete.append('z');
        
        expect(afterAppend.value, equals('abz'));
      });

      test('delete then clear works correctly', () {
        final expression = Expression('test', 4);
        
        final afterDelete = expression.deleteCharacterAtCursor();
        final afterClear = afterDelete.clear();
        
        expect(afterClear, equals(Expression.empty()));
      });

      test('delete then moveCursor works correctly', () {
        final expression = Expression('12345', 5);
        
        final afterDelete = expression.deleteCharacterAtCursor();
        final afterMove = afterDelete.moveCursor(2);
        
        expect(afterMove.value, equals('1234'));
        expect(afterMove.cursorPosition, equals(2));
      });
    });
  });
}
