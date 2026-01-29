import '../entities/expression.dart';

/// Use case for clearing the calculator expression and resetting state.
/// 
/// This use case handles the clear/reset operation for the calculator,
/// returning an empty expression with the cursor at position 0.
/// 
/// The use case also provides information about bracket state reset,
/// indicating that the bracket toggle should be reset to insert '(' first.
/// 
/// Example usage:
/// ```dart
/// final useCase = ClearExpressionUseCase();
/// var expression = Expression('5+3*2');
/// 
/// final result = useCase.execute();
/// // result.expression is empty with cursor at 0
/// // result.leftBracketNext is true (bracket toggle reset)
/// ```
class ClearExpressionUseCase {
  /// Executes the clear operation.
  /// 
  /// Returns a [ClearResult] containing:
  /// - An empty [Expression] with cursor at position 0
  /// - [leftBracketNext] set to true, indicating the bracket toggle
  ///   should be reset to insert '(' on the next parenthesis insertion
  /// 
  /// This method is stateless and always returns the same result,
  /// representing a freshly cleared calculator state.
  ClearResult execute() {
    return ClearResult(
      expression: Expression.empty(),
      leftBracketNext: true,
    );
  }
}

/// Represents the result of a clear operation.
/// 
/// Contains the cleared expression and the reset bracket toggle state.
class ClearResult {
  /// The cleared expression (empty string with cursor at position 0).
  final Expression expression;
  
  /// Indicates that the bracket toggle should be reset to insert '(' next.
  /// 
  /// This value is always true after a clear operation, ensuring that
  /// the next parenthesis insertion will be an opening bracket '('.
  final bool leftBracketNext;
  
  const ClearResult({
    required this.expression,
    required this.leftBracketNext,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClearResult &&
           other.expression == expression &&
           other.leftBracketNext == leftBracketNext;
  }
  
  @override
  int get hashCode => expression.hashCode ^ leftBracketNext.hashCode;
  
  @override
  String toString() => 'ClearResult(expression: $expression, leftBracketNext: $leftBracketNext)';
}
