import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/domain/entities/expression.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/clear_expression_use_case.dart';

void main() {
  late ClearExpressionUseCase useCase;

  setUp(() {
    useCase = ClearExpressionUseCase();
  });

  group('ClearExpressionUseCase', () {
    group('clearing non-empty expressions', () {
      test('clears a simple numeric expression', () {
        final result = useCase.execute();
        
        expect(result.expression.value, equals(''));
        expect(result.expression.isEmpty, isTrue);
      });

      test('result expression is empty when clearing 123+456', () {
        // The use case always returns an empty expression
        // The previous state doesn't matter since clear always resets
        final result = useCase.execute();
        
        expect(result.expression.value, equals(''));
        expect(result.expression.cursorPosition, equals(0));
      });

      test('result expression is empty when clearing complex expression', () {
        // Verify that clear returns empty expression for any complex expression
        final result = useCase.execute();
        
        expect(result.expression.value, equals(''));
        expect(result.expression.length, equals(0));
      });

      test('result expression is empty when clearing expression with parentheses', () {
        final result = useCase.execute();
        
        expect(result.expression.value, equals(''));
        expect(result.expression.isEmpty, isTrue);
      });

      test('result expression is empty when clearing expression with decimals', () {
        final result = useCase.execute();
        
        expect(result.expression.value, equals(''));
        expect(result.expression.isEmpty, isTrue);
      });

      test('result expression is empty when clearing single digit', () {
        final result = useCase.execute();
        
        expect(result.expression.value, equals(''));
        expect(result.expression.isEmpty, isTrue);
      });
    });

    group('clearing already empty expressions', () {
      test('result is empty expression when clearing empty expression', () {
        final result = useCase.execute();
        
        expect(result.expression.value, equals(''));
        expect(result.expression.isEmpty, isTrue);
      });

      test('cursor position is 0 when clearing empty expression', () {
        final result = useCase.execute();
        
        expect(result.expression.cursorPosition, equals(0));
      });

      test('result equals Expression.empty() when clearing empty expression', () {
        final result = useCase.execute();
        
        expect(result.expression, equals(Expression.empty()));
      });
    });

    group('bracket state reset to left bracket', () {
      test('leftBracketNext is true after clear (bracket toggle reset)', () {
        final result = useCase.execute();
        
        expect(result.leftBracketNext, isTrue);
      });

      test('bracket state indicates next bracket should be opening bracket', () {
        // When leftBracketNext is true, the next parenthesis insertion
        // should be '(' instead of ')'
        final result = useCase.execute();
        
        expect(result.leftBracketNext, equals(true));
      });

      test('bracket state is always reset regardless of previous state', () {
        // The clear operation always resets leftBracketNext to true
        // This ensures the calculator starts fresh with '(' as next bracket
        final result = useCase.execute();
        
        expect(result.leftBracketNext, isTrue);
      });

      test('multiple clears always result in leftBracketNext being true', () {
        final result1 = useCase.execute();
        final result2 = useCase.execute();
        final result3 = useCase.execute();
        
        expect(result1.leftBracketNext, isTrue);
        expect(result2.leftBracketNext, isTrue);
        expect(result3.leftBracketNext, isTrue);
      });
    });

    group('cursor position reset to 0', () {
      test('cursor position is 0 after clear', () {
        final result = useCase.execute();
        
        expect(result.expression.cursorPosition, equals(0));
      });

      test('cursor position is at start of expression', () {
        final result = useCase.execute();
        
        // Cursor at 0 means it's at the start
        expect(result.expression.cursorPosition, equals(0));
      });

      test('cursor position equals expression length for empty expression', () {
        final result = useCase.execute();
        
        // For empty expression, cursor position 0 equals length 0
        expect(result.expression.cursorPosition, equals(result.expression.length));
      });
    });

    group('ClearResult properties', () {
      test('ClearResult contains expression and leftBracketNext', () {
        final result = useCase.execute();
        
        expect(result.expression, isNotNull);
        expect(result.leftBracketNext, isNotNull);
      });

      test('ClearResult expression is empty Expression', () {
        final result = useCase.execute();
        
        expect(result.expression.isEmpty, isTrue);
        expect(result.expression.value, equals(''));
      });

      test('ClearResult toString includes expression and leftBracketNext', () {
        final result = useCase.execute();
        final stringRepresentation = result.toString();
        
        expect(stringRepresentation, contains('ClearResult'));
        expect(stringRepresentation, contains('expression'));
        expect(stringRepresentation, contains('leftBracketNext'));
      });
    });

    group('ClearResult equality', () {
      test('two ClearResults with same values are equal', () {
        final result1 = useCase.execute();
        final result2 = useCase.execute();
        
        expect(result1, equals(result2));
      });

      test('ClearResult equals itself', () {
        final result = useCase.execute();
        
        expect(result, equals(result));
      });

      test('ClearResult hashCode is consistent', () {
        final result1 = useCase.execute();
        final result2 = useCase.execute();
        
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('ClearResult created manually equals executed result', () {
        final executedResult = useCase.execute();
        final manualResult = ClearResult(
          expression: Expression.empty(),
          leftBracketNext: true,
        );
        
        expect(executedResult, equals(manualResult));
      });

      test('ClearResult with different expression is not equal', () {
        final result = useCase.execute();
        final differentResult = ClearResult(
          expression: Expression('123'),
          leftBracketNext: true,
        );
        
        expect(result, isNot(equals(differentResult)));
      });

      test('ClearResult with different leftBracketNext is not equal', () {
        final result = useCase.execute();
        final differentResult = ClearResult(
          expression: Expression.empty(),
          leftBracketNext: false,
        );
        
        expect(result, isNot(equals(differentResult)));
      });
    });

    group('use case consistency', () {
      test('execute is stateless and returns same result each time', () {
        final result1 = useCase.execute();
        final result2 = useCase.execute();
        final result3 = useCase.execute();
        
        expect(result1.expression.value, equals(result2.expression.value));
        expect(result2.expression.value, equals(result3.expression.value));
        expect(result1.leftBracketNext, equals(result2.leftBracketNext));
        expect(result2.leftBracketNext, equals(result3.leftBracketNext));
      });

      test('multiple use case instances return same result', () {
        final useCase1 = ClearExpressionUseCase();
        final useCase2 = ClearExpressionUseCase();
        
        final result1 = useCase1.execute();
        final result2 = useCase2.execute();
        
        expect(result1, equals(result2));
      });

      test('clear result is always a fresh empty state', () {
        final result = useCase.execute();
        
        // Verify all aspects of a fresh calculator state
        expect(result.expression.value, equals(''));
        expect(result.expression.cursorPosition, equals(0));
        expect(result.expression.isEmpty, isTrue);
        expect(result.leftBracketNext, isTrue);
      });
    });

    group('integration scenarios', () {
      test('clear result can be used to start new expression', () {
        final clearResult = useCase.execute();
        
        // After clear, we should be able to insert characters
        final newExpression = clearResult.expression.insertAt('5');
        
        expect(newExpression.value, equals('5'));
        expect(newExpression.cursorPosition, equals(1));
      });

      test('clear result expression can insert parenthesis', () {
        final clearResult = useCase.execute();
        
        // Since leftBracketNext is true, insert opening bracket
        final newExpression = clearResult.expression.insertParenthesis('(');
        
        expect(newExpression.value, equals('('));
      });

      test('clear provides valid initial state for calculator', () {
        final result = useCase.execute();
        
        // The result should represent a valid initial calculator state
        expect(result.expression, equals(Expression.empty()));
        expect(result.leftBracketNext, isTrue);
      });
    });
  });
}
