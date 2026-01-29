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

  /// Whether this is an evaluation error that should trigger a toast notification.
  /// 
  /// This is distinct from [hasError] because some errors (like division by zero)
  /// may be displayed in the result area rather than as toast notifications.
  /// Set to true when the expression evaluation fails due to invalid input.
  final bool isEvaluationError;

  /// The evaluation error message to display in a toast notification.
  /// 
  /// This is set when [isEvaluationError] is true and contains a user-friendly
  /// message explaining why the evaluation failed.
  final String? evaluationError;

  /// Whether to show an error toast notification.
  /// 
  /// This flag is set to true when an evaluation error occurs and should
  /// trigger a toast display. Once the toast is displayed, the UI should
  /// dispatch an [ErrorAcknowledged] event to reset this flag to false,
  /// preventing repeated toast displays on subsequent state emissions.
  final bool showError;

  const ExpressionDisplayState({
    required this.expression,
    this.result,
    this.hasError = false,
    this.errorMessage,
    this.isEvaluationError = false,
    this.evaluationError,
    this.showError = false,
  });

  /// Creates the initial state with an empty expression.
  factory ExpressionDisplayState.initial() {
    return ExpressionDisplayState(
      expression: Expression.empty(),
    );
  }

  /// Creates a copy of this state with the given fields replaced.
  /// 
  /// Note: To explicitly set nullable fields to null, use the `clearX` parameters:
  /// - [clearResult]: Set to true to clear the result
  /// - [clearErrorMessage]: Set to true to clear the error message
  /// - [clearEvaluationError]: Set to true to clear the evaluation error
  ExpressionDisplayState copyWith({
    Expression? expression,
    String? result,
    bool? hasError,
    String? errorMessage,
    bool? isEvaluationError,
    String? evaluationError,
    bool? showError,
    bool clearResult = false,
    bool clearErrorMessage = false,
    bool clearEvaluationError = false,
  }) {
    return ExpressionDisplayState(
      expression: expression ?? this.expression,
      result: clearResult ? null : (result ?? this.result),
      hasError: hasError ?? this.hasError,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isEvaluationError: isEvaluationError ?? this.isEvaluationError,
      evaluationError: clearEvaluationError ? null : (evaluationError ?? this.evaluationError),
      showError: showError ?? this.showError,
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
        other.errorMessage == errorMessage &&
        other.isEvaluationError == isEvaluationError &&
        other.evaluationError == evaluationError &&
        other.showError == showError;
  }

  @override
  int get hashCode =>
      expression.hashCode ^
      result.hashCode ^
      hasError.hashCode ^
      errorMessage.hashCode ^
      isEvaluationError.hashCode ^
      evaluationError.hashCode ^
      showError.hashCode;

  @override
  String toString() =>
      'ExpressionDisplayState(expression: $expression, result: $result, hasError: $hasError, errorMessage: $errorMessage, isEvaluationError: $isEvaluationError, evaluationError: $evaluationError, showError: $showError)';
}
