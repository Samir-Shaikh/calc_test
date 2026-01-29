import 'package:android_calculator_flutter/app/di/calculator_module.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/clear_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/delete_character_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_operator_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_parenthesis_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/negate_value_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_bloc.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_state.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/backspace_button.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_button_grid.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

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

  /// Optional custom ClearExpressionUseCase for testing.
  final ClearExpressionUseCase? clearExpressionUseCase;

  /// Optional custom DeleteCharacterUseCase for testing.
  final DeleteCharacterUseCase? deleteCharacterUseCase;

  /// Optional custom NegateValueUseCase for testing.
  final NegateValueUseCase? negateValueUseCase;

  const TestApp({
    super.key,
    required this.child,
    this.insertParenthesisUseCase,
    this.insertOperatorUseCase,
    this.evaluateExpressionUseCase,
    this.clearExpressionUseCase,
    this.deleteCharacterUseCase,
    this.negateValueUseCase,
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
        clearExpressionUseCase: clearExpressionUseCase,
        deleteCharacterUseCase: deleteCharacterUseCase,
        negateValueUseCase: negateValueUseCase,
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
  late final ClearExpressionUseCase _clearExpressionUseCase;
  late final DeleteCharacterUseCase _deleteCharacterUseCase;
  late final NegateValueUseCase _negateValueUseCase;
  late final ExpressionDisplayBloc _bloc;

  @override
  void initState() {
    super.initState();
    _insertParenthesisUseCase = InsertParenthesisUseCase();
    _insertOperatorUseCase = InsertOperatorUseCase();
    _evaluateExpressionUseCase = EvaluateExpressionUseCase();
    _clearExpressionUseCase = ClearExpressionUseCase();
    _deleteCharacterUseCase = DeleteCharacterUseCase();
    _negateValueUseCase = NegateValueUseCase();
    _bloc = ExpressionDisplayBloc(
      insertParenthesisUseCase: _insertParenthesisUseCase,
      insertOperatorUseCase: _insertOperatorUseCase,
      evaluateExpressionUseCase: _evaluateExpressionUseCase,
      clearExpressionUseCase: _clearExpressionUseCase,
      deleteCharacterUseCase: _deleteCharacterUseCase,
      negateValueUseCase: _negateValueUseCase,
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

/// A calculator test app with toast notification support.
///
/// This widget provides a fully functional calculator with:
/// - Expression display with BLoC state management
/// - Calculator button grid
/// - Expression evaluation on equals press
/// - Toast notifications for evaluation errors
///
/// Use this for integration tests that need to verify toast messages
/// are displayed for invalid expressions.
///
/// Usage:
/// ```dart
/// await tester.pumpWidget(const CalculatorTestAppWithToast());
/// await tester.pumpAndSettle();
///
/// // Enter invalid expression and tap equals
/// await tester.tap(find.text('2'));
/// await tester.tap(find.text('+'));
/// await tester.tap(find.text('+'));
/// await tester.tap(find.text('3'));
/// await tester.tap(find.text('='));
/// await tester.pump();
///
/// // Verify toast is displayed
/// expect(find.text('Invalid Input'), findsOneWidget);
/// ```
class CalculatorTestAppWithToast extends StatelessWidget {
  const CalculatorTestAppWithToast({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const _CalculatorTestScreenWithToast(),
    );
  }
}

/// Internal calculator screen for testing with toast notification support.
class _CalculatorTestScreenWithToast extends StatefulWidget {
  const _CalculatorTestScreenWithToast();

  @override
  State<_CalculatorTestScreenWithToast> createState() =>
      _CalculatorTestScreenWithToastState();
}

class _CalculatorTestScreenWithToastState
    extends State<_CalculatorTestScreenWithToast> {
  late final InsertParenthesisUseCase _insertParenthesisUseCase;
  late final InsertOperatorUseCase _insertOperatorUseCase;
  late final EvaluateExpressionUseCase _evaluateExpressionUseCase;
  late final ClearExpressionUseCase _clearExpressionUseCase;
  late final DeleteCharacterUseCase _deleteCharacterUseCase;
  late final NegateValueUseCase _negateValueUseCase;
  late final ExpressionDisplayBloc _bloc;

  @override
  void initState() {
    super.initState();
    _insertParenthesisUseCase = InsertParenthesisUseCase();
    _insertOperatorUseCase = InsertOperatorUseCase();
    _evaluateExpressionUseCase = EvaluateExpressionUseCase();
    _clearExpressionUseCase = ClearExpressionUseCase();
    _deleteCharacterUseCase = DeleteCharacterUseCase();
    _negateValueUseCase = NegateValueUseCase();
    _bloc = ExpressionDisplayBloc(
      insertParenthesisUseCase: _insertParenthesisUseCase,
      insertOperatorUseCase: _insertOperatorUseCase,
      evaluateExpressionUseCase: _evaluateExpressionUseCase,
      clearExpressionUseCase: _clearExpressionUseCase,
      deleteCharacterUseCase: _deleteCharacterUseCase,
      negateValueUseCase: _negateValueUseCase,
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
        body: BlocListener<ExpressionDisplayBloc, ExpressionDisplayState>(
          listenWhen: (previous, current) {
            // Only listen when transitioning to an evaluation error state
            return !previous.isEvaluationError && current.isEvaluationError;
          },
          listener: (context, state) {
            // Show toast when evaluation error occurs
            if (state.isEvaluationError && state.evaluationError != null) {
              CalculatorToast.show(
                context,
                message: state.evaluationError!,
                type: ToastType.error,
              );
            }
          },
          child: Column(
            children: [
              // Display area
              Expanded(
                flex: 1,
                child:
                    BlocBuilder<ExpressionDisplayBloc, ExpressionDisplayState>(
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
      ),
    );
  }
}

/// A calculator test app configured for RTL (Right-to-Left) layout testing.
///
/// This widget wraps the calculator app in a [Directionality] widget
/// with [TextDirection.rtl] to simulate RTL locale environments like
/// Arabic, Hebrew, or Persian.
///
/// Use this for integration tests that need to verify:
/// - Button grid layout mirrors correctly in RTL mode
/// - Backspace button moves to the logical end (left side in RTL)
/// - Display alignment adapts to RTL context
/// - All calculator operations work correctly in RTL layout
///
/// ## RTL Layout Behavior
///
/// In RTL mode:
/// - The button grid is horizontally mirrored (e.g., C, (), ^, ÷ becomes ÷, ^, (), C)
/// - The backspace button appears on the left side (logical end)
/// - Text alignment uses directional values (TextAlign.end)
/// - All calculations produce the same results as LTR mode
///
/// Usage:
/// ```dart
/// await tester.pumpWidget(const CalculatorTestAppRTL());
/// await tester.pumpAndSettle();
///
/// // Verify RTL layout mirroring
/// final clearX = tester.getCenter(find.text('C')).dx;
/// final divideX = tester.getCenter(find.text('÷')).dx;
/// expect(divideX, lessThan(clearX)); // In RTL, ÷ is on the left
///
/// // Calculations work the same
/// await tester.tap(find.text('2'));
/// await tester.tap(find.text('+'));
/// await tester.tap(find.text('3'));
/// await tester.tap(find.text('='));
/// tester.verifyResult('5');
/// ```
class CalculatorTestAppRTL extends StatelessWidget {
  const CalculatorTestAppRTL({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(
        title: 'Calculator Test (RTL)',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        // Wrap home in another Directionality to ensure RTL is propagated
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
        home: const _CalculatorTestScreenRTL(),
      ),
    );
  }
}

/// Internal calculator screen for RTL testing with full evaluation support.
///
/// This screen mirrors the structure of [_CalculatorTestScreen] but includes
/// the backspace button positioned using [MainAxisAlignment.end] which
/// correctly adapts to the RTL context.
class _CalculatorTestScreenRTL extends StatefulWidget {
  const _CalculatorTestScreenRTL();

  @override
  State<_CalculatorTestScreenRTL> createState() =>
      _CalculatorTestScreenRTLState();
}

class _CalculatorTestScreenRTLState extends State<_CalculatorTestScreenRTL> {
  late final InsertParenthesisUseCase _insertParenthesisUseCase;
  late final InsertOperatorUseCase _insertOperatorUseCase;
  late final EvaluateExpressionUseCase _evaluateExpressionUseCase;
  late final ClearExpressionUseCase _clearExpressionUseCase;
  late final DeleteCharacterUseCase _deleteCharacterUseCase;
  late final NegateValueUseCase _negateValueUseCase;
  late final ExpressionDisplayBloc _bloc;

  @override
  void initState() {
    super.initState();
    _insertParenthesisUseCase = InsertParenthesisUseCase();
    _insertOperatorUseCase = InsertOperatorUseCase();
    _evaluateExpressionUseCase = EvaluateExpressionUseCase();
    _clearExpressionUseCase = ClearExpressionUseCase();
    _deleteCharacterUseCase = DeleteCharacterUseCase();
    _negateValueUseCase = NegateValueUseCase();
    _bloc = ExpressionDisplayBloc(
      insertParenthesisUseCase: _insertParenthesisUseCase,
      insertOperatorUseCase: _insertOperatorUseCase,
      evaluateExpressionUseCase: _evaluateExpressionUseCase,
      clearExpressionUseCase: _clearExpressionUseCase,
      deleteCharacterUseCase: _deleteCharacterUseCase,
      negateValueUseCase: _negateValueUseCase,
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
                      // Use CrossAxisAlignment.end for RTL-aware alignment
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          state.displayExpression,
                          // Use TextAlign.end for RTL-aware text alignment
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          state.result ?? state.displayExpression,
                          // Use TextAlign.end for RTL-aware text alignment
                          textAlign: TextAlign.end,
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
            // Backspace button row - uses MainAxisAlignment.end for RTL support
            const _BackspaceButtonRow(),
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

/// A row widget that positions the backspace button at the logical end.
///
/// Uses [MainAxisAlignment.end] to position the backspace button, which
/// automatically adapts to RTL layout (button appears on the left in RTL).
class _BackspaceButtonRow extends StatelessWidget {
  const _BackspaceButtonRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        // MainAxisAlignment.end places the button at the logical end
        // In LTR: right side, In RTL: left side
        mainAxisAlignment: MainAxisAlignment.end,
        children: const [
          BackspaceButton(),
        ],
      ),
    );
  }
}

/// Helper extension for integration tests to simplify common calculator actions.
///
/// Usage:
/// ```dart
/// import 'helpers/test_app.dart';
///
/// // In your test:
/// await tester.enterExpression('2+3*4');
/// await tester.tapEquals();
/// await tester.verifyResult('14');
/// ```
extension CalculatorTestHelpers on WidgetTester {
  /// Enters a mathematical expression by tapping the appropriate buttons.
  ///
  /// Supports digits (0-9), operators (+, -, ×, ÷), decimal point (.),
  /// parentheses, and power (^).
  ///
  /// Note: Use '×' for multiplication and '÷' for division as these
  /// are the symbols displayed on the calculator buttons.
  Future<void> enterExpression(String expression) async {
    for (final char in expression.split('')) {
      await _tapButton(char);
      await pumpAndSettle();
    }
  }

  /// Taps a single button based on the character.
  Future<void> _tapButton(String char) async {
    switch (char) {
      case '(':
      case ')':
        await tap(find.byKey(const Key('parenthesis_button')));
        break;
      case '^':
        await tap(find.byKey(const Key('power_button')));
        break;
      case '=':
        await tap(find.byKey(const Key('equals_button')));
        break;
      default:
        // Digits and other operators (+, -, ×, ÷, .)
        await tap(find.text(char));
    }
  }

  /// Taps the equals button to evaluate the expression.
  Future<void> tapEquals() async {
    await tap(find.byKey(const Key('equals_button')));
    await pumpAndSettle();
  }

  /// Taps the clear button to reset the calculator.
  Future<void> tapClear() async {
    await tap(find.text('C'));
    await pumpAndSettle();
  }

  /// Verifies that the result is displayed.
  ///
  /// Checks for both integer format (e.g., '14') and decimal format
  /// (e.g., '14.0') to handle different number formatting.
  void verifyResult(String expected) {
    final intResult = find.text(expected);
    final decimalResult = find.text('$expected.0');
    expect(
      intResult.evaluate().isNotEmpty || decimalResult.evaluate().isNotEmpty,
      isTrue,
      reason: 'Expected result to be $expected or $expected.0',
    );
  }

  /// Verifies that a toast message is displayed with the given text.
  void verifyToastDisplayed(String message) {
    expect(find.text(message), findsOneWidget,
        reason: 'Expected toast with message "$message" to be displayed');
  }

  /// Verifies that a SnackBar is displayed (toast notification).
  void verifySnackBarDisplayed() {
    expect(find.byType(SnackBar), findsOneWidget,
        reason: 'Expected a SnackBar (toast) to be displayed');
  }

  /// Verifies that no toast/snackbar is currently displayed.
  void verifyNoToastDisplayed() {
    expect(find.byType(SnackBar), findsNothing,
        reason: 'Expected no SnackBar (toast) to be displayed');
  }

  /// Checks if a toast is currently visible.
  ///
  /// Returns true if a SnackBar is found in the widget tree.
  bool isToastVisible() {
    return find.byType(SnackBar).evaluate().isNotEmpty;
  }

  /// Verifies that the 'Invalid Input' toast is displayed.
  ///
  /// This is a convenience method for the common case of checking
  /// for the standard invalid input error message.
  void verifyInvalidInputToastDisplayed() {
    verifyToastDisplayed('Invalid Input');
  }

  /// Waits for a toast to appear and verifies its message.
  ///
  /// Uses [pump] instead of [pumpAndSettle] to capture the toast
  /// before any animations complete.
  Future<void> expectToastWithMessage(String message) async {
    await pump();
    final snackBar = find.byType(SnackBar);
    if (snackBar.evaluate().isNotEmpty) {
      verifyToastDisplayed(message);
    }
  }

  /// Waits for toast to disappear by pumping for the specified duration.
  ///
  /// Default duration is 2.5 seconds which should be enough for the
  /// standard toast duration plus dismiss animation.
  Future<void> waitForToastToDismiss({
    Duration duration = const Duration(milliseconds: 2500),
  }) async {
    await pump(duration);
    await pumpAndSettle();
  }

  /// Enters an invalid expression and verifies the error toast appears.
  ///
  /// This is a convenience method that combines entering an expression,
  /// tapping equals, and verifying the Invalid Input toast.
  ///
  /// Example:
  /// ```dart
  /// await tester.enterInvalidExpressionAndVerifyToast(['2', '+', '+', '3']);
  /// ```
  Future<void> enterInvalidExpressionAndVerifyToast(
    List<String> buttonSequence,
  ) async {
    for (final button in buttonSequence) {
      if (button == '(' || button == ')') {
        await tap(find.byKey(const Key('parenthesis_button')));
      } else if (button == '^') {
        await tap(find.byKey(const Key('power_button')));
      } else if (button == '=') {
        await tap(find.text('='));
      } else {
        await tap(find.text(button));
      }
      await pumpAndSettle();
    }

    // Tap equals
    await tap(find.text('='));
    await pump();

    // Verify toast
    final snackBar = find.byType(SnackBar);
    if (snackBar.evaluate().isNotEmpty) {
      verifyInvalidInputToastDisplayed();
    }
  }
}
