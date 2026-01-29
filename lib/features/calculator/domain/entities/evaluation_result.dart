/// Represents the different types of evaluation errors.
/// 
/// This enum categorizes evaluation errors for proper handling and
/// user-friendly message mapping.
enum EvaluationErrorType {
  /// Invalid expression format or syntax.
  invalidFormat,
  
  /// Expression parsing error (e.g., malformed tokens).
  parsingError,
  
  /// Invalid argument provided.
  invalidArgument,
  
  /// Division by zero detected.
  divisionByZero,
  
  /// General evaluation error.
  generalError,
  
  /// Validation failure (expression didn't pass pre-validation).
  validationFailure,
}

/// Represents the result of an expression evaluation.
/// 
/// This sealed class provides type-safe handling of evaluation outcomes,
/// allowing consumers to exhaustively handle success, invalid input,
/// and division by zero cases.
sealed class EvaluationResult {
  const EvaluationResult();
  
  /// Returns true if the evaluation was successful.
  bool get isSuccess;
  
  /// Returns the error message if evaluation failed, null otherwise.
  String? get errorMessage;
  
  /// Returns the error type if evaluation failed, null otherwise.
  EvaluationErrorType? get errorType;
}

/// Represents a successful evaluation result.
/// 
/// Contains the computed value as a double, which can be formatted
/// for display purposes.
class EvaluationSuccess extends EvaluationResult {
  /// The computed result value.
  final double value;
  
  const EvaluationSuccess(this.value);
  
  @override
  bool get isSuccess => true;
  
  @override
  String? get errorMessage => null;
  
  @override
  EvaluationErrorType? get errorType => null;
  
  /// Returns the result formatted as a display string.
  /// 
  /// - Whole numbers are displayed without decimal places
  /// - Infinity and NaN are displayed as strings
  String get formattedValue {
    if (value.isInfinite) {
      return value.isNegative ? '-Infinity' : 'Infinity';
    }
    if (value.isNaN) {
      return 'NaN';
    }
    
    // Remove trailing zeros for whole numbers
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EvaluationSuccess && other.value == value;
  }
  
  @override
  int get hashCode => value.hashCode;
  
  @override
  String toString() => 'EvaluationSuccess($value)';
}

/// Represents an invalid input evaluation result.
/// 
/// This indicates that the expression could not be evaluated due to
/// invalid syntax, malformed expressions, or other input errors.
class EvaluationInvalidInput extends EvaluationResult {
  /// The user-friendly error message describing why the input is invalid.
  final String message;
  
  /// The type of evaluation error.
  final EvaluationErrorType type;
  
  /// The original exception message for debugging/logging purposes.
  /// This is preserved for debugging while showing a user-friendly message.
  final String? originalError;
  
  const EvaluationInvalidInput(
    this.message, {
    this.type = EvaluationErrorType.generalError,
    this.originalError,
  });
  
  /// Creates an EvaluationInvalidInput with the standard "Invalid Input" message.
  /// 
  /// This factory constructor provides a consistent user-facing error message
  /// while preserving the original error details for debugging.
  factory EvaluationInvalidInput.invalidInput({
    EvaluationErrorType type = EvaluationErrorType.generalError,
    String? originalError,
  }) {
    return EvaluationInvalidInput(
      'Invalid Input',
      type: type,
      originalError: originalError,
    );
  }
  
  @override
  bool get isSuccess => false;
  
  @override
  String? get errorMessage => message;
  
  @override
  EvaluationErrorType? get errorType => type;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EvaluationInvalidInput && 
           other.message == message &&
           other.type == type;
  }
  
  @override
  int get hashCode => Object.hash(message, type);
  
  @override
  String toString() => 'EvaluationInvalidInput($message, type: $type)';
}

/// Represents a division by zero evaluation result.
/// 
/// This is a special case that may be handled differently from other
/// errors, such as showing a specific toast message or warning.
class EvaluationDivisionByZero extends EvaluationResult {
  /// Whether the result is positive infinity (true) or negative infinity (false).
  /// Null indicates the result is NaN (0/0 case).
  final bool? isPositive;
  
  const EvaluationDivisionByZero({this.isPositive});
  
  @override
  bool get isSuccess => false;
  
  @override
  String? get errorMessage => 'Division by zero';
  
  @override
  EvaluationErrorType? get errorType => EvaluationErrorType.divisionByZero;
  
  /// Returns the display string for the division by zero result.
  String get displayValue {
    if (isPositive == null) {
      return 'NaN';
    }
    return isPositive! ? 'Infinity' : '-Infinity';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EvaluationDivisionByZero && other.isPositive == isPositive;
  }
  
  @override
  int get hashCode => isPositive.hashCode;
  
  @override
  String toString() => 'EvaluationDivisionByZero(isPositive: $isPositive)';
}

/// Maps exceptions from the math_expressions library to user-friendly error messages.
/// 
/// This function converts various exception types to the standardized 'Invalid Input'
/// message for display, while preserving the original exception details for logging/debugging.
class EvaluationErrorMapper {
  /// Maps an exception to an EvaluationInvalidInput result.
  /// 
  /// Takes an [exception] and returns an appropriate EvaluationInvalidInput
  /// with a user-friendly message and the original error preserved.
  static EvaluationInvalidInput mapException(Object exception) {
    if (exception is FormatException) {
      return EvaluationInvalidInput.invalidInput(
        type: EvaluationErrorType.invalidFormat,
        originalError: 'FormatException: ${exception.message}',
      );
    }
    
    if (exception is RangeError) {
      return EvaluationInvalidInput.invalidInput(
        type: EvaluationErrorType.parsingError,
        originalError: 'RangeError: ${exception.message}',
      );
    }
    
    if (exception is ArgumentError) {
      return EvaluationInvalidInput.invalidInput(
        type: EvaluationErrorType.invalidArgument,
        originalError: 'ArgumentError: ${exception.message}',
      );
    }
    
    if (exception is StateError) {
      return EvaluationInvalidInput.invalidInput(
        type: EvaluationErrorType.parsingError,
        originalError: 'StateError: ${exception.message}',
      );
    }
    
    // Default case for unknown exceptions
    return EvaluationInvalidInput.invalidInput(
      type: EvaluationErrorType.generalError,
      originalError: exception.toString(),
    );
  }
}
