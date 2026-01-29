import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/validate_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/entities/validation_result.dart';

void main() {
  late ValidateExpressionUseCase useCase;

  setUp(() {
    useCase = ValidateExpressionUseCase();
  });

  group('ValidateExpressionUseCase', () {
    group('ValidationResult sealed class', () {
      test('ValidationSuccess has correct properties', () {
        const success = ValidationSuccess();
        expect(success.isValid, isTrue);
        expect(success.errorMessage, isNull);
        expect(success.errorType, isNull);
      });

      test('ValidationFailure has correct properties', () {
        const failure = ValidationFailure('Test error');
        expect(failure.isValid, isFalse);
        expect(failure.errorMessage, equals('Test error'));
        expect(failure.message, equals('Test error'));
        expect(failure.type, equals(ValidationErrorType.invalidSyntax));
        expect(failure.errorType, equals(ValidationErrorType.invalidSyntax));
      });

      test('ValidationFailure with custom error type has correct properties', () {
        const failure = ValidationFailure(
          'Consecutive operators',
          type: ValidationErrorType.consecutiveOperators,
        );
        expect(failure.isValid, isFalse);
        expect(failure.errorMessage, equals('Consecutive operators'));
        expect(failure.type, equals(ValidationErrorType.consecutiveOperators));
        expect(failure.errorType, equals(ValidationErrorType.consecutiveOperators));
      });

      test('ValidationSuccess equality works correctly', () {
        const success1 = ValidationSuccess();
        const success2 = ValidationSuccess();
        expect(success1, equals(success2));
      });

      test('ValidationFailure equality works correctly', () {
        const failure1 = ValidationFailure('error');
        const failure2 = ValidationFailure('error');
        const failure3 = ValidationFailure('other');

        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });

      test('ValidationFailure equality considers error type', () {
        const failure1 = ValidationFailure(
          'error',
          type: ValidationErrorType.consecutiveOperators,
        );
        const failure2 = ValidationFailure(
          'error',
          type: ValidationErrorType.consecutiveOperators,
        );
        const failure3 = ValidationFailure(
          'error',
          type: ValidationErrorType.invalidSyntax,
        );

        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });

      test('ValidationSuccess toString returns correct format', () {
        const success = ValidationSuccess();
        expect(success.toString(), equals('ValidationSuccess()'));
      });

      test('ValidationFailure toString returns correct format', () {
        const failure = ValidationFailure('Test error');
        expect(
          failure.toString(),
          equals('ValidationFailure(Test error, type: ValidationErrorType.invalidSyntax)'),
        );
      });

      test('ValidationFailure toString includes custom error type', () {
        const failure = ValidationFailure(
          'Consecutive operators',
          type: ValidationErrorType.consecutiveOperators,
        );
        expect(
          failure.toString(),
          equals('ValidationFailure(Consecutive operators, type: ValidationErrorType.consecutiveOperators)'),
        );
      });
    });

    group('ValidationErrorType enum', () {
      test('has all expected error types', () {
        expect(ValidationErrorType.values, contains(ValidationErrorType.consecutiveOperators));
        expect(ValidationErrorType.values, contains(ValidationErrorType.unmatchedParenthesis));
        expect(ValidationErrorType.values, contains(ValidationErrorType.invalidSyntax));
        expect(ValidationErrorType.values, contains(ValidationErrorType.emptyExpression));
        expect(ValidationErrorType.values, contains(ValidationErrorType.startsWithOperator));
        expect(ValidationErrorType.values, contains(ValidationErrorType.endsWithOperator));
        expect(ValidationErrorType.values, contains(ValidationErrorType.emptyParentheses));
        expect(ValidationErrorType.values, contains(ValidationErrorType.operatorAfterOpenParen));
        expect(ValidationErrorType.values, contains(ValidationErrorType.operatorBeforeCloseParen));
      });
    });

    group('empty expression validation', () {
      test('returns failure for empty string', () {
        final result = useCase.execute('');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot be empty'));
        expect(result.type, equals(ValidationErrorType.emptyExpression));
      });

      test('returns failure for whitespace-only string', () {
        final result = useCase.execute('   ');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot be empty'));
        expect(result.type, equals(ValidationErrorType.emptyExpression));
      });

      test('returns failure for tab-only string', () {
        final result = useCase.execute('\t\t');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot be empty'));
        expect(result.type, equals(ValidationErrorType.emptyExpression));
      });

      test('returns failure for mixed whitespace string', () {
        final result = useCase.execute(' \t \n ');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot be empty'));
        expect(result.type, equals(ValidationErrorType.emptyExpression));
      });
    });

    group('consecutive operator detection - AC1 and AC2 patterns', () {
      // AC1: Test '2++3' pattern
      test('detects ++ as invalid consecutive operators (AC1 pattern: 2++3)', () {
        final result = useCase.execute('2++3');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      // AC2: Test '2*/3' pattern
      test('detects */ as invalid consecutive operators (AC2 pattern: 2*/3)', () {
        final result = useCase.execute('2*/3');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });
    });

    group('consecutive operator detection - all permutations', () {
      // Same operator repeated
      test('detects ++ as invalid consecutive operators', () {
        final result = useCase.execute('2++3');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      test('detects -- as invalid consecutive operators', () {
        final result = useCase.execute('5--2');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      test('detects ** as invalid consecutive operators', () {
        final result = useCase.execute('3**4');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      test('detects // as invalid consecutive operators', () {
        final result = useCase.execute('8//2');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      // Plus and minus combinations
      test('detects +- as invalid consecutive operators', () {
        final result = useCase.execute('8+-9');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      test('detects -+ as invalid consecutive operators', () {
        final result = useCase.execute('4-+2');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      // Multiply and divide combinations
      test('detects */ as invalid consecutive operators', () {
        final result = useCase.execute('3*/4');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      test('detects /* as invalid consecutive operators', () {
        final result = useCase.execute('6/*2');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      // Multiply with plus/minus
      test('detects *+ as invalid consecutive operators', () {
        final result = useCase.execute('5*+3');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      test('detects *- as invalid consecutive operators', () {
        final result = useCase.execute('2*-3');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      // Divide with plus/minus
      test('detects /+ as invalid consecutive operators', () {
        final result = useCase.execute('6/+3');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      test('detects /- as invalid consecutive operators', () {
        final result = useCase.execute('10/-2');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      // Plus with multiply/divide
      test('detects +* as invalid consecutive operators', () {
        final result = useCase.execute('2+*3');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      test('detects +/ as invalid consecutive operators', () {
        final result = useCase.execute('2+/3');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      // Minus with multiply/divide
      test('detects -* as invalid consecutive operators', () {
        final result = useCase.execute('2-*3');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      test('detects -/ as invalid consecutive operators', () {
        final result = useCase.execute('2-/3');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      // Unicode operator combinations
      test('detects ×× as invalid consecutive operators', () {
        final result = useCase.execute('3××4');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      test('detects ÷÷ as invalid consecutive operators', () {
        final result = useCase.execute('8÷÷2');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      // Power operator combinations
      test('detects ^+ as invalid consecutive operators', () {
        final result = useCase.execute('2^+3');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      test('detects ^* as invalid consecutive operators', () {
        final result = useCase.execute('2^*3');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      test('detects ^^ as invalid consecutive operators', () {
        final result = useCase.execute('2^^3');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      test('detects ^/ as invalid consecutive operators', () {
        final result = useCase.execute('2^/3');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      // Three or more consecutive operators
      test('detects three consecutive operators as invalid', () {
        final result = useCase.execute('2+-*3');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      test('detects four consecutive operators as invalid', () {
        final result = useCase.execute('5+--*2');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      // Special case: ^- is allowed for negative exponents
      test('allows ^- for negative exponents (valid case)', () {
        final result = useCase.execute('2^-3');
        expect(result, isA<ValidationSuccess>());
      });
    });

    group('boundary conditions - expression ending with operators', () {
      test('detects expression ending with +', () {
        final result = useCase.execute('5+');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot end with an operator'));
        expect(result.type, equals(ValidationErrorType.endsWithOperator));
      });

      test('detects expression ending with -', () {
        final result = useCase.execute('5-');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot end with an operator'));
        expect(result.type, equals(ValidationErrorType.endsWithOperator));
      });

      test('detects expression ending with *', () {
        final result = useCase.execute('5*');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot end with an operator'));
        expect(result.type, equals(ValidationErrorType.endsWithOperator));
      });

      test('detects expression ending with /', () {
        final result = useCase.execute('5/');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot end with an operator'));
        expect(result.type, equals(ValidationErrorType.endsWithOperator));
      });

      test('detects expression ending with ×', () {
        final result = useCase.execute('5×');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot end with an operator'));
        expect(result.type, equals(ValidationErrorType.endsWithOperator));
      });

      test('detects expression ending with ÷', () {
        final result = useCase.execute('5÷');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot end with an operator'));
        expect(result.type, equals(ValidationErrorType.endsWithOperator));
      });

      test('detects expression ending with ^', () {
        final result = useCase.execute('5^');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot end with an operator'));
        expect(result.type, equals(ValidationErrorType.endsWithOperator));
      });

      test('detects complex expression ending with operator', () {
        final result = useCase.execute('2+3*4-');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot end with an operator'));
        expect(result.type, equals(ValidationErrorType.endsWithOperator));
      });

      test('detects parenthesized expression followed by trailing operator', () {
        final result = useCase.execute('(2+3)+');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot end with an operator'));
        expect(result.type, equals(ValidationErrorType.endsWithOperator));
      });
    });

    group('boundary conditions - expression starting with invalid operators', () {
      test('detects expression starting with +', () {
        final result = useCase.execute('+5');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot start with an operator'));
        expect(result.type, equals(ValidationErrorType.startsWithOperator));
      });

      test('detects expression starting with *', () {
        final result = useCase.execute('*5');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot start with an operator'));
        expect(result.type, equals(ValidationErrorType.startsWithOperator));
      });

      test('detects expression starting with /', () {
        final result = useCase.execute('/5');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot start with an operator'));
        expect(result.type, equals(ValidationErrorType.startsWithOperator));
      });

      test('detects expression starting with ×', () {
        final result = useCase.execute('×5');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot start with an operator'));
        expect(result.type, equals(ValidationErrorType.startsWithOperator));
      });

      test('detects expression starting with ÷', () {
        final result = useCase.execute('÷5');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot start with an operator'));
        expect(result.type, equals(ValidationErrorType.startsWithOperator));
      });

      test('detects expression starting with ^', () {
        final result = useCase.execute('^5');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot start with an operator'));
        expect(result.type, equals(ValidationErrorType.startsWithOperator));
      });

      test('allows expression starting with - (unary minus)', () {
        final result = useCase.execute('-5');
        expect(result, isA<ValidationSuccess>());
      });

      test('allows expression starting with - followed by number and operator', () {
        final result = useCase.execute('-5+3');
        expect(result, isA<ValidationSuccess>());
      });

      test('allows expression starting with - followed by parenthesis', () {
        final result = useCase.execute('-(5+3)');
        expect(result, isA<ValidationSuccess>());
      });
    });

    group('boundary conditions - operators at parenthesis boundaries', () {
      // Invalid operator after opening parenthesis (except unary minus)
      test('detects + after opening parenthesis', () {
        final result = useCase.execute('(+5)');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid operator after opening parenthesis'));
        expect(result.type, equals(ValidationErrorType.operatorAfterOpenParen));
      });

      test('detects * after opening parenthesis', () {
        final result = useCase.execute('(*5)');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid operator after opening parenthesis'));
        expect(result.type, equals(ValidationErrorType.operatorAfterOpenParen));
      });

      test('detects / after opening parenthesis', () {
        final result = useCase.execute('(/5)');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid operator after opening parenthesis'));
        expect(result.type, equals(ValidationErrorType.operatorAfterOpenParen));
      });

      test('detects × after opening parenthesis', () {
        final result = useCase.execute('(×5)');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid operator after opening parenthesis'));
        expect(result.type, equals(ValidationErrorType.operatorAfterOpenParen));
      });

      test('detects ÷ after opening parenthesis', () {
        final result = useCase.execute('(÷5)');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid operator after opening parenthesis'));
        expect(result.type, equals(ValidationErrorType.operatorAfterOpenParen));
      });

      test('detects ^ after opening parenthesis', () {
        final result = useCase.execute('(^5)');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid operator after opening parenthesis'));
        expect(result.type, equals(ValidationErrorType.operatorAfterOpenParen));
      });

      // Allows - after opening parenthesis (unary minus)
      test('allows - after opening parenthesis (unary minus)', () {
        final result = useCase.execute('(-5)');
        expect(result, isA<ValidationSuccess>());
      });

      test('allows - after opening parenthesis in complex expression', () {
        final result = useCase.execute('2*(-3+4)');
        expect(result, isA<ValidationSuccess>());
      });

      // Invalid operator before closing parenthesis
      test('detects + before closing parenthesis', () {
        final result = useCase.execute('(5+)');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid operator before closing parenthesis'));
        expect(result.type, equals(ValidationErrorType.operatorBeforeCloseParen));
      });

      test('detects - before closing parenthesis', () {
        final result = useCase.execute('(5-)');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid operator before closing parenthesis'));
        expect(result.type, equals(ValidationErrorType.operatorBeforeCloseParen));
      });

      test('detects * before closing parenthesis', () {
        final result = useCase.execute('(5*)');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid operator before closing parenthesis'));
        expect(result.type, equals(ValidationErrorType.operatorBeforeCloseParen));
      });

      test('detects / before closing parenthesis', () {
        final result = useCase.execute('(5/)');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid operator before closing parenthesis'));
        expect(result.type, equals(ValidationErrorType.operatorBeforeCloseParen));
      });

      test('detects × before closing parenthesis', () {
        final result = useCase.execute('(5×)');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid operator before closing parenthesis'));
        expect(result.type, equals(ValidationErrorType.operatorBeforeCloseParen));
      });

      test('detects ÷ before closing parenthesis', () {
        final result = useCase.execute('(5÷)');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid operator before closing parenthesis'));
        expect(result.type, equals(ValidationErrorType.operatorBeforeCloseParen));
      });

      test('detects ^ before closing parenthesis', () {
        final result = useCase.execute('(5^)');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid operator before closing parenthesis'));
        expect(result.type, equals(ValidationErrorType.operatorBeforeCloseParen));
      });

      // Nested parentheses with invalid operators
      test('detects operator before closing in nested parentheses', () {
        final result = useCase.execute('((5+3)-)');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid operator before closing parenthesis'));
        expect(result.type, equals(ValidationErrorType.operatorBeforeCloseParen));
      });

      test('detects operator after opening in nested parentheses', () {
        final result = useCase.execute('((*5)+3)');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid operator after opening parenthesis'));
        expect(result.type, equals(ValidationErrorType.operatorAfterOpenParen));
      });
    });

    group('unbalanced parentheses detection', () {
      test('detects missing closing parenthesis', () {
        final result = useCase.execute('(2+3');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Unmatched opening parenthesis'));
        expect(result.type, equals(ValidationErrorType.unmatchedParenthesis));
      });

      test('detects missing opening parenthesis', () {
        final result = useCase.execute('2+3)');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Unmatched closing parenthesis'));
        expect(result.type, equals(ValidationErrorType.unmatchedParenthesis));
      });

      test('detects extra opening parenthesis in nested expression', () {
        final result = useCase.execute('((2+3)');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Unmatched opening parenthesis'));
        expect(result.type, equals(ValidationErrorType.unmatchedParenthesis));
      });

      test('detects extra closing parenthesis in nested expression', () {
        final result = useCase.execute('(2+3))');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Unmatched closing parenthesis'));
        expect(result.type, equals(ValidationErrorType.unmatchedParenthesis));
      });

      test('detects multiple unmatched opening parentheses', () {
        final result = useCase.execute('(((2+3)');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Unmatched opening parenthesis'));
        expect(result.type, equals(ValidationErrorType.unmatchedParenthesis));
      });

      test('detects multiple unmatched closing parentheses', () {
        final result = useCase.execute('(2+3)))');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Unmatched closing parenthesis'));
        expect(result.type, equals(ValidationErrorType.unmatchedParenthesis));
      });

      test('detects closing before opening parenthesis', () {
        final result = useCase.execute(')(2+3)(');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Unmatched closing parenthesis'));
        expect(result.type, equals(ValidationErrorType.unmatchedParenthesis));
      });

      test('detects reversed parentheses order', () {
        final result = useCase.execute(')2+3(');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Unmatched closing parenthesis'));
        expect(result.type, equals(ValidationErrorType.unmatchedParenthesis));
      });

      test('detects unbalanced in complex expression', () {
        final result = useCase.execute('((2+3)*4+5');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Unmatched opening parenthesis'));
        expect(result.type, equals(ValidationErrorType.unmatchedParenthesis));
      });

      test('validates balanced parentheses as valid', () {
        final result = useCase.execute('(2+3)');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates nested balanced parentheses as valid', () {
        final result = useCase.execute('((2+3)*4)');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates multiple separate balanced parentheses as valid', () {
        final result = useCase.execute('(2+3)*(4+5)');
        expect(result, isA<ValidationSuccess>());
      });
    });

    group('empty parentheses detection', () {
      test('detects empty parentheses', () {
        final result = useCase.execute('()');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Empty parentheses are not allowed'));
        expect(result.type, equals(ValidationErrorType.emptyParentheses));
      });

      test('detects empty parentheses in expression', () {
        final result = useCase.execute('5+()');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Empty parentheses are not allowed'));
        expect(result.type, equals(ValidationErrorType.emptyParentheses));
      });

      test('detects empty parentheses at start of expression', () {
        final result = useCase.execute('()+5');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Empty parentheses are not allowed'));
        expect(result.type, equals(ValidationErrorType.emptyParentheses));
      });

      test('detects empty parentheses in middle of expression', () {
        final result = useCase.execute('2+()*3');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Empty parentheses are not allowed'));
        expect(result.type, equals(ValidationErrorType.emptyParentheses));
      });

      test('detects multiple empty parentheses', () {
        final result = useCase.execute('()()+()');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Empty parentheses are not allowed'));
        expect(result.type, equals(ValidationErrorType.emptyParentheses));
      });
    });

    group('valid expressions - not falsely rejected', () {
      // Basic arithmetic operations
      test('validates simple addition: 2+3', () {
        final result = useCase.execute('2+3');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates simple subtraction: 10-4', () {
        final result = useCase.execute('10-4');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates simple multiplication: 3*4', () {
        final result = useCase.execute('3*4');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates simple division: 10/2', () {
        final result = useCase.execute('10/2');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates simple power: 2^3', () {
        final result = useCase.execute('2^3');
        expect(result, isA<ValidationSuccess>());
      });

      // Expressions with parentheses
      test('validates expression with parentheses: (2+3)*4', () {
        final result = useCase.execute('(2+3)*4');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with nested parentheses: ((2+3)*4)+5', () {
        final result = useCase.execute('((2+3)*4)+5');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates multiple parentheses groups: (2+3)*(4+5)', () {
        final result = useCase.execute('(2+3)*(4+5)');
        expect(result, isA<ValidationSuccess>());
      });

      // Negative numbers
      test('validates expression starting with negative number: -5+3', () {
        final result = useCase.execute('-5+3');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates single negative number: -42', () {
        final result = useCase.execute('-42');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates negative number in parentheses: 2*(-3)', () {
        final result = useCase.execute('2*(-3)');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates negative operand in parentheses for multiplication: 5*(-3)', () {
        final result = useCase.execute('5*(-3)');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates negative operand in parentheses for division: 10/(-2)', () {
        final result = useCase.execute('10/(-2)');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates negative operand in parentheses for addition: 5+(-3)', () {
        final result = useCase.execute('5+(-3)');
        expect(result, isA<ValidationSuccess>());
      });

      // Negative exponents (special case - allowed without parentheses)
      test('validates negative exponent: 2^-3', () {
        final result = useCase.execute('2^-3');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates negative exponent in complex expression: 10^-2+5', () {
        final result = useCase.execute('10^-2+5');
        expect(result, isA<ValidationSuccess>());
      });

      // Decimal numbers
      test('validates expression with decimal numbers: 1.5+2.5', () {
        final result = useCase.execute('1.5+2.5');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates single decimal number: 3.14', () {
        final result = useCase.execute('3.14');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates negative decimal: -3.14', () {
        final result = useCase.execute('-3.14');
        expect(result, isA<ValidationSuccess>());
      });

      // Unicode operators
      test('validates expression with display multiplication operator ×: 3×4', () {
        final result = useCase.execute('3×4');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with display division operator ÷: 10÷2', () {
        final result = useCase.execute('10÷2');
        expect(result, isA<ValidationSuccess>());
      });

      // Single numbers
      test('validates single number: 42', () {
        final result = useCase.execute('42');
        expect(result, isA<ValidationSuccess>());
      });

      // Complex expressions
      test('validates complex expression with multiple operators', () {
        final result = useCase.execute('2+3*4');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates complex expression with all operator types', () {
        final result = useCase.execute('2+3-4*5/2^2');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates deeply nested parentheses', () {
        final result = useCase.execute('(((2+3)))');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with parentheses and power', () {
        final result = useCase.execute('(2+1)^2');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with zero: 5+0', () {
        final result = useCase.execute('5+0');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with division by zero syntax', () {
        // Syntax is valid, evaluation would handle the division by zero
        final result = useCase.execute('10/0');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates parenthesized negative base for power: (-2)^3', () {
        final result = useCase.execute('(-2)^3');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates chained power operators: 2^3^2', () {
        final result = useCase.execute('2^3^2');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression ending with closing parenthesis', () {
        final result = useCase.execute('2*(3+4)');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression starting with opening parenthesis', () {
        final result = useCase.execute('(2+3)*4');
        expect(result, isA<ValidationSuccess>());
      });
    });

    group('edge cases', () {
      test('validates expression with leading zeros', () {
        final result = useCase.execute('007+3');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with trailing zeros in decimal', () {
        final result = useCase.execute('3.140+2');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with spaces (trimmed)', () {
        final result = useCase.execute('  2+3  ');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates very long expression', () {
        final result = useCase.execute('1+2+3+4+5+6+7+8+9+10');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with large numbers', () {
        final result = useCase.execute('999999999+1');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with very small decimal', () {
        final result = useCase.execute('0.000001+1');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates single digit: 5', () {
        final result = useCase.execute('5');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates zero: 0', () {
        final result = useCase.execute('0');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates negative zero: -0', () {
        final result = useCase.execute('-0');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with mixed unicode and ASCII operators', () {
        final result = useCase.execute('2+3×4÷2');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates complex nested expression with negative numbers', () {
        final result = useCase.execute('(-2+3)*(-4+5)');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with parentheses around single number', () {
        final result = useCase.execute('(5)');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with parentheses around negative number', () {
        final result = useCase.execute('(-5)');
        expect(result, isA<ValidationSuccess>());
      });
    });

    group('combined error scenarios - error priority', () {
      test('detects first error when multiple errors exist - starts with operator', () {
        // Expression starts with * and has other issues
        final result = useCase.execute('*2++3');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot start with an operator'));
        expect(result.type, equals(ValidationErrorType.startsWithOperator));
      });

      test('detects first error when multiple errors exist - ends with operator', () {
        // Expression ends with operator and has unbalanced parentheses
        final result = useCase.execute('(2+3+');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot end with an operator'));
        expect(result.type, equals(ValidationErrorType.endsWithOperator));
      });

      test('detects consecutive operators before parenthesis check', () {
        // Has both consecutive operators and unbalanced parentheses
        final result = useCase.execute('2++3(');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

      test('only operators returns appropriate error', () {
        final result = useCase.execute('+-*/');
        expect(result, isA<ValidationFailure>());
        // Starts with + which is invalid start operator
        expect((result as ValidationFailure).message, equals('Expression cannot start with an operator'));
        expect(result.type, equals(ValidationErrorType.startsWithOperator));
      });

      test('empty expression takes priority over all other errors', () {
        final result = useCase.execute('');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot be empty'));
        expect(result.type, equals(ValidationErrorType.emptyExpression));
      });

      test('starts with operator checked before ends with operator', () {
        final result = useCase.execute('+-');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot start with an operator'));
        expect(result.type, equals(ValidationErrorType.startsWithOperator));
      });

      test('ends with operator checked before consecutive operators for -+ pattern', () {
        // This should detect ends with + before the consecutive operators
        final result = useCase.execute('5-+');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Expression cannot end with an operator'));
        expect(result.type, equals(ValidationErrorType.endsWithOperator));
      });
    });

    group('parameterized consecutive operator tests', () {
      // Test all combinations programmatically
      final invalidCombinations = [
        ('++', '5++3', 'double plus'),
        ('--', '5--3', 'double minus'),
        ('**', '5**3', 'double multiply'),
        ('//', '5//3', 'double divide'),
        ('+-', '5+-3', 'plus minus'),
        ('-+', '5-+3', 'minus plus'),
        ('*/', '5*/3', 'multiply divide'),
        ('/*', '5/*3', 'divide multiply'),
        ('*+', '5*+3', 'multiply plus'),
        ('/+', '5/+3', 'divide plus'),
        ('+*', '5+*3', 'plus multiply'),
        ('+/', '5+/3', 'plus divide'),
        ('-*', '5-*3', 'minus multiply'),
        ('-/', '5-/3', 'minus divide'),
        ('*-', '5*-3', 'multiply minus'),
        ('/-', '5/-3', 'divide minus'),
      ];

      for (final (operators, expression, description) in invalidCombinations) {
        test('detects $description ($operators) as invalid in $expression', () {
          final result = useCase.execute(expression);
          expect(result, isA<ValidationFailure>());
          expect((result as ValidationFailure).type, equals(ValidationErrorType.consecutiveOperators));
        });
      }
    });

    group('parameterized boundary operator tests', () {
      // Test all operators at start
      final startOperators = ['+', '*', '/', '×', '÷', '^'];
      for (final op in startOperators) {
        test('rejects expression starting with $op', () {
          final result = useCase.execute('${op}5');
          expect(result, isA<ValidationFailure>());
          expect((result as ValidationFailure).type, equals(ValidationErrorType.startsWithOperator));
        });
      }

      // Test all operators at end
      final endOperators = ['+', '-', '*', '/', '×', '÷', '^'];
      for (final op in endOperators) {
        test('rejects expression ending with $op', () {
          final result = useCase.execute('5$op');
          expect(result, isA<ValidationFailure>());
          expect((result as ValidationFailure).type, equals(ValidationErrorType.endsWithOperator));
        });
      }

      // Test all operators after open paren (except -)
      final afterOpenParenOperators = ['+', '*', '/', '×', '÷', '^'];
      for (final op in afterOpenParenOperators) {
        test('rejects $op after opening parenthesis', () {
          final result = useCase.execute('(${op}5)');
          expect(result, isA<ValidationFailure>());
          expect((result as ValidationFailure).type, equals(ValidationErrorType.operatorAfterOpenParen));
        });
      }

      // Test all operators before close paren
      final beforeCloseParenOperators = ['+', '-', '*', '/', '×', '÷', '^'];
      for (final op in beforeCloseParenOperators) {
        test('rejects $op before closing parenthesis', () {
          final result = useCase.execute('(5$op)');
          expect(result, isA<ValidationFailure>());
          expect((result as ValidationFailure).type, equals(ValidationErrorType.operatorBeforeCloseParen));
        });
      }
    });
  });
}
