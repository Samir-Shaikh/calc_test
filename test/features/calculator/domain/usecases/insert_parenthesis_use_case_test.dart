import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/domain/entities/expression.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_parenthesis_use_case.dart';

void main() {
  late InsertParenthesisUseCase useCase;

  setUp(() {
    useCase = InsertParenthesisUseCase();
  });

  group('InsertParenthesisUseCase', () {
    group('initial state', () {
      test('leftBracket starts as true', () {
        expect(useCase.leftBracket, isTrue);
      });

      test('first execute() inserts left bracket', () {
        final expression = Expression('5+');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('5+('));
      });

      test('first execute() on empty expression inserts left bracket', () {
        final expression = Expression.empty();
        final result = useCase.execute(expression);
        
        expect(result.value, equals('('));
      });
    });

    group('toggle behavior', () {
      test('leftBracket becomes false after first execute()', () {
        final expression = Expression('5+');
        useCase.execute(expression);
        
        expect(useCase.leftBracket, isFalse);
      });

      test('second execute() inserts right bracket', () {
        var expression = Expression('5+');
        expression = useCase.execute(expression); // Inserts '('
        expression = useCase.execute(expression); // Inserts ')'
        
        expect(expression.value, equals('5+()'));
      });

      test('leftBracket becomes true after second execute()', () {
        final expression = Expression('5+');
        useCase.execute(expression);
        useCase.execute(Expression('5+('));
        
        expect(useCase.leftBracket, isTrue);
      });
    });

    group('alternating behavior', () {
      test('multiple presses alternate between ( and )', () {
        var expression = Expression('');
        
        // First press - left bracket
        expression = useCase.execute(expression);
        expect(expression.value, equals('('));
        expect(useCase.leftBracket, isFalse);
        
        // Second press - right bracket
        expression = useCase.execute(expression);
        expect(expression.value, equals('()'));
        expect(useCase.leftBracket, isTrue);
        
        // Third press - left bracket again
        expression = useCase.execute(expression);
        expect(expression.value, equals('()('));
        expect(useCase.leftBracket, isFalse);
        
        // Fourth press - right bracket again
        expression = useCase.execute(expression);
        expect(expression.value, equals('()()'));
        expect(useCase.leftBracket, isTrue);
      });

      test('six consecutive presses produce correct pattern', () {
        var expression = Expression('1+');
        
        expression = useCase.execute(expression); // (
        expression = useCase.execute(expression); // )
        expression = useCase.execute(expression); // (
        expression = useCase.execute(expression); // )
        expression = useCase.execute(expression); // (
        expression = useCase.execute(expression); // )
        
        expect(expression.value, equals('1+()()()'));
      });

      test('nested parentheses pattern works correctly', () {
        var expression = Expression('');
        
        // Build ((()))
        expression = useCase.execute(expression); // (
        expect(expression.value, equals('('));
        
        expression = useCase.execute(expression); // )
        expect(expression.value, equals('()'));
        
        // Continue building
        expression = useCase.execute(expression); // (
        expect(expression.value, equals('()('));
        
        expression = useCase.execute(expression); // )
        expect(expression.value, equals('()()'));
      });
    });

    group('reset functionality', () {
      test('resetBracketState() sets leftBracket back to true', () {
        final expression = Expression('5+');
        useCase.execute(expression); // leftBracket becomes false
        
        expect(useCase.leftBracket, isFalse);
        
        useCase.resetBracketState();
        
        expect(useCase.leftBracket, isTrue);
      });

      test('after reset, next execute() inserts left bracket', () {
        var expression = Expression('5+');
        expression = useCase.execute(expression); // Inserts '(' -> leftBracket false
        
        useCase.resetBracketState();
        
        expression = useCase.execute(expression); // Should insert '(' again
        
        expect(expression.value, equals('5+(('));
      });

      test('reset after multiple presses works correctly', () {
        var expression = Expression('');
        
        // Press multiple times
        // 1st: '' -> '(' (leftBracket becomes false)
        expression = useCase.execute(expression);
        expect(expression.value, equals('('));
        
        // 2nd: '(' -> '()' (leftBracket becomes true)
        expression = useCase.execute(expression);
        expect(expression.value, equals('()'));
        
        // 3rd: '()' -> '()(' (leftBracket becomes false)
        expression = useCase.execute(expression);
        expect(expression.value, equals('()('));
        
        expect(useCase.leftBracket, isFalse);
        
        // Reset - leftBracket becomes true
        useCase.resetBracketState();
        expect(useCase.leftBracket, isTrue);
        
        // Next press should insert '(' since we reset
        // '()(' -> '()(('
        expression = useCase.execute(expression);
        expect(expression.value, equals('()(('));
      });

      test('reset when already at initial state has no effect', () {
        expect(useCase.leftBracket, isTrue);
        
        useCase.resetBracketState();
        
        expect(useCase.leftBracket, isTrue);
        
        // First execute should still insert left bracket
        final expression = Expression('');
        final result = useCase.execute(expression);
        expect(result.value, equals('('));
      });

      test('multiple resets work correctly', () {
        final expression = Expression('');
        
        useCase.execute(expression); // leftBracket -> false
        useCase.resetBracketState(); // leftBracket -> true
        useCase.resetBracketState(); // still true
        useCase.resetBracketState(); // still true
        
        expect(useCase.leftBracket, isTrue);
      });
    });

    group('cursor positioning', () {
      test('parenthesis inserted at cursor position in middle of expression', () {
        // Expression with cursor at position 2 (after '5+')
        final expression = Expression('5+3', 2);
        final result = useCase.execute(expression);
        
        expect(result.value, equals('5+(3'));
        expect(result.cursorPosition, equals(3));
      });

      test('parenthesis inserted at beginning when cursor at 0', () {
        final expression = Expression('5+3', 0);
        final result = useCase.execute(expression);
        
        expect(result.value, equals('(5+3'));
        expect(result.cursorPosition, equals(1));
      });

      test('parenthesis inserted at end when cursor at end', () {
        final expression = Expression('5+3', 3);
        final result = useCase.execute(expression);
        
        expect(result.value, equals('5+3('));
        expect(result.cursorPosition, equals(4));
      });

      test('cursor moves forward after insertion', () {
        final expression = Expression('1+2', 1);
        final result = useCase.execute(expression);
        
        expect(result.cursorPosition, equals(2));
      });

      test('multiple insertions at same cursor position', () {
        // Insert at position 2, cursor should move with each insertion
        var expression = Expression('abc', 1);
        
        expression = useCase.execute(expression); // Insert '(' at position 1
        expect(expression.value, equals('a(bc'));
        expect(expression.cursorPosition, equals(2));
        
        expression = useCase.execute(expression); // Insert ')' at position 2
        expect(expression.value, equals('a()bc'));
        expect(expression.cursorPosition, equals(3));
      });

      test('insertions with cursor tracking through complex expression', () {
        var expression = Expression('10+5*2', 3); // Cursor after '10+'
        
        expression = useCase.execute(expression); // Insert '('
        expect(expression.value, equals('10+(5*2'));
        expect(expression.cursorPosition, equals(4));
        
        // Move cursor to end and insert closing bracket
        expression = Expression(expression.value, expression.value.length);
        expression = useCase.execute(expression); // Insert ')'
        expect(expression.value, equals('10+(5*2)'));
        expect(expression.cursorPosition, equals(8));
      });
    });

    group('expression value preservation', () {
      test('original expression value is preserved before insertion point', () {
        final expression = Expression('123+456', 4); // Cursor after '123+'
        final result = useCase.execute(expression);
        
        expect(result.value.startsWith('123+'), isTrue);
      });

      test('original expression value is preserved after insertion point', () {
        final expression = Expression('123+456', 4); // Cursor after '123+'
        final result = useCase.execute(expression);
        
        expect(result.value.endsWith('456'), isTrue);
      });

      test('complete expression structure with insertion', () {
        final expression = Expression('abc', 1);
        final result = useCase.execute(expression);
        
        expect(result.value, equals('a(bc'));
      });
    });

    group('edge cases', () {
      test('works with expression containing existing parentheses', () {
        var expression = Expression('(1+2)*');
        expression = useCase.execute(expression);
        
        expect(expression.value, equals('(1+2)*('));
      });

      test('works with decimal numbers', () {
        var expression = Expression('1.5+');
        expression = useCase.execute(expression);
        
        expect(expression.value, equals('1.5+('));
      });

      test('works with display operators (× and ÷)', () {
        var expression = Expression('5×');
        expression = useCase.execute(expression);
        
        expect(expression.value, equals('5×('));
      });

      test('works with negative numbers', () {
        var expression = Expression('-5+');
        expression = useCase.execute(expression);
        
        expect(expression.value, equals('-5+('));
      });

      test('works with long expressions', () {
        var expression = Expression('123456789+987654321*');
        expression = useCase.execute(expression);
        
        expect(expression.value, equals('123456789+987654321*('));
      });

      test('separate use case instances have independent state', () {
        final useCase1 = InsertParenthesisUseCase();
        final useCase2 = InsertParenthesisUseCase();
        
        // Both start with leftBracket = true
        expect(useCase1.leftBracket, isTrue);
        expect(useCase2.leftBracket, isTrue);
        
        // Execute on useCase1
        useCase1.execute(Expression(''));
        
        // useCase1 should be false, useCase2 should still be true
        expect(useCase1.leftBracket, isFalse);
        expect(useCase2.leftBracket, isTrue);
      });
    });

    group('integration scenarios', () {
      test('building a complete parenthesized expression', () {
        var expression = Expression('2*');
        
        // Add opening parenthesis
        expression = useCase.execute(expression);
        expect(expression.value, equals('2*('));
        
        // Simulate adding numbers (not part of use case)
        expression = Expression(expression.value + '3+4', expression.value.length + 3);
        expect(expression.value, equals('2*(3+4'));
        
        // Add closing parenthesis
        expression = useCase.execute(expression);
        expect(expression.value, equals('2*(3+4)'));
      });

      test('simulating clear and restart scenario', () {
        var expression = Expression('');
        
        // Build some expression with parentheses
        expression = useCase.execute(expression); // (
        expression = useCase.execute(expression); // ()
        
        // Simulate clear button - reset expression and bracket state
        expression = Expression.empty();
        useCase.resetBracketState();
        
        // Start fresh - should insert left bracket
        expression = useCase.execute(expression);
        expect(expression.value, equals('('));
        expect(useCase.leftBracket, isFalse);
      });

      test('typical calculator usage pattern', () {
        // User presses: ( 5 + 3 ) * 2
        var expression = Expression('');
        
        // Press (
        expression = useCase.execute(expression);
        expect(expression.value, equals('('));
        
        // Add 5+3 (simulated)
        expression = Expression(expression.value + '5+3', expression.value.length + 3);
        
        // Press )
        expression = useCase.execute(expression);
        expect(expression.value, equals('(5+3)'));
        
        // Add *2 (simulated)
        expression = Expression(expression.value + '*2', expression.value.length + 2);
        expect(expression.value, equals('(5+3)*2'));
      });
    });
  });
}
