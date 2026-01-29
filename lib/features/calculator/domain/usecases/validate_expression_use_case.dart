import '../entities/validation_result.dart';

/// Use case for validating mathematical expressions before evaluation.
/// 
/// This use case checks for common expression errors such as:
/// - Empty expressions
/// - Consecutive operators (e.g., '++', '--', '*/', etc.)
/// - Expressions starting with invalid operators
/// - Expressions ending with operators
/// - Unbalanced parentheses
/// - Invalid operator positioning
class ValidateExpressionUseCase {
  /// Regex pattern for detecting invalid consecutive operator combinations.
  /// Matches patterns like: ++, --, +-, -+, */, /*, etc.
  /// Note: Allows ^- for negative exponents (e.g., 2^-1)
  static final RegExp _consecutiveOperatorsPattern = RegExp(
    r'[+\-][+\-]|[+\-*/×÷^]{3,}|[*/×÷][+\-*/×÷^]|[+\-][*/×÷^]|\^[+*/×÷^]'
  );
  
  /// Regex pattern for detecting expression ending with an operator.
  static final RegExp _endsWithOperatorPattern = RegExp(
    r'[+\-*/×÷^]$'
  );
  
  /// Regex pattern for detecting expression starting with invalid operators.
  /// Allows unary minus at the start, but not other operators.
  static final RegExp _startsWithInvalidOperatorPattern = RegExp(
    r'^[+*/×÷^]'
  );
  
  /// Regex pattern for detecting operator immediately after opening parenthesis
  /// (except unary minus).
  static final RegExp _operatorAfterOpenParenPattern = RegExp(
    r'\([+*/×÷^]'
  );
  
  /// Regex pattern for detecting operator immediately before closing parenthesis.
  static final RegExp _operatorBeforeCloseParenPattern = RegExp(
    r'[+\-*/×÷^]\)'
  );
  
  /// Regex pattern for detecting empty parentheses.
  static final RegExp _emptyParenthesesPattern = RegExp(
    r'\(\)'
  );

  /// Executes the expression validation.
  /// 
  /// Takes an [expression] string and validates it against all rules.
  /// Returns [ValidationSuccess] if valid, or [ValidationFailure] with
  /// a descriptive error message if invalid.
  ValidationResult execute(String expression) {
    // Trim whitespace for validation
    final trimmed = expression.trim();
    
    // Check for empty expression
    if (trimmed.isEmpty) {
      return const ValidationFailure('Expression cannot be empty');
    }
    
    // Check for expression starting with invalid operators
    if (_startsWithInvalidOperator(trimmed)) {
      return const ValidationFailure('Expression cannot start with an operator');
    }
    
    // Check for expression ending with an operator
    if (_endsWithOperator(trimmed)) {
      return const ValidationFailure('Expression cannot end with an operator');
    }
    
    // Check for consecutive operators
    if (_hasConsecutiveOperators(trimmed)) {
      return const ValidationFailure('Invalid consecutive operators');
    }
    
    // Check for unbalanced parentheses
    final parenthesesResult = _validateParentheses(trimmed);
    if (parenthesesResult != null) {
      return ValidationFailure(parenthesesResult);
    }
    
    // Check for empty parentheses
    if (_hasEmptyParentheses(trimmed)) {
      return const ValidationFailure('Empty parentheses are not allowed');
    }
    
    // Check for operator after opening parenthesis (except unary minus)
    if (_hasOperatorAfterOpenParen(trimmed)) {
      return const ValidationFailure('Invalid operator after opening parenthesis');
    }
    
    // Check for operator before closing parenthesis
    if (_hasOperatorBeforeCloseParen(trimmed)) {
      return const ValidationFailure('Invalid operator before closing parenthesis');
    }
    
    // All validations passed
    return const ValidationSuccess();
  }
  
  /// Checks if the expression starts with an invalid operator.
  /// Unary minus is allowed at the start.
  bool _startsWithInvalidOperator(String expression) {
    return _startsWithInvalidOperatorPattern.hasMatch(expression);
  }
  
  /// Checks if the expression ends with an operator.
  bool _endsWithOperator(String expression) {
    return _endsWithOperatorPattern.hasMatch(expression);
  }
  
  /// Checks for invalid consecutive operator combinations.
  bool _hasConsecutiveOperators(String expression) {
    return _consecutiveOperatorsPattern.hasMatch(expression);
  }
  
  /// Validates parentheses balance and returns an error message if invalid.
  /// Returns null if parentheses are valid.
  String? _validateParentheses(String expression) {
    int openCount = 0;
    
    for (int i = 0; i < expression.length; i++) {
      final char = expression[i];
      
      if (char == '(') {
        openCount++;
      } else if (char == ')') {
        openCount--;
        
        // More closing than opening at this point
        if (openCount < 0) {
          return 'Unmatched closing parenthesis';
        }
      }
    }
    
    if (openCount > 0) {
      return 'Unmatched opening parenthesis';
    }
    
    return null;
  }
  
  /// Checks for empty parentheses in the expression.
  bool _hasEmptyParentheses(String expression) {
    return _emptyParenthesesPattern.hasMatch(expression);
  }
  
  /// Checks for operator immediately after opening parenthesis
  /// (except unary minus which is allowed).
  bool _hasOperatorAfterOpenParen(String expression) {
    return _operatorAfterOpenParenPattern.hasMatch(expression);
  }
  
  /// Checks for operator immediately before closing parenthesis.
  bool _hasOperatorBeforeCloseParen(String expression) {
    return _operatorBeforeCloseParenPattern.hasMatch(expression);
  }
}
