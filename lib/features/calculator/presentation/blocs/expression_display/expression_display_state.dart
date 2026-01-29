import 'package:flutter/foundation.dart';

import '../../../domain/entities/expression.dart';

/// State for the Expression Display BLoC.
///
/// This state holds the current expression being displayed and
/// any result from evaluation.
@immutable
class ExpressionDisplayState {
  /// The current expression being entered/displayed.
  final Expression expression;

  /// The result of evaluating the expression, if any.
  final String? result;

  /// Whether an error occurred during evaluation.
  final bool hasError;

  /// Error message if [hasError] is true.
  final String? errorMessage;

  const ExpressionDisplayState({
    required this.expression,
    this.result,
    this.hasError = false,
    this.errorMessage,
  });

  /// Creates the initial state with an empty expression.
  factory ExpressionDisplayState.initial() {
    return ExpressionDisplayState(
      expression: Expression.empty(),
    );
  }

  /// Creates a copy of this state with the given fields replaced.
  ExpressionDisplayState copyWith({
    Expression? expression,
    String? result,
    bool? hasError,
    String? errorMessage,
  }) {
    return ExpressionDisplayState(
      expression: expression ?? this.expression,
      result: result ?? this.result,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Returns the display string for the expression.
  String get displayExpression => expression.value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpressionDisplayState &&
        other.expression == expression &&
        other.result == result &&
        other.hasError == hasError &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode =>
      expression.hashCode ^
      result.hashCode ^
      hasError.hashCode ^
      errorMessage.hashCode;

  @override
  String toString() =>
      'ExpressionDisplayState(expression: $expression, result: $result, hasError: $hasError, errorMessage: $errorMessage)';
}
