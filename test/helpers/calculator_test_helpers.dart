import 'package:android_calculator_flutter/features/calculator/domain/entities/expression.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/clear_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_operator_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_parenthesis_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_bloc.dart';

/// Mock implementation of [ClearExpressionUseCase] for testing.
///
/// This mock allows tests to control the behavior of the clear operation
/// by providing a custom [ClearResult] or using the default behavior.
///
/// Usage:
/// ```dart
/// final mockClearUseCase = MockClearExpressionUseCase();
/// final bloc = ExpressionDisplayBloc(
///   insertParenthesisUseCase: InsertParenthesisUseCase(),
///   insertOperatorUseCase: InsertOperatorUseCase(),
///   evaluateExpressionUseCase: EvaluateExpressionUseCase(),
///   clearExpressionUseCase: mockClearUseCase,
/// );
/// ```
class MockClearExpressionUseCase extends ClearExpressionUseCase {
  /// Optional custom result to return from [execute].
  ClearResult? customResult;

  /// Counter to track how many times [execute] has been called.
  int executeCallCount = 0;

  /// Creates a mock clear expression use case.
  ///
  /// If [customResult] is provided, it will be returned by [execute].
  /// Otherwise, the default behavior (empty expression, leftBracketNext=true)
  /// will be used.
  MockClearExpressionUseCase({this.customResult});

  @override
  ClearResult execute() {
    executeCallCount++;
    return customResult ?? super.execute();
  }

  /// Resets the mock state.
  void reset() {
    executeCallCount = 0;
    customResult = null;
  }
}

/// Mock implementation of [InsertParenthesisUseCase] for testing.
///
/// This mock allows tests to track calls and control the bracket state.
class MockInsertParenthesisUseCase extends InsertParenthesisUseCase {
  /// Counter to track how many times [execute] has been called.
  int executeCallCount = 0;

  /// Counter to track how many times [resetBracketState] has been called.
  int resetBracketStateCallCount = 0;

  @override
  Expression execute(Expression expression) {
    executeCallCount++;
    return super.execute(expression);
  }

  @override
  void resetBracketState() {
    resetBracketStateCallCount++;
    super.resetBracketState();
  }

  /// Resets the mock state.
  void reset() {
    executeCallCount = 0;
    resetBracketStateCallCount = 0;
  }
}

/// Mock implementation of [InsertOperatorUseCase] for testing.
///
/// This mock allows tests to track calls to the operator insertion.
class MockInsertOperatorUseCase extends InsertOperatorUseCase {
  /// Counter to track how many times [execute] has been called.
  int executeCallCount = 0;

  /// The last operator that was passed to [execute].
  String? lastOperator;

  @override
  Expression execute(Expression expression, String operator) {
    executeCallCount++;
    lastOperator = operator;
    return super.execute(expression, operator);
  }

  /// Resets the mock state.
  void reset() {
    executeCallCount = 0;
    lastOperator = null;
  }
}

/// Mock implementation of [EvaluateExpressionUseCase] for testing.
///
/// This mock allows tests to control the evaluation result.
class MockEvaluateExpressionUseCase extends EvaluateExpressionUseCase {
  /// Optional custom result to return from [execute].
  EvaluationResult? customResult;

  /// Counter to track how many times [execute] has been called.
  int executeCallCount = 0;

  /// The last expression that was passed to [execute].
  String? lastExpression;

  @override
  EvaluationResult execute(String expression) {
    executeCallCount++;
    lastExpression = expression;
    return customResult ?? super.execute(expression);
  }

  /// Resets the mock state.
  void reset() {
    executeCallCount = 0;
    lastExpression = null;
    customResult = null;
  }
}

/// Creates an [ExpressionDisplayBloc] with default use cases for testing.
///
/// This helper function simplifies test setup by creating a BLoC
/// with all required dependencies using real implementations.
///
/// Usage:
/// ```dart
/// final bloc = createTestBloc();
/// bloc.add(const NumericPressed('5'));
/// ```
ExpressionDisplayBloc createTestBloc({
  InsertParenthesisUseCase? insertParenthesisUseCase,
  InsertOperatorUseCase? insertOperatorUseCase,
  EvaluateExpressionUseCase? evaluateExpressionUseCase,
  ClearExpressionUseCase? clearExpressionUseCase,
}) {
  return ExpressionDisplayBloc(
    insertParenthesisUseCase:
        insertParenthesisUseCase ?? InsertParenthesisUseCase(),
    insertOperatorUseCase: insertOperatorUseCase ?? InsertOperatorUseCase(),
    evaluateExpressionUseCase:
        evaluateExpressionUseCase ?? EvaluateExpressionUseCase(),
    clearExpressionUseCase: clearExpressionUseCase ?? ClearExpressionUseCase(),
  );
}

/// Creates an [ExpressionDisplayBloc] with all mock use cases for testing.
///
/// This helper function simplifies test setup by creating a BLoC
/// with mock implementations that can be used to verify interactions.
///
/// Returns a record containing the bloc and all mock use cases.
///
/// Usage:
/// ```dart
/// final (bloc, mocks) = createTestBlocWithMocks();
/// bloc.add(const ClearPressed());
/// expect(mocks.clearExpressionUseCase.executeCallCount, equals(1));
/// ```
({
  ExpressionDisplayBloc bloc,
  MockInsertParenthesisUseCase insertParenthesisUseCase,
  MockInsertOperatorUseCase insertOperatorUseCase,
  MockEvaluateExpressionUseCase evaluateExpressionUseCase,
  MockClearExpressionUseCase clearExpressionUseCase,
}) createTestBlocWithMocks() {
  final insertParenthesisUseCase = MockInsertParenthesisUseCase();
  final insertOperatorUseCase = MockInsertOperatorUseCase();
  final evaluateExpressionUseCase = MockEvaluateExpressionUseCase();
  final clearExpressionUseCase = MockClearExpressionUseCase();

  final bloc = ExpressionDisplayBloc(
    insertParenthesisUseCase: insertParenthesisUseCase,
    insertOperatorUseCase: insertOperatorUseCase,
    evaluateExpressionUseCase: evaluateExpressionUseCase,
    clearExpressionUseCase: clearExpressionUseCase,
  );

  return (
    bloc: bloc,
    insertParenthesisUseCase: insertParenthesisUseCase,
    insertOperatorUseCase: insertOperatorUseCase,
    evaluateExpressionUseCase: evaluateExpressionUseCase,
    clearExpressionUseCase: clearExpressionUseCase,
  );
}
