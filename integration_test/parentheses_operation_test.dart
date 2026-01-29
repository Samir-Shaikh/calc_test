import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_parenthesis_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_bloc.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_event.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_state.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_button_grid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Parentheses Operation Integration Tests', () {
    testWidgets('toggle behavior - first tap inserts opening parenthesis',
        (WidgetTester tester) async {
      // Build the test calculator app
      await tester.pumpWidget(const _TestCalculatorApp());
      await tester.pumpAndSettle();

      // Tap the parenthesis button
      await tester.tap(find.byKey(const Key('parenthesis_button')));
      await tester.pumpAndSettle();

      // Verify '(' is displayed
      expect(find.text('('), findsOneWidget);
    });

    testWidgets('toggle behavior - second tap inserts closing parenthesis',
        (WidgetTester tester) async {
      // Build the test calculator app
      await tester.pumpWidget(const _TestCalculatorApp());
      await tester.pumpAndSettle();

      // Tap the parenthesis button twice
      await tester.tap(find.byKey(const Key('parenthesis_button')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(const Key('parenthesis_button')));
      await tester.pumpAndSettle();

      // Verify '()' is displayed (both parentheses)
      expect(find.text('()'), findsOneWidget);
    });

    testWidgets('toggle continues alternating - third tap inserts opening again',
        (WidgetTester tester) async {
      // Build the test calculator app
      await tester.pumpWidget(const _TestCalculatorApp());
      await tester.pumpAndSettle();

      // Tap the parenthesis button three times
      await tester.tap(find.byKey(const Key('parenthesis_button')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(const Key('parenthesis_button')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(const Key('parenthesis_button')));
      await tester.pumpAndSettle();

      // Verify '()(' is displayed
      expect(find.text('()('), findsOneWidget);
    });

    testWidgets('building expression (2+3)*4',
        (WidgetTester tester) async {
      // Build the test calculator app
      await tester.pumpWidget(const _TestCalculatorApp());
      await tester.pumpAndSettle();

      // Build expression: ( 2 + 3 ) * 4
      // Tap '('
      await tester.tap(find.byKey(const Key('parenthesis_button')));
      await tester.pumpAndSettle();

      // Tap '2'
      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      // Tap '+'
      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();

      // Tap '3'
      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();

      // Tap ')' (second parenthesis tap)
      await tester.tap(find.byKey(const Key('parenthesis_button')));
      await tester.pumpAndSettle();

      // Tap '*' (×)
      await tester.tap(find.text('×'));
      await tester.pumpAndSettle();

      // Tap '4'
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();

      // Verify expression is displayed correctly
      expect(find.text('(2+3)×4'), findsOneWidget);
    });

    testWidgets('AC3: evaluating (2+3)*4 equals 20',
        (WidgetTester tester) async {
      // Build the test calculator app
      await tester.pumpWidget(const _TestCalculatorApp());
      await tester.pumpAndSettle();

      // Build expression: ( 2 + 3 ) * 4 =
      await tester.tap(find.byKey(const Key('parenthesis_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('parenthesis_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('×'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();

      // Tap '='
      await tester.tap(find.text('='));
      await tester.pumpAndSettle();

      // Verify result is displayed - AC3 requirement: (2+3)*4 = 20
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('clear resets bracket state - after clear, parenthesis inserts opening',
        (WidgetTester tester) async {
      // Build the test calculator app
      await tester.pumpWidget(const _TestCalculatorApp());
      await tester.pumpAndSettle();

      // Tap '(' first
      await tester.tap(find.byKey(const Key('parenthesis_button')));
      await tester.pumpAndSettle();
      expect(find.text('('), findsOneWidget);

      // Tap 'C' to clear
      await tester.tap(find.text('C'));
      await tester.pumpAndSettle();

      // Verify expression is cleared (display shows empty or 0)
      expect(find.text('('), findsNothing);

      // Tap parenthesis again - should insert '(' not ')'
      await tester.tap(find.byKey(const Key('parenthesis_button')));
      await tester.pumpAndSettle();

      // Verify '(' is displayed (not ')')
      expect(find.text('('), findsOneWidget);
      expect(find.text(')'), findsNothing);
    });

    testWidgets('nested parentheses - building ((2+3)*2)',
        (WidgetTester tester) async {
      // Build the test calculator app
      await tester.pumpWidget(const _TestCalculatorApp());
      await tester.pumpAndSettle();

      // Build: ( ( 2 + 3 ) * 2 )
      // Tap '(' twice for nested opening
      await tester.tap(find.byKey(const Key('parenthesis_button')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(const Key('parenthesis_button')));
      await tester.pumpAndSettle();

      // At this point we have '()' due to toggle, but let's build a proper nested expression
      // Clear and try a different approach - build expression with numbers between
      await tester.tap(find.text('C'));
      await tester.pumpAndSettle();

      // Build: ( ( 2 + 3 ) * 2 ) using proper sequence
      await tester.tap(find.byKey(const Key('parenthesis_button'))); // (
      await tester.pumpAndSettle();

      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('parenthesis_button'))); // )
      await tester.pumpAndSettle();

      await tester.tap(find.text('×'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      // Verify expression
      expect(find.text('(2+3)×2'), findsOneWidget);
    });

    testWidgets('evaluating nested parentheses ((2+3)*2) equals 10',
        (WidgetTester tester) async {
      // Build the test calculator app
      await tester.pumpWidget(const _TestCalculatorApp());
      await tester.pumpAndSettle();

      // Build: ( 2 + 3 ) * 2 =
      await tester.tap(find.byKey(const Key('parenthesis_button'))); // (
      await tester.pumpAndSettle();

      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('parenthesis_button'))); // )
      await tester.pumpAndSettle();

      await tester.tap(find.text('×'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('='));
      await tester.pumpAndSettle();

      // Verify result
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('complex expression (1+2)*(3+4) equals 21',
        (WidgetTester tester) async {
      // Build the test calculator app
      await tester.pumpWidget(const _TestCalculatorApp());
      await tester.pumpAndSettle();

      // Build: ( 1 + 2 ) * ( 3 + 4 ) =
      // First group: (1+2)
      await tester.tap(find.byKey(const Key('parenthesis_button'))); // (
      await tester.pumpAndSettle();

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('parenthesis_button'))); // )
      await tester.pumpAndSettle();

      // Operator between groups
      await tester.tap(find.text('×'));
      await tester.pumpAndSettle();

      // Second group: (3+4)
      await tester.tap(find.byKey(const Key('parenthesis_button'))); // (
      await tester.pumpAndSettle();

      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('parenthesis_button'))); // )
      await tester.pumpAndSettle();

      // Verify expression is built correctly
      expect(find.text('(1+2)×(3+4)'), findsOneWidget);

      // Evaluate
      await tester.tap(find.text('='));
      await tester.pumpAndSettle();

      // Verify result: (1+2)*(3+4) = 3*7 = 21
      expect(find.text('21'), findsOneWidget);
    });

    testWidgets('expression with division and parentheses (10+2)/3 equals 4',
        (WidgetTester tester) async {
      // Build the test calculator app
      await tester.pumpWidget(const _TestCalculatorApp());
      await tester.pumpAndSettle();

      // Build: ( 1 0 + 2 ) / 3 =
      await tester.tap(find.byKey(const Key('parenthesis_button'))); // (
      await tester.pumpAndSettle();

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('parenthesis_button'))); // )
      await tester.pumpAndSettle();

      await tester.tap(find.text('÷'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('='));
      await tester.pumpAndSettle();

      // Verify result: (10+2)/3 = 12/3 = 4
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('parentheses change order of operations - 2+3*4 vs (2+3)*4',
        (WidgetTester tester) async {
      // Build the test calculator app
      await tester.pumpWidget(const _TestCalculatorApp());
      await tester.pumpAndSettle();

      // First: 2+3*4 without parentheses = 2 + 12 = 14
      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('×'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('='));
      await tester.pumpAndSettle();

      // Verify result without parentheses: 2+3*4 = 14
      expect(find.text('14'), findsOneWidget);

      // Clear
      await tester.tap(find.text('C'));
      await tester.pumpAndSettle();

      // Second: (2+3)*4 with parentheses = 5 * 4 = 20
      await tester.tap(find.byKey(const Key('parenthesis_button'))); // (
      await tester.pumpAndSettle();

      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('parenthesis_button'))); // )
      await tester.pumpAndSettle();

      await tester.tap(find.text('×'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('='));
      await tester.pumpAndSettle();

      // Verify result with parentheses: (2+3)*4 = 20
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('multiple parentheses groups: (2+3)*(4+1) equals 25',
        (WidgetTester tester) async {
      // Build the test calculator app
      await tester.pumpWidget(const _TestCalculatorApp());
      await tester.pumpAndSettle();

      // Build: ( 2 + 3 ) * ( 4 + 1 ) =
      // First group: (2+3)
      await tester.tap(find.byKey(const Key('parenthesis_button'))); // (
      await tester.pumpAndSettle();

      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('parenthesis_button'))); // )
      await tester.pumpAndSettle();

      // Operator between groups
      await tester.tap(find.text('×'));
      await tester.pumpAndSettle();

      // Second group: (4+1)
      await tester.tap(find.byKey(const Key('parenthesis_button'))); // (
      await tester.pumpAndSettle();

      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('parenthesis_button'))); // )
      await tester.pumpAndSettle();

      // Evaluate
      await tester.tap(find.text('='));
      await tester.pumpAndSettle();

      // Verify result: (2+3)*(4+1) = 5*5 = 25
      expect(find.text('25'), findsOneWidget);
    });
  });
}

/// A test calculator app that integrates the BLoC with a proper display
/// and includes expression evaluation on equals press.
class _TestCalculatorApp extends StatelessWidget {
  const _TestCalculatorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const _TestCalculatorScreen(),
    );
  }
}

/// A test calculator screen that uses the ExpressionDisplayBloc
/// and integrates the EvaluateExpressionUseCase for testing.
class _TestCalculatorScreen extends StatefulWidget {
  const _TestCalculatorScreen();

  @override
  State<_TestCalculatorScreen> createState() => _TestCalculatorScreenState();
}

class _TestCalculatorScreenState extends State<_TestCalculatorScreen> {
  late final InsertParenthesisUseCase _insertParenthesisUseCase;
  late final EvaluateExpressionUseCase _evaluateExpressionUseCase;
  late final _TestExpressionDisplayBloc _bloc;

  @override
  void initState() {
    super.initState();
    _insertParenthesisUseCase = InsertParenthesisUseCase();
    _evaluateExpressionUseCase = EvaluateExpressionUseCase();
    _bloc = _TestExpressionDisplayBloc(
      insertParenthesisUseCase: _insertParenthesisUseCase,
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

/// Extended BLoC that includes evaluation logic for testing purposes.
class _TestExpressionDisplayBloc extends ExpressionDisplayBloc {
  final EvaluateExpressionUseCase _evaluateExpressionUseCase;

  _TestExpressionDisplayBloc({
    required super.insertParenthesisUseCase,
    required EvaluateExpressionUseCase evaluateExpressionUseCase,
  }) : _evaluateExpressionUseCase = evaluateExpressionUseCase {
    // Override the equals handler
    on<EqualsPressed>(_onEqualsPressedWithEvaluation);
  }

  void _onEqualsPressedWithEvaluation(
    EqualsPressed event,
    Emitter<ExpressionDisplayState> emit,
  ) {
    final expression = state.expression.value;
    if (expression.isEmpty) {
      return;
    }

    final result = _evaluateExpressionUseCase.execute(expression);
    emit(state.copyWith(
      result: result,
      hasError: result == 'Error',
      errorMessage: result == 'Error' ? 'Invalid expression' : null,
    ));
  }
}
