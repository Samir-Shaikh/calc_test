/// Enum representing specific types of validation errors.
/// 
/// This allows for more granular error categorization and enables
/// consumers to handle different error types appropriately.
enum ValidationErrorType {
  /// Expression contains consecutive operators like '++', '--', '*/', etc.
  consecutiveOperators,
  
  /// Expression has unmatched parentheses (missing opening or closing).
  unmatchedParenthesis,
  
  /// Expression contains invalid syntax that doesn't fit other categories.
  invalidSyntax,
  
  /// Expression is empty or contains only whitespace.
  emptyExpression,
  
  /// Expression starts with an invalid operator (not unary minus).
  startsWithOperator,
  
  /// Expression ends with an operator.
  endsWithOperator,
  
  /// Expression contains empty parentheses '()'.
  emptyParentheses,
  
  /// Expression has an operator immediately after an opening parenthesis.
  operatorAfterOpenParen,
  
  /// Expression has an operator immediately before a closing parenthesis.
  operatorBeforeCloseParen,
}

/// Represents the result of an expression validation.
/// 
/// This sealed class provides type-safe handling of validation outcomes,
/// allowing consumers to exhaustively handle success and failure cases.
sealed class ValidationResult {
  const ValidationResult();
  
  /// Returns true if the validation was successful.
  bool get isValid;
  
  /// Returns the error message if validation failed, null otherwise.
  String? get errorMessage;
  
  /// Returns the error type if validation failed, null otherwise.
  ValidationErrorType? get errorType;
}

/// Represents a successful validation result.
/// 
/// This indicates that the expression passed all validation checks
/// and is ready for evaluation.
class ValidationSuccess extends ValidationResult {
  const ValidationSuccess();
  
  @override
  bool get isValid => true;
  
  @override
  String? get errorMessage => null;
  
  @override
  ValidationErrorType? get errorType => null;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidationSuccess;
  }
  
  @override
  int get hashCode => runtimeType.hashCode;
  
  @override
  String toString() => 'ValidationSuccess()';
}

/// Represents a failed validation result.
/// 
/// Contains an error message that can be displayed to users
/// explaining why the expression is invalid, and an error type
/// for programmatic handling of specific error categories.
class ValidationFailure extends ValidationResult {
  /// The error message describing why validation failed.
  final String message;
  
  /// The type of validation error that occurred.
  final ValidationErrorType type;
  
  const ValidationFailure(this.message, {this.type = ValidationErrorType.invalidSyntax});
  
  @override
  bool get isValid => false;
  
  @override
  String? get errorMessage => message;
  
  @override
  ValidationErrorType? get errorType => type;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidationFailure && 
           other.message == message && 
           other.type == type;
  }
  
  @override
  int get hashCode => Object.hash(message, type);
  
  @override
  String toString() => 'ValidationFailure($message, type: $type)';
}
