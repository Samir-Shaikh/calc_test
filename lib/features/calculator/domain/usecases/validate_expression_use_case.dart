import '../entities/validation_result.dart';

/// Validates mathematical expressions before evaluation.
///
/// Checks: empty expression, start/end with operator, consecutive operators,
/// unbalanced or empty parentheses, operator after '(' or before ')'.
class ValidateExpressionUseCase {
  static final RegExp _consecutiveOperatorsPattern = RegExp(
    r'(\+\+|--|'
    r'\+\-|\-\+|'
    r'\*\/|\/\*|'
    r'\*\+|\/\+|'
    r'\+\*|\+\/|'
    r'\-\*|\-\/|'
    r'\*\-|\/\-|'
    r'\*\*|\/\/|'
    r'×\/|\/×|'
    r'×\+|÷\+|'
    r'\+×|\+÷|'
    r'\-×|\-÷|'
    r'×\-|÷\-|'
    r'××|÷÷|'
    r'×÷|÷×|'
    r'\^[+*/×÷^]|'
    r'[+\-*/×÷]\^(?!\-)|'
    r'[+\-*/×÷^]{3,})',
  );
  static final RegExp _endsWithOperatorPattern = RegExp(r'[+\-*/×÷^]$');
  static final RegExp _startsWithInvalidOperatorPattern = RegExp(r'^[+*/×÷^]');
  static final RegExp _operatorAfterOpenParenPattern = RegExp(r'\([+*/×÷^]');
  static final RegExp _operatorBeforeCloseParenPattern = RegExp(r'[+\-*/×÷^]\)');
  static final RegExp _emptyParenthesesPattern = RegExp(r'\(\)');

  static final List<({RegExp pattern, String message, ValidationErrorType type})> _rules = [
    (pattern: _startsWithInvalidOperatorPattern, message: 'Expression cannot start with an operator', type: ValidationErrorType.startsWithOperator),
    (pattern: _endsWithOperatorPattern, message: 'Expression cannot end with an operator', type: ValidationErrorType.endsWithOperator),
    (pattern: _consecutiveOperatorsPattern, message: 'Invalid consecutive operators', type: ValidationErrorType.consecutiveOperators),
    (pattern: _emptyParenthesesPattern, message: 'Empty parentheses are not allowed', type: ValidationErrorType.emptyParentheses),
    (pattern: _operatorAfterOpenParenPattern, message: 'Invalid operator after opening parenthesis', type: ValidationErrorType.operatorAfterOpenParen),
    (pattern: _operatorBeforeCloseParenPattern, message: 'Invalid operator before closing parenthesis', type: ValidationErrorType.operatorBeforeCloseParen),
  ];

  /// Returns [ValidationSuccess] if valid, [ValidationFailure] with message and type otherwise.
  ValidationResult execute(String expression) {
    final trimmed = expression.trim();
    if (trimmed.isEmpty) {
      return const ValidationFailure(
        'Expression cannot be empty',
        type: ValidationErrorType.emptyExpression,
      );
    }
    for (final rule in _rules) {
      if (rule.pattern.hasMatch(trimmed)) {
        return ValidationFailure(rule.message, type: rule.type);
      }
    }
    final parenthesesError = _validateParentheses(trimmed);
    if (parenthesesError != null) {
      return ValidationFailure(parenthesesError, type: ValidationErrorType.unmatchedParenthesis);
    }
    return const ValidationSuccess();
  }

  /// Returns error message if parentheses are unbalanced, null if valid.
  String? _validateParentheses(String expression) {
    int openCount = 0;
    for (int i = 0; i < expression.length; i++) {
      final char = expression[i];
      if (char == '(') {
        openCount++;
      } else if (char == ')') {
        openCount--;
        if (openCount < 0) return 'Unmatched closing parenthesis';
      }
    }
    return openCount > 0 ? 'Unmatched opening parenthesis' : null;
  }
}