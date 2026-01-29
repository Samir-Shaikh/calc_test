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
  
  /// List of valid operator characters supported by the calculator.
  /// Includes: +, -, *, /, × (multiplication), ÷ (division), ^ (power)
  static const List<String> validOperators = ['+', '-', '*', '/', '×', '÷', '^'];
  
  /// Creates a new Expression with the given value and cursor position.
  /// 
  /// If [cursorPosition] is not provided, it defaults to the end of the expression.
  Expression(this.value, [int? cursorPosition])
      : cursorPosition = cursorPosition ?? value.length;
  
  /// Creates an empty expression.
  factory Expression.empty() => Expression('', 0);
  
  /// Checks if the given character is a valid operator.
  static bool isOperator(String char) {
    return validOperators.contains(char);
  }
  
  /// Checks if the given character is a digit (0-9).
  static bool isDigit(String char) {
    return char.length == 1 && char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
  }
  
  /// Checks if the given character is part of a number (digit or decimal point).
  static bool isNumberChar(String char) {
    return isDigit(char) || char == '.';
  }
  
  /// Returns the character before the cursor position, or null if at the start.
  String? get characterBeforeCursor {
    if (cursorPosition == 0 || value.isEmpty) {
      return null;
    }
    return value[cursorPosition - 1];
  }
  
  /// Returns true if the character before the cursor is an operator.
  bool get hasOperatorBeforeCursor {
    final char = characterBeforeCursor;
    return char != null && isOperator(char);
  }
  
  /// Returns true if the character before the cursor is an opening parenthesis.
  bool get hasOpenParenthesisBeforeCursor {
    return characterBeforeCursor == '(';
  }
  
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
  
  /// Inserts a character at a specific position in the expression.
  /// 
  /// Returns a new Expression with the character inserted.
  /// The cursor position is adjusted if necessary:
  /// - If insertion is before or at cursor, cursor moves forward
  /// - If insertion is after cursor, cursor stays the same
  Expression insertCharacterAt(String char, int position) {
    final clampedPosition = position.clamp(0, value.length);
    final newValue = value.substring(0, clampedPosition) + 
                     char + 
                     value.substring(clampedPosition);
    
    // Adjust cursor position if insertion is at or before cursor
    final newCursorPosition = clampedPosition <= cursorPosition 
        ? cursorPosition + char.length 
        : cursorPosition;
    
    return Expression(newValue, newCursorPosition);
  }
  
  /// Removes the character at a specific position in the expression.
  /// 
  /// Returns a new Expression with the character removed.
  /// The cursor position is adjusted if necessary:
  /// - If removal is before cursor, cursor moves backward
  /// - If removal is at or after cursor, cursor stays the same (unless it would be out of bounds)
  Expression removeCharacterAt(int position) {
    if (position < 0 || position >= value.length) {
      return this;
    }
    
    final newValue = value.substring(0, position) + value.substring(position + 1);
    
    // Adjust cursor position if removal is before cursor
    int newCursorPosition = cursorPosition;
    if (position < cursorPosition) {
      newCursorPosition = cursorPosition - 1;
    }
    // Ensure cursor doesn't go out of bounds
    newCursorPosition = newCursorPosition.clamp(0, newValue.length);
    
    return Expression(newValue, newCursorPosition);
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
  
  /// Inserts an operator at the current cursor position.
  /// 
  /// This is a convenience method that validates the operator character.
  /// Throws [ArgumentError] if the operator is not valid.
  Expression insertOperator(String operator) {
    if (!isOperator(operator)) {
      throw ArgumentError('Invalid operator character: $operator');
    }
    return insertAt(operator);
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
  
  /// Deletes the character at cursorPosition-1 (backspace operation).
  /// 
  /// This method removes the character immediately before the cursor
  /// and returns a new Expression with the updated text and cursor position.
  /// 
  /// Returns the same expression unchanged if:
  /// - The cursor is at position 0 (nothing to delete before cursor)
  /// - The expression is empty
  /// 
  /// Example:
  /// ```dart
  /// var expr = Expression('123', 2); // cursor after '2'
  /// expr = expr.deleteCharacterAtCursor(); // '13' with cursor at 1
  /// ```
  Expression deleteCharacterAtCursor() {
    // Handle edge cases: cursor at position 0 or empty expression
    if (cursorPosition == 0 || value.isEmpty) {
      return this;
    }
    
    // Remove character at cursorPosition - 1
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
  
  /// Finds the boundary of the current number at or near the cursor position.
  /// 
  /// Returns a [NumberBoundary] containing the start and end indices of the number,
  /// or null if no number is found at the cursor position.
  /// 
  /// This method searches both backward and forward from the cursor to find
  /// the complete number, including handling negative numbers and decimal points.
  /// 
  /// Example:
  /// ```dart
  /// var expr = Expression('12+345', 4); // cursor in middle of '345'
  /// var boundary = expr.findCurrentNumberBoundary(); // start: 3, end: 6
  /// ```
  NumberBoundary? findCurrentNumberBoundary() {
    if (value.isEmpty) {
      return null;
    }
    
    // Start searching from cursor position
    // If cursor is at end or after the last char, start from cursorPosition - 1
    int searchStart = cursorPosition;
    if (searchStart > 0 && searchStart >= value.length) {
      searchStart = value.length - 1;
    }
    
    // If cursor is at a position, check if we're in a number
    // First, try to find a number character at or before the cursor
    int startIndex = -1;
    int endIndex = -1;
    
    // Search backward from cursor to find start of number
    int pos = searchStart;
    
    // If we're not on a number char, check position before cursor
    if (pos < value.length && !isNumberChar(value[pos])) {
      if (cursorPosition > 0 && isNumberChar(value[cursorPosition - 1])) {
        pos = cursorPosition - 1;
      }
    }
    
    // Now find the start of the number
    if (pos >= 0 && pos < value.length && isNumberChar(value[pos])) {
      startIndex = pos;
      endIndex = pos + 1;
      
      // Search backward for start
      while (startIndex > 0 && isNumberChar(value[startIndex - 1])) {
        startIndex--;
      }
      
      // Search forward for end
      while (endIndex < value.length && isNumberChar(value[endIndex])) {
        endIndex++;
      }
      
      return NumberBoundary(startIndex, endIndex);
    }
    
    return null;
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

/// Represents the boundary indices of a number in an expression.
/// 
/// [start] is the inclusive start index of the number.
/// [end] is the exclusive end index of the number.
class NumberBoundary {
  final int start;
  final int end;
  
  const NumberBoundary(this.start, this.end);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NumberBoundary && other.start == start && other.end == end;
  }
  
  @override
  int get hashCode => start.hashCode ^ end.hashCode;
  
  @override
  String toString() => 'NumberBoundary(start: $start, end: $end)';
}
