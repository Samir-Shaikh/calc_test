import 'package:android_calculator_flutter/app/di/calculator_module.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_parenthesis_use_case.dart';
import 'package:flutter/material.dart';

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

  /// Optional custom EvaluateExpressionUseCase for testing.
  final EvaluateExpressionUseCase? evaluateExpressionUseCase;

  const TestApp({
    super.key,
    required this.child,
    this.insertParenthesisUseCase,
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
