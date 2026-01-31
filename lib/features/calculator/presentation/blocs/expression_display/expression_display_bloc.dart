import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/expression.dart';
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
/// Handles all user interactions that affect the calculator display:
/// numeric input, operators, parentheses, evaluation, and error handling.
class ExpressionDisplayBloc
    extends Bloc<ExpressionDisplayEvent, ExpressionDisplayState> {
  final InsertParenthesisUseCase _insertParenthesisUseCase;
  final InsertOperatorUseCase _insertOperatorUseCase;
  final EvaluateExpressionUseCase _evaluateExpressionUseCase;
  final ClearExpressionUseCase _clearExpressionUseCase;
  final DeleteCharacterUseCase _deleteCharacterUseCase;
  final NegateValueUseCase _negateValueUseCase;

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

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  ExpressionDisplayState _resetState(Expression newExpression) {
    return ExpressionDisplayState(
      expression: newExpression,
      result: null,
      hasError: false,
      errorMessage: null,
      isEvaluationError: false,
      evaluationError: null,
      showError: false,
    );
  }

  // ---------------------------------------------------------------------------
  // Input handlers
  // ---------------------------------------------------------------------------

  void _onNumericPressed(
      NumericPressed event,
      Emitter<ExpressionDisplayState> emit,
      ) {
    emit(_resetState(state.expression.insertAt(event.digit)));
  }

  void _onOperatorPressed(
      OperatorPressed event,
      Emitter<ExpressionDisplayState> emit,
      ) {
    emit(_resetState(state.expression.insertAt(event.operator)));
  }

  void _onPowerOperatorPressed(
      PowerOperatorPressed event,
      Emitter<ExpressionDisplayState> emit,
      ) {
    emit(_resetState(
      _insertOperatorUseCase.execute(state.expression, '^'),
    ));
  }

  void _onParenthesisPressed(
      ParenthesisPressed event,
      Emitter<ExpressionDisplayState> emit,
      ) {
    emit(_resetState(
      _insertParenthesisUseCase.execute(state.expression),
    ));
  }

  void _onDecimalPressed(
      DecimalPressed event,
      Emitter<ExpressionDisplayState> emit,
      ) {
    emit(_resetState(state.expression.insertAt('.')));
  }

  void _onNegatePressed(
      NegatePressed event,
      Emitter<ExpressionDisplayState> emit,
      ) {
    emit(_resetState(
      _negateValueUseCase.execute(state.expression),
    ));
  }

  // ---------------------------------------------------------------------------
  // Clear / Delete
  // ---------------------------------------------------------------------------

  void _onClearPressed(
      ClearPressed event,
      Emitter<ExpressionDisplayState> emit,
      ) {
    final clearResult = _clearExpressionUseCase.execute();
    _insertParenthesisUseCase.resetBracketState();

    emit(_resetState(clearResult.expression));
  }

  void _onBackspacePressed(
      BackspacePressed event,
      Emitter<ExpressionDisplayState> emit,
      ) {
    final newExpression = _deleteCharacterUseCase.execute(state.expression);

    if (newExpression != state.expression) {
      emit(_resetState(newExpression));
    }
  }

  // ---------------------------------------------------------------------------
  // Evaluation
  // ---------------------------------------------------------------------------

  void _onEqualsPressed(
      EqualsPressed event,
      Emitter<ExpressionDisplayState> emit,
      ) {
    if (state.expression.isEmpty) return;

    final evaluationResult =
    _evaluateExpressionUseCase.execute(state.expression.value);

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
        emit(ExpressionDisplayState(
          expression: state.expression,
          result: state.result,
          hasError: true,
          errorMessage: 'Invalid Input',
          isEvaluationError: true,
          evaluationError: 'Invalid Input',
          showError: true,
        ));

      case EvaluationDivisionByZero():
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

  // ---------------------------------------------------------------------------
  // Error handling
  // ---------------------------------------------------------------------------

  void _onErrorAcknowledged(
      ErrorAcknowledged event,
      Emitter<ExpressionDisplayState> emit,
      ) {
    if (state.showError) {
      emit(state.copyWith(showError: false));
    }
  }
}