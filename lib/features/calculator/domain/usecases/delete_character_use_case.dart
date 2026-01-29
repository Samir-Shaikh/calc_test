import '../entities/expression.dart';

/// Use case for deleting a character at the cursor position (backspace operation).
/// 
/// This use case handles the character deletion operation for the calculator,
/// removing the character immediately before the cursor position and updating
/// the cursor accordingly.
/// 
/// Edge cases handled:
/// - Cursor at position 0: Returns the expression unchanged (nothing to delete)
/// - Empty expression: Returns the expression unchanged
/// 
/// Example usage:
/// ```dart
/// final useCase = DeleteCharacterUseCase();
/// var expression = Expression('123', 3); // cursor at end
/// 
/// expression = useCase.execute(expression); // "12" with cursor at 2
/// expression = useCase.execute(expression); // "1" with cursor at 1
/// expression = useCase.execute(expression); // "" with cursor at 0
/// expression = useCase.execute(expression); // "" with cursor at 0 (unchanged)
/// ```
class DeleteCharacterUseCase {
  /// Executes the delete character operation.
  /// 
  /// Takes the current [expression] and returns a new Expression with the
  /// character before the cursor removed.
  /// 
  /// Returns the same expression unchanged if:
  /// - The cursor is at position 0 (nothing before cursor to delete)
  /// - The expression is empty
  /// 
  /// The cursor position is updated to reflect the deletion (moved back by 1).
  Expression execute(Expression expression) {
    return expression.deleteCharacterAtCursor();
  }
}
