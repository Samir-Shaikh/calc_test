import '../entities/expression.dart';

/// Use case for toggling the sign of a number in an expression (+/-).
/// 
/// This use case handles the negate/toggle sign functionality that toggles
/// the sign of the current number at the cursor position. It handles several
/// scenarios:
/// 
/// - Empty expression: Inserts a minus sign ('-') to start a negative number
/// - At start of expression: Toggles the sign of the first number
/// - After an operator: Inserts a minus sign for a negative number
/// - For existing negative number: Removes the minus sign
/// - In the middle of a number: Toggles the sign of that number
/// 
/// Example usage:
/// ```dart
/// final useCase = NegateValueUseCase();
/// var expression = Expression('5');
/// 
/// expression = useCase.execute(expression); // "-5"
/// expression = useCase.execute(expression); // "5"
/// 
/// expression = Expression('3+5');
/// expression = useCase.execute(expression); // "3+-5" or "3+(-5)"
/// ```
class NegateValueUseCase {
  /// Executes the negate/toggle sign operation.
  /// 
  /// Takes the current [expression] and returns a new Expression with the
  /// sign of the current number toggled.
  /// 
  /// The cursor position is updated appropriately:
  /// - When inserting a minus, cursor moves forward by 1
  /// - When removing a minus, cursor moves backward by 1
  Expression execute(Expression expression) {
    // Handle empty expression - insert minus sign
    if (expression.isEmpty) {
      return expression.insertAt('-');
    }
    
    // Find the boundaries of the current number at cursor position
    final numberBoundary = expression.findCurrentNumberBoundary();
    
    if (numberBoundary == null) {
      // No number found at cursor - insert minus sign at cursor
      // This handles cases like cursor after an operator
      return expression.insertAt('-');
    }
    
    final startIndex = numberBoundary.start;
    final value = expression.value;
    
    // Check if the number is already negative
    // A number is negative if it starts with '-' and either:
    // - It's at the beginning of the expression
    // - It's preceded by an operator (other than '-') or '('
    if (startIndex > 0 && value[startIndex - 1] == '-') {
      // Check if this minus is a negation sign (not a subtraction operator)
      final isNegationSign = _isNegationSign(value, startIndex - 1);
      
      if (isNegationSign) {
        // Remove the minus sign (make number positive)
        return expression.removeCharacterAt(startIndex - 1);
      }
    }
    
    // Check if number starts with minus at position 0
    if (startIndex == 0 && value.isNotEmpty && value[0] == '-') {
      // Check if the first character is a minus and cursor is within the first number
      // Remove the minus sign
      return expression.removeCharacterAt(0);
    }
    
    // Number is positive - insert minus sign to make it negative
    return expression.insertCharacterAt('-', startIndex);
  }
  
  /// Determines if the minus sign at [index] is a negation sign (not subtraction).
  /// 
  /// A minus is a negation sign if:
  /// - It's at position 0
  /// - It's preceded by an operator (+, *, /, ^, ×, ÷) but not another minus
  /// - It's preceded by an opening parenthesis '('
  bool _isNegationSign(String value, int index) {
    if (index == 0) {
      return true;
    }
    
    final charBefore = value[index - 1];
    
    // Check if preceded by an operator (except minus) or opening parenthesis
    return charBefore == '+' ||
           charBefore == '*' ||
           charBefore == '/' ||
           charBefore == '^' ||
           charBefore == '×' ||
           charBefore == '÷' ||
           charBefore == '(';
  }
}
