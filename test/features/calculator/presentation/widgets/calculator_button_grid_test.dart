import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_operator_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_parenthesis_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_bloc.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_button_grid.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/parenthesis_button_config.dart';

void main() {
  late InsertParenthesisUseCase insertParenthesisUseCase;
  late InsertOperatorUseCase insertOperatorUseCase;
  late EvaluateExpressionUseCase evaluateExpressionUseCase;
  late ExpressionDisplayBloc bloc;

  setUp(() {
    insertParenthesisUseCase = InsertParenthesisUseCase();
    insertOperatorUseCase = InsertOperatorUseCase();
    evaluateExpressionUseCase = EvaluateExpressionUseCase();
    bloc = ExpressionDisplayBloc(
      insertParenthesisUseCase: insertParenthesisUseCase,
      insertOperatorUseCase: insertOperatorUseCase,
      evaluateExpressionUseCase: evaluateExpressionUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<ExpressionDisplayBloc>.value(
          value: bloc,
          child: const CalculatorButtonGrid(),
        ),
      ),
    );
  }

  group('CalculatorButtonGrid', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CalculatorButtonGrid), findsOneWidget);
    });

    testWidgets('displays all digit buttons (0-9)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      for (var i = 0; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('displays operator buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('+'), findsOneWidget);
      expect(find.text('-'), findsOneWidget);
      expect(find.text('×'), findsOneWidget);
      expect(find.text('÷'), findsOneWidget);
    });

    testWidgets('displays function buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('C'), findsOneWidget);
      expect(find.text('%'), findsOneWidget);
      expect(find.text('⌫'), findsOneWidget);
      expect(find.text('='), findsOneWidget);
    });

    testWidgets('displays decimal button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('.'), findsOneWidget);
    });
  });

  group('Parenthesis Button', () {
    testWidgets('displays parenthesis button with correct label', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text(ParenthesisButtonConfig.label), findsOneWidget);
      expect(find.text('()'), findsOneWidget);
    });

    testWidgets('parenthesis button has correct key', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byKey(const Key('parenthesis_button')), findsOneWidget);
    });

    testWidgets('parenthesis button is positioned in first row', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find the parenthesis button
      final parenthesisButton = find.byKey(const Key('parenthesis_button'));
      expect(parenthesisButton, findsOneWidget);

      // Verify it exists alongside other first-row buttons
      expect(find.text('C'), findsOneWidget);
      expect(find.text('%'), findsOneWidget);
      expect(find.text('÷'), findsOneWidget);
    });

    testWidgets('tapping parenthesis button dispatches ParenthesisPressed event', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initial state should be empty expression
      expect(bloc.state.expression.value, isEmpty);

      // Tap the parenthesis button
      await tester.tap(find.byKey(const Key('parenthesis_button')));
      await tester.pump();

      // After tapping, expression should contain '('
      expect(bloc.state.expression.value, equals('('));
    });

    testWidgets('tapping parenthesis button twice inserts both parentheses', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap twice
      await tester.tap(find.byKey(const Key('parenthesis_button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('parenthesis_button')));
      await tester.pump();

      // Should have '()'
      expect(bloc.state.expression.value, equals('()'));
    });

    testWidgets('parenthesis button uses gray background color', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final parenthesisButtonFinder = find.byKey(const Key('parenthesis_button'));
      expect(parenthesisButtonFinder, findsOneWidget);

      // Verify the button's decoration uses the correct background color
      final container = tester.widget<Container>(
        find.descendant(
          of: parenthesisButtonFinder,
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(ParenthesisButtonConfig.backgroundColor));
    });
  });

  group('Button interactions', () {
    testWidgets('tapping digit buttons updates expression', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('5'));
      await tester.pump();

      expect(bloc.state.expression.value, equals('5'));
    });

    testWidgets('tapping clear button resets expression', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Add some digits
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();

      expect(bloc.state.expression.value, equals('53'));

      // Clear
      await tester.tap(find.text('C'));
      await tester.pump();

      expect(bloc.state.expression.value, isEmpty);
    });

    testWidgets('combining digits, operators, and parentheses', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Build expression: (5+3)
      await tester.tap(find.byKey(const Key('parenthesis_button'))); // (
      await tester.pump();
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('+'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.byKey(const Key('parenthesis_button'))); // )
      await tester.pump();

      expect(bloc.state.expression.value, equals('(5+3)'));
    });
  });
}
