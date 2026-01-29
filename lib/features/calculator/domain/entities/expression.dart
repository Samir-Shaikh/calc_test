/// Represents a mathematical expression with cursor support.
/// 
/// This entity encapsulates the expression string and provides
/// methods for manipulating the expression, including inserting
/// characters at the cursor position.
class Expression {
  /// The current expression string.
  final String value;
  
  /// The current cursor position within the expression.
  /// Defaults to the end of the expression.
  final int cursorPosition;
  
  /// Creates a new Expression with the given value and cursor position.
  /// 
  /// If [cursorPosition] is not provided, it defaults to the end of the expression.
  Expression(this.value, [int? cursorPosition])
      : cursorPosition = cursorPosition ?? value.length;
  
  /// Creates an empty expression.
  factory Expression.empty() => Expression('', 0);
  
  /// Inserts a character at the current cursor position.
  /// 
  /// Returns a new Expression with the character inserted and
  /// the cursor moved to after the inserted character.
  Expression insertAt(String char) {
    final newValue = value.substring(0, cursorPosition) + 
                     char + 
                     value.substring(cursorPosition);
    return Expression(newValue, cursorPosition + char.length);
  }
  
  /// Inserts a parenthesis character at the current cursor position.
  /// 
  /// This is a convenience method that handles both '(' and ')' characters.
  /// The cursor is positioned after the inserted parenthesis.
  Expression insertParenthesis(String parenthesis) {
    if (parenthesis != '(' && parenthesis != ')') {
      throw ArgumentError('Invalid parenthesis character: $parenthesis');
    }
    return insertAt(parenthesis);
  }
  
  /// Appends a character to the end of the expression.
  /// 
  /// Returns a new Expression with the character appended and
  /// the cursor at the end.
  Expression append(String char) {
    final newValue = value + char;
    return Expression(newValue, newValue.length);
  }
  
  /// Clears the expression, returning an empty expression.
  Expression clear() => Expression.empty();
  
  /// Deletes the character before the cursor position (backspace).
  /// 
  /// Returns a new Expression with the character removed and
  /// the cursor moved back by one position.
  /// If the cursor is at position 0, returns the same expression.
  Expression deleteBeforeCursor() {
    if (cursorPosition == 0) {
      return this;
    }
    final newValue = value.substring(0, cursorPosition - 1) + 
                     value.substring(cursorPosition);
    return Expression(newValue, cursorPosition - 1);
  }
  
  /// Moves the cursor to a new position.
  /// 
  /// The position is clamped to valid bounds (0 to value.length).
  Expression moveCursor(int newPosition) {
    final clampedPosition = newPosition.clamp(0, value.length);
    return Expression(value, clampedPosition);
  }
  
  /// Returns true if the expression is empty.
  bool get isEmpty => value.isEmpty;
  
  /// Returns true if the expression is not empty.
  bool get isNotEmpty => value.isNotEmpty;
  
  /// Returns the length of the expression.
  int get length => value.length;
  
  @override
  String toString() => value;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expression &&
           other.value == value &&
           other.cursorPosition == cursorPosition;
  }
  
  @override
  int get hashCode => value.hashCode ^ cursorPosition.hashCode;
}
