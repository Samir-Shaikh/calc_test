import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/expression.dart';
import '../../../domain/usecases/evaluate_expression_use_case.dart';
import '../../../domain/usecases/insert_operator_use_case.dart';
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

  /// Use case for inserting operators with validation.
  final InsertOperatorUseCase _insertOperatorUseCase;

  /// Use case for evaluating mathematical expressions.
  final EvaluateExpressionUseCase _evaluateExpressionUseCase;

  /// Creates an ExpressionDisplayBloc with the required use cases.
  ///
  /// The [insertParenthesisUseCase] handles the toggle logic for
  /// inserting left or right parentheses.
  /// The [insertOperatorUseCase] handles operator insertion with validation.
  /// The [evaluateExpressionUseCase] handles expression evaluation.
  ExpressionDisplayBloc({
    required InsertParenthesisUseCase insertParenthesisUseCase,
    required InsertOperatorUseCase insertOperatorUseCase,
    required EvaluateExpressionUseCase evaluateExpressionUseCase,
  })  : _insertParenthesisUseCase = insertParenthesisUseCase,
        _insertOperatorUseCase = insertOperatorUseCase,
        _evaluateExpressionUseCase = evaluateExpressionUseCase,
        super(ExpressionDisplayState.initial()) {
    on<NumericPressed>(_onNumericPressed);
    on<OperatorPressed>(_onOperatorPressed);
    on<PowerOperatorPressed>(_onPowerOperatorPressed);
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

  /// Handles power operator (^) button presses.
  ///
  /// Uses the InsertOperatorUseCase to insert the '^' operator
  /// with proper validation (e.g., prevents consecutive operators).
  void _onPowerOperatorPressed(
    PowerOperatorPressed event,
    Emitter<ExpressionDisplayState> emit,
  ) {
    final newExpression = _insertOperatorUseCase.execute(state.expression, '^');
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
  /// Evaluates the current expression using the EvaluateExpressionUseCase
  /// and emits the result. Handles errors gracefully by setting hasError
  /// and errorMessage in the state.
  void _onEqualsPressed(
    EqualsPressed event,
    Emitter<ExpressionDisplayState> emit,
  ) {
    // Don't evaluate empty expressions
    if (state.expression.isEmpty) {
      return;
    }

    final result = _evaluateExpressionUseCase.execute(state.expression.value);

    // Check if evaluation returned an error
    if (result == 'Error') {
      emit(state.copyWith(
        result: null,
        hasError: true,
        errorMessage: 'Invalid expression',
      ));
    } else {
      emit(state.copyWith(
        result: result,
        hasError: false,
        errorMessage: null,
      ));
    }
  }
}
