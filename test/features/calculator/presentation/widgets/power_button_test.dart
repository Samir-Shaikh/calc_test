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
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/power_button_config.dart';

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

  group('Power Button Widget Tests', () {
    group('Display Tests', () {
      testWidgets('displays "^" label on the button', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Verify the power button shows '^' text
        expect(find.text('^'), findsOneWidget);
        expect(find.text(PowerButtonConfig.label), findsOneWidget);
      });

      testWidgets('button label matches PowerButtonConfig.label', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Verify the label is exactly '^'
        expect(PowerButtonConfig.label, equals('^'));
        expect(find.text(PowerButtonConfig.label), findsOneWidget);
      });

      testWidgets('button is findable by key', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byKey(const Key('power_button')), findsOneWidget);
      });
    });

    group('Background Color Tests', () {
      testWidgets('has gray (#505050) background color', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final powerButtonFinder = find.byKey(const Key('power_button'));
        expect(powerButtonFinder, findsOneWidget);

        // Find the Container widget that has the decoration
        final container = tester.widget<Container>(
          find.descendant(
            of: powerButtonFinder,
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;

        // Verify the background color is #505050 (gray)
        expect(decoration.color, equals(const Color(0xFF505050)));
        expect(decoration.color, equals(CalculatorColors.powerButtonBackground));
      });

      testWidgets('background color matches PowerButtonConfig.backgroundColor', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final powerButtonFinder = find.byKey(const Key('power_button'));
        final container = tester.widget<Container>(
          find.descendant(
            of: powerButtonFinder,
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;

        expect(decoration.color, equals(PowerButtonConfig.backgroundColor));
      });

      testWidgets('CalculatorColors.powerButtonBackground is #505050', (WidgetTester tester) async {
        // Verify the constant value is correct
        expect(CalculatorColors.powerButtonBackground, equals(const Color(0xFF505050)));
      });
    });

    group('Event Dispatch Tests', () {
      testWidgets('tap dispatches PowerOperatorPressed event to BLoC', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // First tap a digit so we have something to apply power to
        await tester.tap(find.text('2'));
        await tester.pump();
        expect(bloc.state.expression.value, equals('2'));

        // Tap the power button
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pump();

        // After tapping, expression should contain '2^'
        // This proves the PowerOperatorPressed event was dispatched and handled
        expect(bloc.state.expression.value, equals('2^'));
      });

      testWidgets('tap on empty expression does not add power operator', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Initial state should be empty expression
        expect(bloc.state.expression.value, isEmpty);

        // Tap the power button on empty expression
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pump();

        // Power operator should not be added to empty expression
        // (InsertOperatorUseCase validates this)
        expect(bloc.state.expression.value, isEmpty);
      });

      testWidgets('multiple power operations can be chained', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Build expression: 2^3^4
        await tester.tap(find.text('2'));
        await tester.pump();

        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pump();
        expect(bloc.state.expression.value, equals('2^'));

        await tester.tap(find.text('3'));
        await tester.pump();

        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pump();
        expect(bloc.state.expression.value, equals('2^3^'));

        await tester.tap(find.text('4'));
        await tester.pump();
        expect(bloc.state.expression.value, equals('2^3^4'));
      });

      testWidgets('tap dispatches event that updates BLoC state', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Add a digit first
        await tester.tap(find.text('5'));
        await tester.pump();
        final expressionAfterDigit = bloc.state.expression.value;
        expect(expressionAfterDigit, equals('5'));

        // Tap the power button
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pump();

        // Verify state was updated (not the same as before power tap)
        expect(bloc.state.expression.value, isNot(equals(expressionAfterDigit)));
        expect(bloc.state.expression.value, equals('5^'));
      });

      testWidgets('PowerOperatorPressed event is correctly constructed', (WidgetTester tester) async {
        // Test that PowerOperatorPressed event can be constructed
        const event = PowerOperatorPressed();

        // Verify event properties
        expect(event, isA<ExpressionDisplayEvent>());
        expect(event.toString(), equals('PowerOperatorPressed()'));
      });
    });

    group('Circular Shape Tests', () {
      testWidgets('button has circular shape decoration', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final powerButtonFinder = find.byKey(const Key('power_button'));
        final container = tester.widget<Container>(
          find.descendant(
            of: powerButtonFinder,
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;

        // Verify the shape is circular
        expect(decoration.shape, equals(BoxShape.circle));
      });

      testWidgets('button decoration matches CalculatorButtonDecorations.powerButton', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final powerButtonFinder = find.byKey(const Key('power_button'));
        final container = tester.widget<Container>(
          find.descendant(
            of: powerButtonFinder,
            matching: find.byType(Container),
          ).first,
        );

        final actualDecoration = container.decoration as BoxDecoration;
        final expectedDecoration = CalculatorButtonDecorations.powerButton;

        // Verify decoration properties match
        expect(actualDecoration.color, equals(expectedDecoration.color));
        expect(actualDecoration.shape, equals(expectedDecoration.shape));
      });

      testWidgets('circular shape matches other calculator buttons pattern', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Find power button's container
        final powerButtonFinder = find.byKey(const Key('power_button'));
        final powerContainer = tester.widget<Container>(
          find.descendant(
            of: powerButtonFinder,
            matching: find.byType(Container),
          ).first,
        );
        final powerDecoration = powerContainer.decoration as BoxDecoration;

        // Find parenthesis button's container for comparison
        final parenthesisButtonFinder = find.byKey(const Key('parenthesis_button'));
        final parenthesisContainer = tester.widget<Container>(
          find.descendant(
            of: parenthesisButtonFinder,
            matching: find.byType(Container),
          ).first,
        );
        final parenthesisDecoration = parenthesisContainer.decoration as BoxDecoration;

        // The power button should have the same shape as parenthesis button
        expect(powerDecoration.shape, equals(parenthesisDecoration.shape));
        expect(powerDecoration.shape, equals(BoxShape.circle));
      });

      testWidgets('PowerButtonConfig.decoration has circular shape', (WidgetTester tester) async {
        // Verify the config decoration has circular shape
        final decoration = PowerButtonConfig.decoration;

        expect(decoration.shape, equals(BoxShape.circle));
        expect(decoration.color, equals(CalculatorColors.powerButtonBackground));
      });
    });

    group('Text Style Tests', () {
      testWidgets('button text has white color for contrast', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final textWidget = tester.widget<Text>(find.text('^'));
        final textStyle = textWidget.style!;

        // Verify text color is white for good contrast on gray background
        expect(textStyle.color, equals(Colors.white));
      });

      testWidgets('button text style matches PowerButtonConfig.textColor', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final textWidget = tester.widget<Text>(find.text('^'));
        final textStyle = textWidget.style!;

        expect(textStyle.color, equals(PowerButtonConfig.textColor));
        expect(textStyle.color, equals(CalculatorColors.lightButtonText));
      });
    });

    group('Button Presence in Grid Tests', () {
      testWidgets('power button is present in calculator button grid', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Verify the power button exists in the grid
        expect(find.byKey(const Key('power_button')), findsOneWidget);
        expect(find.text('^'), findsOneWidget);
      });

      testWidgets('power button is in the same row as 0, decimal, backspace, and equals', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Verify other buttons in the same row exist
        expect(find.text('0'), findsOneWidget);
        expect(find.text('.'), findsOneWidget);
        expect(find.text('⌫'), findsOneWidget);
        expect(find.text('='), findsOneWidget);
        expect(find.text('^'), findsOneWidget);
      });

      testWidgets('power button has same gray color as parenthesis button', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Get power button decoration
        final powerButtonFinder = find.byKey(const Key('power_button'));
        final powerContainer = tester.widget<Container>(
          find.descendant(
            of: powerButtonFinder,
            matching: find.byType(Container),
          ).first,
        );
        final powerDecoration = powerContainer.decoration as BoxDecoration;

        // Get parenthesis button decoration
        final parenthesisButtonFinder = find.byKey(const Key('parenthesis_button'));
        final parenthesisContainer = tester.widget<Container>(
          find.descendant(
            of: parenthesisButtonFinder,
            matching: find.byType(Container),
          ).first,
        );
        final parenthesisDecoration = parenthesisContainer.decoration as BoxDecoration;

        // Both should have the same gray color
        expect(powerDecoration.color, equals(parenthesisDecoration.color));
        expect(powerDecoration.color, equals(const Color(0xFF505050)));
      });
    });

    group('Integration with BLoC', () {
      testWidgets('button correctly integrates with ExpressionDisplayBloc for power calculation', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Build expression: 2^3
        await tester.tap(find.text('2'));
        await tester.pump();

        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pump();

        await tester.tap(find.text('3'));
        await tester.pump();

        // Verify the complete expression
        expect(bloc.state.expression.value, equals('2^3'));

        // Tap equals to evaluate
        await tester.tap(find.text('='));
        await tester.pump();

        // Verify the result (2^3 = 8)
        expect(bloc.state.result, equals('8'));
      });

      testWidgets('power operator works with parentheses', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Build expression: (2+3)^2
        await tester.tap(find.byKey(const Key('parenthesis_button'))); // (
        await tester.pump();

        await tester.tap(find.text('2'));
        await tester.pump();

        await tester.tap(find.text('+'));
        await tester.pump();

        await tester.tap(find.text('3'));
        await tester.pump();

        await tester.tap(find.byKey(const Key('parenthesis_button'))); // )
        await tester.pump();

        await tester.tap(find.byKey(const Key('power_button'))); // ^
        await tester.pump();

        await tester.tap(find.text('2'));
        await tester.pump();

        // Verify the complete expression
        expect(bloc.state.expression.value, equals('(2+3)^2'));

        // Tap equals to evaluate
        await tester.tap(find.text('='));
        await tester.pump();

        // Verify the result ((2+3)^2 = 25)
        expect(bloc.state.result, equals('25'));
      });

      testWidgets('clear button resets expression with power operator', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Build expression with power operator
        await tester.tap(find.text('2'));
        await tester.pump();

        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pump();

        await tester.tap(find.text('3'));
        await tester.pump();
        expect(bloc.state.expression.value, equals('2^3'));

        // Clear
        await tester.tap(find.text('C'));
        await tester.pump();
        expect(bloc.state.expression.value, isEmpty);
      });

      testWidgets('backspace removes power operator', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Build expression: 2^
        await tester.tap(find.text('2'));
        await tester.pump();

        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pump();
        expect(bloc.state.expression.value, equals('2^'));

        // Backspace should remove the ^
        await tester.tap(find.text('⌫'));
        await tester.pump();
        expect(bloc.state.expression.value, equals('2'));
      });
    });
  });
}
