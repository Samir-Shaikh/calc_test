import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/expression.dart';
import '../../../domain/usecases/insert_parenthesis_use_case.dart';
import 'expression_display_event.dart';
import 'expression_display_state.dart';

/// BLoC for managing the expression display state.
///
/// This BLoC handles all user interactions that affect the calculator's
/// expression display, including numeric input, operators, parentheses,
/// and clear/backspace operations.
class ExpressionDisplayBloc
    extends Bloc<ExpressionDisplayEvent, ExpressionDisplayState> {
  /// Use case for inserting parentheses with toggle logic.
  final InsertParenthesisUseCase _insertParenthesisUseCase;

  /// Creates an ExpressionDisplayBloc with the required use cases.
  ///
  /// The [insertParenthesisUseCase] handles the toggle logic for
  /// inserting left or right parentheses.
  ExpressionDisplayBloc({
    required InsertParenthesisUseCase insertParenthesisUseCase,
  })  : _insertParenthesisUseCase = insertParenthesisUseCase,
        super(ExpressionDisplayState.initial()) {
    on<NumericPressed>(_onNumericPressed);
    on<OperatorPressed>(_onOperatorPressed);
    on<ParenthesisPressed>(_onParenthesisPressed);
    on<DecimalPressed>(_onDecimalPressed);
    on<ClearPressed>(_onClearPressed);
    on<BackspacePressed>(_onBackspacePressed);
    on<EqualsPressed>(_onEqualsPressed);
  }

  /// Handles numeric digit presses.
  void _onNumericPressed(
    NumericPressed event,
    Emitter<ExpressionDisplayState> emit,
  ) {
    final newExpression = state.expression.insertAt(event.digit);
    emit(state.copyWith(
      expression: newExpression,
      result: null,
      hasError: false,
      errorMessage: null,
    ));
  }

  /// Handles operator presses.
  void _onOperatorPressed(
    OperatorPressed event,
    Emitter<ExpressionDisplayState> emit,
  ) {
    final newExpression = state.expression.insertAt(event.operator);
    emit(state.copyWith(
      expression: newExpression,
      result: null,
      hasError: false,
      errorMessage: null,
    ));
  }

  /// Handles parenthesis button presses.
  ///
  /// Uses the InsertParenthesisUseCase to determine whether to insert
  /// an opening '(' or closing ')' parenthesis based on the toggle state.
  void _onParenthesisPressed(
    ParenthesisPressed event,
    Emitter<ExpressionDisplayState> emit,
  ) {
    final newExpression = _insertParenthesisUseCase.execute(state.expression);
    emit(state.copyWith(
      expression: newExpression,
      result: null,
      hasError: false,
      errorMessage: null,
    ));
  }

  /// Handles decimal point presses.
  void _onDecimalPressed(
    DecimalPressed event,
    Emitter<ExpressionDisplayState> emit,
  ) {
    final newExpression = state.expression.insertAt('.');
    emit(state.copyWith(
      expression: newExpression,
      result: null,
      hasError: false,
      errorMessage: null,
    ));
  }

  /// Handles clear button presses.
  ///
  /// Clears the expression and resets the parenthesis bracket state
  /// to ensure the next parenthesis press inserts '('.
  void _onClearPressed(
    ClearPressed event,
    Emitter<ExpressionDisplayState> emit,
  ) {
    // Reset the bracket state so next parenthesis insertion starts with '('
    _insertParenthesisUseCase.resetBracketState();

    emit(ExpressionDisplayState(
      expression: Expression.empty(),
      result: null,
      hasError: false,
      errorMessage: null,
    ));
  }

  /// Handles backspace/delete presses.
  void _onBackspacePressed(
    BackspacePressed event,
    Emitter<ExpressionDisplayState> emit,
  ) {
    final newExpression = state.expression.deleteBeforeCursor();
    emit(state.copyWith(
      expression: newExpression,
      result: null,
      hasError: false,
      errorMessage: null,
    ));
  }

  /// Handles equals button presses.
  ///
  /// Note: Evaluation logic is handled by a separate use case and
  /// will be integrated in a future task.
  void _onEqualsPressed(
    EqualsPressed event,
    Emitter<ExpressionDisplayState> emit,
  ) {
    // TODO: Integrate EvaluateExpressionUseCase for expression evaluation
    // For now, this is a placeholder that will be implemented later
  }
}
