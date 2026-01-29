import 'package:android_calculator_flutter/app/di/calculator_module.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_operator_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_parenthesis_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_bloc.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_state.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_button_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A test wrapper for integration tests that provides all necessary
/// dependencies for the calculator feature.
///
/// This widget sets up the CalculatorModule with optional mock/custom
/// use cases for testing purposes.
///
/// Usage:
/// ```dart
/// await tester.pumpWidget(
///   TestApp(
///     child: CalculatorScreen(),
///   ),
/// );
/// ```
class TestApp extends StatelessWidget {
  /// The child widget to be tested.
  final Widget child;

  /// Optional custom InsertParenthesisUseCase for testing.
  final InsertParenthesisUseCase? insertParenthesisUseCase;

  /// Optional custom InsertOperatorUseCase for testing.
  final InsertOperatorUseCase? insertOperatorUseCase;

  /// Optional custom EvaluateExpressionUseCase for testing.
  final EvaluateExpressionUseCase? evaluateExpressionUseCase;

  const TestApp({
    super.key,
    required this.child,
    this.insertParenthesisUseCase,
    this.insertOperatorUseCase,
    this.evaluateExpressionUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: CalculatorModule(
        insertParenthesisUseCase: insertParenthesisUseCase,
        insertOperatorUseCase: insertOperatorUseCase,
        evaluateExpressionUseCase: evaluateExpressionUseCase,
        child: child,
      ),
    );
  }
}

/// A simplified test app that wraps a widget with just MaterialApp.
///
/// Use this when you don't need the full CalculatorModule setup,
/// for example when testing individual widgets in isolation.
class SimpleTestApp extends StatelessWidget {
  /// The child widget to be tested.
  final Widget child;

  const SimpleTestApp({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: child,
    );
  }
}

/// A complete calculator test app that includes BLoC with evaluation support.
///
/// This widget provides a fully functional calculator with:
/// - Expression display with BLoC state management
/// - Calculator button grid
/// - Expression evaluation on equals press
///
/// Use this for integration tests that need the full calculator functionality
/// including parentheses and evaluation.
///
/// Usage:
/// ```dart
/// await tester.pumpWidget(const CalculatorTestApp());
/// await tester.pumpAndSettle();
///
/// // Tap buttons and verify results
/// await tester.tap(find.text('2'));
/// await tester.tap(find.text('+'));
/// await tester.tap(find.text('3'));
/// await tester.tap(find.text('='));
/// expect(find.text('5'), findsOneWidget);
/// ```
class CalculatorTestApp extends StatelessWidget {
  const CalculatorTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const _CalculatorTestScreen(),
    );
  }
}

/// Internal calculator screen for testing with full evaluation support.
class _CalculatorTestScreen extends StatefulWidget {
  const _CalculatorTestScreen();

  @override
  State<_CalculatorTestScreen> createState() => _CalculatorTestScreenState();
}

class _CalculatorTestScreenState extends State<_CalculatorTestScreen> {
  late final InsertParenthesisUseCase _insertParenthesisUseCase;
  late final InsertOperatorUseCase _insertOperatorUseCase;
  late final EvaluateExpressionUseCase _evaluateExpressionUseCase;
  late final ExpressionDisplayBloc _bloc;

  @override
  void initState() {
    super.initState();
    _insertParenthesisUseCase = InsertParenthesisUseCase();
    _insertOperatorUseCase = InsertOperatorUseCase();
    _evaluateExpressionUseCase = EvaluateExpressionUseCase();
    _bloc = ExpressionDisplayBloc(
      insertParenthesisUseCase: _insertParenthesisUseCase,
      insertOperatorUseCase: _insertOperatorUseCase,
      evaluateExpressionUseCase: _evaluateExpressionUseCase,
    );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExpressionDisplayBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Calculator'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Column(
          children: [
            // Display area
            Expanded(
              flex: 1,
              child: BlocBuilder<ExpressionDisplayBloc, ExpressionDisplayState>(
                builder: (context, state) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          state.displayExpression,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          state.result ?? state.displayExpression,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Button area
            const Expanded(
              flex: 2,
              child: CalculatorButtonGrid(),
            ),
          ],
        ),
      ),
    );
  }
}
