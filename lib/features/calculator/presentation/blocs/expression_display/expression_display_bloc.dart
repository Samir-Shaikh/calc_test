import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/clear_expression_use_case.dart';
import '../../../domain/usecases/delete_character_use_case.dart';
import '../../../domain/usecases/evaluate_expression_use_case.dart';
import '../../../domain/usecases/insert_operator_use_case.dart';
import '../../../domain/usecases/insert_parenthesis_use_case.dart';
import '../../../domain/usecases/negate_value_use_case.dart';
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

  /// Use case for inserting operators with validation.
  final InsertOperatorUseCase _insertOperatorUseCase;

  /// Use case for evaluating mathematical expressions.
  final EvaluateExpressionUseCase _evaluateExpressionUseCase;

  /// Use case for clearing the expression and resetting state.
  final ClearExpressionUseCase _clearExpressionUseCase;

  /// Use case for deleting characters at the cursor position (backspace).
  final DeleteCharacterUseCase _deleteCharacterUseCase;

  /// Use case for toggling the sign of the current number (+/-).
  final NegateValueUseCase _negateValueUseCase;

  /// Creates an ExpressionDisplayBloc with the required use cases.
  ///
  /// The [insertParenthesisUseCase] handles the toggle logic for
  /// inserting left or right parentheses.
  /// The [insertOperatorUseCase] handles operator insertion with validation.
  /// The [evaluateExpressionUseCase] handles expression evaluation.
  /// The [clearExpressionUseCase] handles clearing the expression and resetting state.
  /// The [deleteCharacterUseCase] handles deleting characters at the cursor position.
  /// The [negateValueUseCase] handles toggling the sign of the current number.
  ExpressionDisplayBloc({
    required InsertParenthesisUseCase insertParenthesisUseCase,
    required InsertOperatorUseCase insertOperatorUseCase,
    required EvaluateExpressionUseCase evaluateExpressionUseCase,
    required ClearExpressionUseCase clearExpressionUseCase,
    required DeleteCharacterUseCase deleteCharacterUseCase,
    required NegateValueUseCase negateValueUseCase,
  })  : _insertParenthesisUseCase = insertParenthesisUseCase,
        _insertOperatorUseCase = insertOperatorUseCase,
        _evaluateExpressionUseCase = evaluateExpressionUseCase,
        _clearExpressionUseCase = clearExpressionUseCase,
        _deleteCharacterUseCase = deleteCharacterUseCase,
        _negateValueUseCase = negateValueUseCase,
        super(ExpressionDisplayState.initial()) {
    on<NumericPressed>(_onNumericPressed);
    on<OperatorPressed>(_onOperatorPressed);
    on<PowerOperatorPressed>(_onPowerOperatorPressed);
    on<ParenthesisPressed>(_onParenthesisPressed);
    on<DecimalPressed>(_onDecimalPressed);
    on<ClearPressed>(_onClearPressed);
    on<BackspacePressed>(_onBackspacePressed);
    on<EqualsPressed>(_onEqualsPressed);
    on<NegatePressed>(_onNegatePressed);
    on<ErrorAcknowledged>(_onErrorAcknowledged);
  }

  /// Handles numeric digit presses.
  /// Clears any evaluation error state from previous operations.
  void _onNumericPressed(
    NumericPressed event,
    Emitter<ExpressionDisplayState> emit,
  ) {
    final newExpression = state.expression.insertAt(event.digit);
    emit(ExpressionDisplayState(
      expression: newExpression,
      result: null,
      hasError: false,
      errorMessage: null,
      isEvaluationError: false,
      evaluationError: null,
      showError: false,
    ));
  }

  /// Handles operator presses.
  /// Clears any evaluation error state from previous operations.
  void _onOperatorPressed(
    OperatorPressed event,
    Emitter<ExpressionDisplayState> emit,
  ) {
    final newExpression = state.expression.insertAt(event.operator);
    emit(ExpressionDisplayState(
      expression: newExpression,
      result: null,
      hasError: false,
      errorMessage: null,
      isEvaluationError: false,
      evaluationError: null,
      showError: false,
    ));
  }

  /// Handles power operator (^) button presses.
  ///
  /// Uses the InsertOperatorUseCase to insert the '^' operator
  /// with proper validation (e.g., prevents consecutive operators).
  /// Clears any evaluation error state from previous operations.
  void _onPowerOperatorPressed(
    PowerOperatorPressed event,
    Emitter<ExpressionDisplayState> emit,
  ) {
    final newExpression = _insertOperatorUseCase.execute(state.expression, '^');
    emit(ExpressionDisplayState(
      expression: newExpression,
      result: null,
      hasError: false,
      errorMessage: null,
      isEvaluationError: false,
      evaluationError: null,
      showError: false,
    ));
  }

  /// Handles parenthesis button presses.
  ///
  /// Uses the InsertParenthesisUseCase to determine whether to insert
  /// an opening '(' or closing ')' parenthesis based on the toggle state.
  /// Clears any evaluation error state from previous operations.
  void _onParenthesisPressed(
    ParenthesisPressed event,
    Emitter<ExpressionDisplayState> emit,
  ) {
    final newExpression = _insertParenthesisUseCase.execute(state.expression);
    emit(ExpressionDisplayState(
      expression: newExpression,
      result: null,
      hasError: false,
      errorMessage: null,
      isEvaluationError: false,
      evaluationError: null,
      showError: false,
    ));
  }

  /// Handles decimal point presses.
  /// Clears any evaluation error state from previous operations.
  void _onDecimalPressed(
    DecimalPressed event,
    Emitter<ExpressionDisplayState> emit,
  ) {
    final newExpression = state.expression.insertAt('.');
    emit(ExpressionDisplayState(
      expression: newExpression,
      result: null,
      hasError: false,
      errorMessage: null,
      isEvaluationError: false,
      evaluationError: null,
      showError: false,
    ));
  }

  /// Handles clear button presses.
  ///
  /// Uses the ClearExpressionUseCase to reset the expression state.
  /// Emits a new state with empty expression, empty result, and
  /// resets the bracket toggle state to ensure the next parenthesis
  /// press inserts '('.
  /// Also clears any evaluation error state.
  void _onClearPressed(
    ClearPressed event,
    Emitter<ExpressionDisplayState> emit,
  ) {
    // Execute the clear use case to get the reset state
    final clearResult = _clearExpressionUseCase.execute();

    // Reset the bracket state in the parenthesis use case
    // so next parenthesis insertion starts with '('
    _insertParenthesisUseCase.resetBracketState();

    emit(ExpressionDisplayState(
      expression: clearResult.expression,
      result: null,
      hasError: false,
      errorMessage: null,
      isEvaluationError: false,
      evaluationError: null,
      showError: false,
    ));
  }

  /// Handles backspace/delete presses.
  ///
  /// Uses the DeleteCharacterUseCase to delete the character before the cursor.
  /// If the cursor is at position 0 or the expression is empty, no deletion
  /// occurs (the use case returns the same expression).
  /// Clears any evaluation error state from previous operations.
  void _onBackspacePressed(
    BackspacePressed event,
    Emitter<ExpressionDisplayState> emit,
  ) {
    final newExpression = _deleteCharacterUseCase.execute(state.expression);
    
    // Only emit new state if the expression actually changed
    // This handles edge cases where no deletion occurs (cursor at 0 or empty expression)
    if (newExpression != state.expression) {
      emit(ExpressionDisplayState(
        expression: newExpression,
        result: null,
        hasError: false,
        errorMessage: null,
        isEvaluationError: false,
        evaluationError: null,
        showError: false,
      ));
    }
  }

  /// Handles equals button presses.
  ///
  /// Evaluates the current expression using the EvaluateExpressionUseCase
  /// and emits the result. Handles errors gracefully by setting appropriate
  /// error states:
  /// - [EvaluationSuccess]: Updates result with computed value
  /// - [EvaluationInvalidInput]: Sets showError for toast notification while
  ///   preserving the previous result value
  /// - [EvaluationDivisionByZero]: Shows special display value (Infinity/NaN)
  void _onEqualsPressed(
    EqualsPressed event,
    Emitter<ExpressionDisplayState> emit,
  ) {
    // Don't evaluate empty expressions
    if (state.expression.isEmpty) {
      return;
    }

    final evaluationResult = _evaluateExpressionUseCase.execute(state.expression.value);

    // Handle the evaluation result using pattern matching
    switch (evaluationResult) {
      case EvaluationSuccess():
        emit(ExpressionDisplayState(
          expression: state.expression,
          result: evaluationResult.formattedValue,
          hasError: false,
          errorMessage: null,
          isEvaluationError: false,
          evaluationError: null,
          showError: false,
        ));
      case EvaluationInvalidInput():
        // Emit error state with showError flag for toast notification
        // Preserve the previous result value so the result display remains unchanged
        emit(ExpressionDisplayState(
          expression: state.expression,
          result: state.result, // Preserve previous result (AC3 requirement)
          hasError: true,
          errorMessage: 'Invalid Input',
          isEvaluationError: true,
          evaluationError: 'Invalid Input',
          showError: true,
        ));
      case EvaluationDivisionByZero():
        // Division by zero is shown as the result (Infinity, -Infinity, or NaN)
        // rather than as an error, matching standard calculator behavior
        emit(ExpressionDisplayState(
          expression: state.expression,
          result: evaluationResult.displayValue,
          hasError: false,
          errorMessage: null,
          isEvaluationError: false,
          evaluationError: null,
          showError: false,
        ));
    }
  }

  /// Handles negate/plus-minus button presses.
  ///
  /// Uses the NegateValueUseCase to toggle the sign of the current number
  /// at the cursor position. This handles:
  /// - Empty expression: Inserts a minus sign to start a negative number
  /// - Positive number: Inserts a minus sign to make it negative
  /// - Negative number: Removes the minus sign to make it positive
  /// Clears any evaluation error state from previous operations.
  void _onNegatePressed(
    NegatePressed event,
    Emitter<ExpressionDisplayState> emit,
  ) {
    final newExpression = _negateValueUseCase.execute(state.expression);
    emit(ExpressionDisplayState(
      expression: newExpression,
      result: null,
      hasError: false,
      errorMessage: null,
      isEvaluationError: false,
      evaluationError: null,
      showError: false,
    ));
  }

  /// Handles error acknowledgement after toast display.
  ///
  /// Resets the [showError] flag to false after the toast has been displayed,
  /// preventing repeated toast displays on subsequent state emissions.
  /// All other state values are preserved.
  void _onErrorAcknowledged(
    ErrorAcknowledged event,
    Emitter<ExpressionDisplayState> emit,
  ) {
    // Only emit if there was an error being shown
    if (state.showError) {
      emit(state.copyWith(showError: false));
    }
  }
}
