import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/calculator/domain/usecases/evaluate_expression_use_case.dart';
import '../../features/calculator/domain/usecases/insert_operator_use_case.dart';
import '../../features/calculator/domain/usecases/insert_parenthesis_use_case.dart';
import '../../features/calculator/presentation/blocs/expression_display/expression_display_bloc.dart';

/// Dependency injection module for the calculator feature.
///
/// This module provides all the dependencies required by the calculator
/// feature, including use cases and BLoCs.
///
/// Usage:
/// ```dart
/// CalculatorModule(
///   child: CalculatorScreen(),
/// )
/// ```
class CalculatorModule extends StatelessWidget {
  /// The child widget that will have access to the provided dependencies.
  final Widget child;

  /// Optional InsertParenthesisUseCase for testing.
  final InsertParenthesisUseCase? insertParenthesisUseCase;

  /// Optional InsertOperatorUseCase for testing.
  final InsertOperatorUseCase? insertOperatorUseCase;

  /// Optional EvaluateExpressionUseCase for testing.
  final EvaluateExpressionUseCase? evaluateExpressionUseCase;

  const CalculatorModule({
    super.key,
    required this.child,
    this.insertParenthesisUseCase,
    this.insertOperatorUseCase,
    this.evaluateExpressionUseCase,
  });

  @override
  Widget build(BuildContext context) {
    // Create use case instances (or use provided ones for testing)
    final insertParenthesis =
        insertParenthesisUseCase ?? InsertParenthesisUseCase();
    final insertOperator =
        insertOperatorUseCase ?? InsertOperatorUseCase();
    final evaluateExpression =
        evaluateExpressionUseCase ?? EvaluateExpressionUseCase();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<InsertParenthesisUseCase>.value(
          value: insertParenthesis,
        ),
        RepositoryProvider<InsertOperatorUseCase>.value(
          value: insertOperator,
        ),
        RepositoryProvider<EvaluateExpressionUseCase>.value(
          value: evaluateExpression,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ExpressionDisplayBloc>(
            create: (context) => ExpressionDisplayBloc(
              insertParenthesisUseCase: insertParenthesis,
              insertOperatorUseCase: insertOperator,
              evaluateExpressionUseCase: evaluateExpression,
            ),
          ),
        ],
        child: child,
      ),
    );
  }
}

/// Extension to easily access calculator dependencies from BuildContext.
extension CalculatorDependencies on BuildContext {
  /// Gets the InsertParenthesisUseCase from the context.
  InsertParenthesisUseCase get insertParenthesisUseCase =>
      read<InsertParenthesisUseCase>();

  /// Gets the InsertOperatorUseCase from the context.
  InsertOperatorUseCase get insertOperatorUseCase =>
      read<InsertOperatorUseCase>();

  /// Gets the EvaluateExpressionUseCase from the context.
  EvaluateExpressionUseCase get evaluateExpressionUseCase =>
      read<EvaluateExpressionUseCase>();

  /// Gets the ExpressionDisplayBloc from the context.
  ExpressionDisplayBloc get expressionDisplayBloc =>
      read<ExpressionDisplayBloc>();
}
