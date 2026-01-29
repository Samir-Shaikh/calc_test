import '../entities/expression.dart';

/// Use case for inserting parentheses with toggle logic.
/// 
/// This use case handles the toggle behavior for inserting left or right
/// parentheses. It maintains a [leftBracket] flag that alternates between
/// true (insert '(') and false (insert ')') with each call to [execute].
/// 
/// The flag starts as true and can be reset to true using [resetBracketState],
/// which should be called when the clear button is pressed.
/// 
/// Example usage:
/// ```dart
/// final useCase = InsertParenthesisUseCase();
/// var expression = Expression('5+');
/// 
/// expression = useCase.execute(expression); // Inserts '(' -> "5+("
/// expression = useCase.execute(expression); // Inserts ')' -> "5+()"
/// expression = useCase.execute(expression); // Inserts '(' -> "5+()(
/// 
/// useCase.resetBracketState(); // Reset for clear button
/// expression = useCase.execute(expression); // Inserts '(' again
/// ```
class InsertParenthesisUseCase {
  /// Flag indicating whether to insert left bracket '(' (true) or right bracket ')' (false).
  /// 
  /// Starts as true and toggles with each call to [execute].
  bool _leftBracket = true;
  
  /// Returns the current state of the bracket flag.
  /// 
  /// Returns true if the next insertion will be '(', false if ')'.
  bool get leftBracket => _leftBracket;
  
  /// Executes the parenthesis insertion.
  /// 
  /// Inserts '(' when [leftBracket] is true, ')' when false.
  /// After insertion, the flag is toggled for the next call.
  /// 
  /// Takes the current [expression] and returns a new Expression with
  /// the appropriate parenthesis inserted at the cursor position.
  Expression execute(Expression expression) {
    final parenthesis = _leftBracket ? '(' : ')';
    final newExpression = expression.insertParenthesis(parenthesis);
    
    // Toggle the bracket state for the next call
    _leftBracket = !_leftBracket;
    
    return newExpression;
  }
  
  /// Resets the bracket state to insert left bracket '(' on next call.
  /// 
  /// This method should be called when the clear button is pressed
  /// to reset the toggle state back to its initial value.
  void resetBracketState() {
    _leftBracket = true;
  }
}
