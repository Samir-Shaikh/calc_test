/// Events for the Expression Display BLoC.
///
/// These events represent user interactions with the calculator
/// that affect the expression display.
library;

/// Base class for all expression display events.
abstract class ExpressionDisplayEvent {
  const ExpressionDisplayEvent();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpressionDisplayEvent && runtimeType == other.runtimeType;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Event triggered when a numeric digit is pressed.
class NumericPressed extends ExpressionDisplayEvent {
  /// The digit that was pressed (0-9).
  final String digit;

  const NumericPressed(this.digit);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NumericPressed && other.digit == digit;
  }

  @override
  int get hashCode => digit.hashCode;

  @override
  String toString() => 'NumericPressed(digit: $digit)';
}

/// Event triggered when an operator is pressed.
class OperatorPressed extends ExpressionDisplayEvent {
  /// The operator that was pressed (+, -, ×, ÷).
  final String operator;

  const OperatorPressed(this.operator);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OperatorPressed && other.operator == operator;
  }

  @override
  int get hashCode => operator.hashCode;

  @override
  String toString() => 'OperatorPressed(operator: $operator)';
}

/// Event triggered when the power operator button is pressed.
///
/// This event triggers the insertion of '^' into the expression
/// for exponentiation operations.
class PowerOperatorPressed extends ExpressionDisplayEvent {
  const PowerOperatorPressed();

  @override
  String toString() => 'PowerOperatorPressed()';
}

/// Event triggered when the parenthesis button is pressed.
///
/// This event triggers the toggle logic for inserting the appropriate
/// bracket (either opening or closing parenthesis) based on the current
/// expression state.
class ParenthesisPressed extends ExpressionDisplayEvent {
  const ParenthesisPressed();

  @override
  String toString() => 'ParenthesisPressed()';
}

/// Event triggered when the decimal point is pressed.
class DecimalPressed extends ExpressionDisplayEvent {
  const DecimalPressed();

  @override
  String toString() => 'DecimalPressed()';
}

/// Event triggered when the clear button is pressed.
class ClearPressed extends ExpressionDisplayEvent {
  const ClearPressed();

  @override
  String toString() => 'ClearPressed()';
}

/// Event triggered when the backspace/delete button is pressed.
class BackspacePressed extends ExpressionDisplayEvent {
  const BackspacePressed();

  @override
  String toString() => 'BackspacePressed()';
}

/// Event triggered when the equals button is pressed.
class EqualsPressed extends ExpressionDisplayEvent {
  const EqualsPressed();

  @override
  String toString() => 'EqualsPressed()';
}
