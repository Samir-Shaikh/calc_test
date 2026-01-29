import '../entities/expression.dart';

/// Use case for inserting mathematical operators into an expression.
/// 
/// This use case handles the insertion of operator characters (+, -, *, /, ^, ×, ÷)
/// into an expression with proper validation rules:
/// 
/// - Prevents inserting an operator at the start of an empty expression
///   (except for the minus sign which can be used for negative numbers)
/// - Prevents consecutive operators by replacing the previous operator
///   with the new one
/// - Prevents inserting an operator immediately after an opening parenthesis
///   (except for minus which can indicate a negative number)
/// 
/// Example usage:
/// ```dart
/// final useCase = InsertOperatorUseCase();
/// var expression = Expression('5');
/// 
/// expression = useCase.execute(expression, '+'); // "5+"
/// expression = useCase.execute(expression, '*'); // "5*" (replaces + with *)
/// ```
class InsertOperatorUseCase {
  /// Executes the operator insertion.
  /// 
  /// Takes the current [expression] and the [operator] to insert.
  /// Returns a new Expression with the operator inserted according to
  /// the validation rules, or the same expression if the insertion
  /// is not allowed.
  /// 
  /// The [operator] must be one of: +, -, *, /, ^, ×, ÷
  /// 
  /// Throws [ArgumentError] if the operator is not valid.
  Expression execute(Expression expression, String operator) {
    // Validate that it's a valid operator
    if (!Expression.isOperator(operator)) {
      throw ArgumentError('Invalid operator: $operator. Must be one of: ${Expression.validOperators.join(", ")}');
    }
    
    // Handle empty expression
    if (expression.isEmpty) {
      // Only allow minus for negative numbers at the start
      if (operator == '-') {
        return expression.insertOperator(operator);
      }
      // Don't allow other operators at the start of an empty expression
      return expression;
    }
    
    // Check if there's an operator immediately before the cursor
    if (expression.hasOperatorBeforeCursor) {
      // Replace the previous operator with the new one
      // First delete the previous operator, then insert the new one
      final withoutPreviousOperator = expression.deleteBeforeCursor();
      return withoutPreviousOperator.insertOperator(operator);
    }
    
    // Check if there's an opening parenthesis before the cursor
    if (expression.hasOpenParenthesisBeforeCursor) {
      // Only allow minus after opening parenthesis (for negative numbers)
      if (operator == '-') {
        return expression.insertOperator(operator);
      }
      // Don't allow other operators after opening parenthesis
      return expression;
    }
    
    // Normal case: insert the operator
    return expression.insertOperator(operator);
  }
}
