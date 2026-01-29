import 'package:flutter_test/flutter_test.dart';
import 'package:samplecalc/features/calculator/domain/usecases/insert_parenthesis_use_case.dart';
import 'package:samplecalc/features/calculator/domain/entities/expression.dart';

void main() {
  late InsertParenthesisUseCase useCase;

  setUp(() {
    useCase = InsertParenthesisUseCase();
  });

  group('InsertParenthesisUseCase', () {
    test('should start with leftBracket as true', () {
      expect(useCase.leftBracket, isTrue);
    });

    test('should insert left parenthesis on first call', () {
      final expression = Expression('5+');
      final result = useCase.execute(expression);
      
      expect(result.value, equals('5+('));
    });

    test('should toggle to right parenthesis after first call', () {
      final expression = Expression('5+');
      useCase.execute(expression);
      
      expect(useCase.leftBracket, isFalse);
    });

    test('should insert right parenthesis on second call', () {
      var expression = Expression('5+(');
      useCase.execute(Expression('')); // First call to toggle state
      
      final result = useCase.execute(expression);
      
      expect(result.value, equals('5+()'));
    });

    test('should alternate between left and right parentheses', () {
      var expression = Expression('');
      
      expression = useCase.execute(expression); // '('
      expect(expression.value, equals('('));
      
      expression = useCase.execute(expression); // '()'
      expect(expression.value, equals('()'));
      
      expression = useCase.execute(expression); // '()('
      expect(expression.value, equals('()('));
      
      expression = useCase.execute(expression); // '()()'
      expect(expression.value, equals('()()'));
    });

    test('should reset bracket state to left bracket', () {
      // Toggle to right bracket
      useCase.execute(Expression(''));
      expect(useCase.leftBracket, isFalse);
      
      // Reset
      useCase.resetBracketState();
      
      expect(useCase.leftBracket, isTrue);
    });

    test('should insert left parenthesis after reset', () {
      // Toggle to right bracket
      useCase.execute(Expression(''));
      
      // Reset
      useCase.resetBracketState();
      
      final expression = Expression('5+');
      final result = useCase.execute(expression);
      
      expect(result.value, equals('5+('));
    });

    test('should position cursor after inserted parenthesis', () {
      final expression = Expression('5+', 2);
      final result = useCase.execute(expression);
      
      expect(result.cursorPosition, equals(3));
    });

    test('should insert at cursor position in middle of expression', () {
      final expression = Expression('5+3', 2); // Cursor after '+'
      final result = useCase.execute(expression);
      
      expect(result.value, equals('5+(3'));
      expect(result.cursorPosition, equals(3));
    });
  });

  group('Expression parenthesis handling', () {
    test('should insert left parenthesis correctly', () {
      final expression = Expression('5+');
      final result = expression.insertParenthesis('(');
      
      expect(result.value, equals('5+('));
    });

    test('should insert right parenthesis correctly', () {
      final expression = Expression('5+(3');
      final result = expression.insertParenthesis(')');
      
      expect(result.value, equals('5+(3)'));
    });

    test('should throw ArgumentError for invalid parenthesis', () {
      final expression = Expression('5+');
      
      expect(
        () => expression.insertParenthesis('['),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should handle nested parentheses', () {
      var expression = Expression('');
      
      expression = expression.insertParenthesis('(');
      expression = expression.insertParenthesis('(');
      expression = expression.insertParenthesis(')');
      expression = expression.insertParenthesis(')');
      
      expect(expression.value, equals('(())'));
    });
  });
}
