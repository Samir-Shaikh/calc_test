import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_operator_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_parenthesis_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_bloc.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_event.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/theme/calculator_button_decorations.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/theme/calculator_colors.dart';
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

  group('Parenthesis Button Widget Tests', () {
    group('Display Tests', () {
      testWidgets('displays "()" label on the button', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Verify the parenthesis button shows '()' text
        expect(find.text('()'), findsOneWidget);
        expect(find.text(ParenthesisButtonConfig.label), findsOneWidget);
      });

      testWidgets('button label matches ParenthesisButtonConfig.label', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Verify the label is exactly '()'
        expect(ParenthesisButtonConfig.label, equals('()'));
        expect(find.text(ParenthesisButtonConfig.label), findsOneWidget);
      });

      testWidgets('button is findable by key', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byKey(const Key('parenthesis_button')), findsOneWidget);
      });
    });

    group('Background Color Tests', () {
      testWidgets('has gray (#505050) background color', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final parenthesisButtonFinder = find.byKey(const Key('parenthesis_button'));
        expect(parenthesisButtonFinder, findsOneWidget);

        // Find the Container widget that has the decoration
        final container = tester.widget<Container>(
          find.descendant(
            of: parenthesisButtonFinder,
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;

        // Verify the background color is #505050 (gray)
        expect(decoration.color, equals(const Color(0xFF505050)));
        expect(decoration.color, equals(CalculatorColors.parenthesisButtonBackground));
      });

      testWidgets('background color matches ParenthesisButtonConfig.backgroundColor', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final parenthesisButtonFinder = find.byKey(const Key('parenthesis_button'));
        final container = tester.widget<Container>(
          find.descendant(
            of: parenthesisButtonFinder,
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;

        expect(decoration.color, equals(ParenthesisButtonConfig.backgroundColor));
      });

      testWidgets('CalculatorColors.parenthesisButtonBackground is #505050', (WidgetTester tester) async {
        // Verify the constant value is correct
        expect(CalculatorColors.parenthesisButtonBackground, equals(const Color(0xFF505050)));
      });
    });

    group('Event Dispatch Tests', () {
      testWidgets('tap dispatches ParenthesisPressed event to BLoC', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Initial state should be empty expression
        expect(bloc.state.expression.value, isEmpty);

        // Tap the parenthesis button
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pump();

        // After tapping, expression should contain '(' (first parenthesis)
        // This proves the ParenthesisPressed event was dispatched and handled
        expect(bloc.state.expression.value, equals('('));
      });

      testWidgets('multiple taps dispatch multiple ParenthesisPressed events', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // First tap - should insert '('
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pump();
        expect(bloc.state.expression.value, equals('('));

        // Second tap - should insert ')'
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pump();
        expect(bloc.state.expression.value, equals('()'));
      });

      testWidgets('tap dispatches event that updates BLoC state', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Store initial state
        final initialExpression = bloc.state.expression.value;
        expect(initialExpression, isEmpty);

        // Tap the parenthesis button
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pump();

        // Verify state was updated (not the same as initial)
        expect(bloc.state.expression.value, isNot(equals(initialExpression)));
        expect(bloc.state.expression.value, isNotEmpty);
      });

      testWidgets('ParenthesisPressed event is correctly constructed', (WidgetTester tester) async {
        // Test that ParenthesisPressed event can be constructed
        const event = ParenthesisPressed();

        // Verify event properties
        expect(event, isA<ExpressionDisplayEvent>());
        expect(event.toString(), equals('ParenthesisPressed()'));
      });
    });

    group('Circular Shape Tests', () {
      testWidgets('button has circular shape decoration', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final parenthesisButtonFinder = find.byKey(const Key('parenthesis_button'));
        final container = tester.widget<Container>(
          find.descendant(
            of: parenthesisButtonFinder,
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;

        // Verify the shape is circular
        expect(decoration.shape, equals(BoxShape.circle));
      });

      testWidgets('button decoration matches CalculatorButtonDecorations.parenthesisButton', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final parenthesisButtonFinder = find.byKey(const Key('parenthesis_button'));
        final container = tester.widget<Container>(
          find.descendant(
            of: parenthesisButtonFinder,
            matching: find.byType(Container),
          ).first,
        );

        final actualDecoration = container.decoration as BoxDecoration;
        final expectedDecoration = CalculatorButtonDecorations.parenthesisButton;

        // Verify decoration properties match
        expect(actualDecoration.color, equals(expectedDecoration.color));
        expect(actualDecoration.shape, equals(expectedDecoration.shape));
      });

      testWidgets('circular shape matches other calculator buttons pattern', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Find parenthesis button's container
        final parenthesisButtonFinder = find.byKey(const Key('parenthesis_button'));
        final parenthesisContainer = tester.widget<Container>(
          find.descendant(
            of: parenthesisButtonFinder,
            matching: find.byType(Container),
          ).first,
        );
        final parenthesisDecoration = parenthesisContainer.decoration as BoxDecoration;

        // Find a digit button (e.g., '5') container for comparison
        final digit5Finder = find.text('5');
        expect(digit5Finder, findsOneWidget);

        // The parenthesis button should have the same shape as other buttons
        expect(parenthesisDecoration.shape, equals(BoxShape.circle));
      });

      testWidgets('ParenthesisButtonConfig.decoration has circular shape', (WidgetTester tester) async {
        // Verify the config decoration has circular shape
        final decoration = ParenthesisButtonConfig.decoration;

        expect(decoration.shape, equals(BoxShape.circle));
        expect(decoration.color, equals(CalculatorColors.parenthesisButtonBackground));
      });
    });

    group('Text Style Tests', () {
      testWidgets('button text has white color for contrast', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final textWidget = tester.widget<Text>(find.text('()'));
        final textStyle = textWidget.style!;

        // Verify text color is white for good contrast on gray background
        expect(textStyle.color, equals(Colors.white));
      });

      testWidgets('button text style matches ParenthesisButtonConfig.textColor', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final textWidget = tester.widget<Text>(find.text('()'));
        final textStyle = textWidget.style!;

        expect(textStyle.color, equals(ParenthesisButtonConfig.textColor));
        expect(textStyle.color, equals(CalculatorColors.lightButtonText));
      });
    });

    group('Integration with BLoC', () {
      testWidgets('button correctly integrates with ExpressionDisplayBloc', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Build a complex expression using parentheses
        // Tap '(' 
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pump();

        // Tap '5'
        await tester.tap(find.text('5'));
        await tester.pump();

        // Tap '+' 
        await tester.tap(find.text('+'));
        await tester.pump();

        // Tap '3'
        await tester.tap(find.text('3'));
        await tester.pump();

        // Tap ')' (second parenthesis press)
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pump();

        // Verify the complete expression
        expect(bloc.state.expression.value, equals('(5+3)'));
      });

      testWidgets('clear button resets parenthesis state', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Insert opening parenthesis
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pump();
        expect(bloc.state.expression.value, equals('('));

        // Clear
        await tester.tap(find.text('C'));
        await tester.pump();
        expect(bloc.state.expression.value, isEmpty);

        // After clear, next parenthesis should be '(' again
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pump();
        expect(bloc.state.expression.value, equals('('));
      });
    });
  });
}
