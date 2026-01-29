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

    group('consecutive operator detection', () {
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

      test('detects *+ as invalid consecutive operators', () {
        final result = useCase.execute('5*+3');
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

      test('detects /+ as invalid consecutive operators', () {
        final result = useCase.execute('6/+3');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

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

      test('detects *- as invalid consecutive operators', () {
        final result = useCase.execute('2*-3');
        expect(result, isA<ValidationFailure>());
        expect((result as ValidationFailure).message, equals('Invalid consecutive operators'));
        expect(result.type, equals(ValidationErrorType.consecutiveOperators));
      });

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

      test('allows ^- for negative exponents (valid case)', () {
        final result = useCase.execute('2^-3');
        expect(result, isA<ValidationSuccess>());
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

    group('invalid operator positioning - starting with operators', () {
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
    });

    group('invalid operator positioning - ending with operators', () {
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
    });

    group('invalid operator after opening parenthesis', () {
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

      test('allows - after opening parenthesis (unary minus)', () {
        final result = useCase.execute('(-5)');
        expect(result, isA<ValidationSuccess>());
      });

      test('allows - after opening parenthesis in complex expression', () {
        final result = useCase.execute('2*(-3+4)');
        expect(result, isA<ValidationSuccess>());
      });
    });

    group('invalid operator before closing parenthesis', () {
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
    });

    group('valid expressions pass validation', () {
      test('validates simple addition', () {
        final result = useCase.execute('2+3');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates simple subtraction', () {
        final result = useCase.execute('10-4');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates simple multiplication', () {
        final result = useCase.execute('3*4');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates simple division', () {
        final result = useCase.execute('10/2');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates simple power', () {
        final result = useCase.execute('2^3');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates complex expression with multiple operators', () {
        final result = useCase.execute('2+3*4');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with parentheses', () {
        final result = useCase.execute('(2+3)*4');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with nested parentheses', () {
        final result = useCase.execute('((2+3)*4)+5');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with negative number at start', () {
        final result = useCase.execute('-5+3');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with negative number in parentheses', () {
        final result = useCase.execute('2*(-3)');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with negative exponent', () {
        final result = useCase.execute('2^-3');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with decimal numbers', () {
        final result = useCase.execute('1.5+2.5');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with display multiplication operator ×', () {
        final result = useCase.execute('3×4');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with display division operator ÷', () {
        final result = useCase.execute('10÷2');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates single number', () {
        final result = useCase.execute('42');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates single negative number', () {
        final result = useCase.execute('-42');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates single decimal number', () {
        final result = useCase.execute('3.14');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates complex expression with all operator types', () {
        final result = useCase.execute('2+3-4*5/2^2');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with multiple parentheses groups', () {
        final result = useCase.execute('(2+3)*(4+5)');
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

      test('validates expression with zero', () {
        final result = useCase.execute('5+0');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with division by zero syntax', () {
        // Syntax is valid, evaluation would handle the division by zero
        final result = useCase.execute('10/0');
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

      test('validates chained power operators', () {
        final result = useCase.execute('2^3^2');
        expect(result, isA<ValidationSuccess>());
      });

      test('validates expression with parenthesized negative base for power', () {
        final result = useCase.execute('(-2)^3');
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

    group('combined error scenarios', () {
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
    });
  });
}
