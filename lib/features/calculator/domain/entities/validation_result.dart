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
/// explaining why the expression is invalid.
class ValidationFailure extends ValidationResult {
  /// The error message describing why validation failed.
  final String message;
  
  const ValidationFailure(this.message);
  
  @override
  bool get isValid => false;
  
  @override
  String? get errorMessage => message;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidationFailure && other.message == message;
  }
  
  @override
  int get hashCode => message.hashCode;
  
  @override
  String toString() => 'ValidationFailure($message)';
}
