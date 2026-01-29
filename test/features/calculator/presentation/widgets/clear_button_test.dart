import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/clear_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/delete_character_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_operator_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_parenthesis_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_bloc.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_event.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/theme/calculator_button_decorations.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/theme/calculator_colors.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_button_grid.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/clear_button_config.dart';

void main() {
  late InsertParenthesisUseCase insertParenthesisUseCase;
  late InsertOperatorUseCase insertOperatorUseCase;
  late EvaluateExpressionUseCase evaluateExpressionUseCase;
  late ClearExpressionUseCase clearExpressionUseCase;
  late DeleteCharacterUseCase deleteCharacterUseCase;
  late ExpressionDisplayBloc bloc;

  setUp(() {
    insertParenthesisUseCase = InsertParenthesisUseCase();
    insertOperatorUseCase = InsertOperatorUseCase();
    evaluateExpressionUseCase = EvaluateExpressionUseCase();
    clearExpressionUseCase = ClearExpressionUseCase();
    deleteCharacterUseCase = DeleteCharacterUseCase();
    bloc = ExpressionDisplayBloc(
      insertParenthesisUseCase: insertParenthesisUseCase,
      insertOperatorUseCase: insertOperatorUseCase,
      evaluateExpressionUseCase: evaluateExpressionUseCase,
      clearExpressionUseCase: clearExpressionUseCase,
      deleteCharacterUseCase: deleteCharacterUseCase,
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

  group('Clear Button Widget Tests', () {
    group('Display Tests', () {
      testWidgets('displays "C" label on the button', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Verify the clear button shows 'C' text
        expect(find.text('C'), findsOneWidget);
        expect(find.text(ClearButtonConfig.label), findsOneWidget);
      });

      testWidgets('button label matches ClearButtonConfig.label', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Verify the label is exactly 'C'
        expect(ClearButtonConfig.label, equals('C'));
        expect(find.text(ClearButtonConfig.label), findsOneWidget);
      });

      testWidgets('button is findable by key', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byKey(const Key('clear_button')), findsOneWidget);
      });
    });

    group('Background Color Tests', () {
      testWidgets('has gray (#505050) background color', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final clearButtonFinder = find.byKey(const Key('clear_button'));
        expect(clearButtonFinder, findsOneWidget);

        // Find the Container widget that has the decoration
        final container = tester.widget<Container>(
          find.descendant(
            of: clearButtonFinder,
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;

        // Verify the background color is #505050 (gray)
        expect(decoration.color, equals(const Color(0xFF505050)));
        expect(decoration.color, equals(CalculatorColors.clearButtonBackground));
      });

      testWidgets('background color matches ClearButtonConfig.backgroundColor', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final clearButtonFinder = find.byKey(const Key('clear_button'));
        final container = tester.widget<Container>(
          find.descendant(
            of: clearButtonFinder,
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;

        expect(decoration.color, equals(ClearButtonConfig.backgroundColor));
      });

      testWidgets('CalculatorColors.clearButtonBackground is #505050', (WidgetTester tester) async {
        // Verify the constant value is correct
        expect(CalculatorColors.clearButtonBackground, equals(const Color(0xFF505050)));
      });

      testWidgets('explicit color verification for #505050', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final clearButtonFinder = find.byKey(const Key('clear_button'));
        final container = tester.widget<Container>(
          find.descendant(
            of: clearButtonFinder,
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;

        // Explicit verification that the color is exactly Color(0xFF505050)
        expect(decoration.color, isNotNull);
        expect(decoration.color!.value, equals(0xFF505050));
        expect(decoration.color, equals(const Color(0xFF505050)));
      });
    });

    group('Event Dispatch Tests', () {
      testWidgets('tap dispatches ClearPressed event to BLoC', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // First add some digits to the expression
        await tester.tap(find.text('1'));
        await tester.pump();
        await tester.tap(find.text('2'));
        await tester.pump();
        await tester.tap(find.text('3'));
        await tester.pump();
        expect(bloc.state.expression.value, equals('123'));

        // Tap the clear button
        await tester.tap(find.byKey(const Key('clear_button')));
        await tester.pump();

        // After tapping, expression should be empty
        // This proves the ClearPressed event was dispatched and handled
        expect(bloc.state.expression.value, isEmpty);
      });

      testWidgets('tap on empty expression remains empty', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Initial state should be empty expression
        expect(bloc.state.expression.value, isEmpty);

        // Tap the clear button on empty expression
        await tester.tap(find.byKey(const Key('clear_button')));
        await tester.pump();

        // Expression should still be empty
        expect(bloc.state.expression.value, isEmpty);
      });

      testWidgets('tap clears expression with operators', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Build expression: 12+34
        await tester.tap(find.text('1'));
        await tester.pump();
        await tester.tap(find.text('2'));
        await tester.pump();
        await tester.tap(find.text('+'));
        await tester.pump();
        await tester.tap(find.text('3'));
        await tester.pump();
        await tester.tap(find.text('4'));
        await tester.pump();
        expect(bloc.state.expression.value, equals('12+34'));

        // Tap the clear button
        await tester.tap(find.byKey(const Key('clear_button')));
        await tester.pump();

        // Expression should be cleared
        expect(bloc.state.expression.value, isEmpty);
      });

      testWidgets('tap dispatches event that updates BLoC state', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Add some digits first
        await tester.tap(find.text('5'));
        await tester.pump();
        await tester.tap(find.text('6'));
        await tester.pump();
        final expressionAfterDigits = bloc.state.expression.value;
        expect(expressionAfterDigits, equals('56'));

        // Tap the clear button
        await tester.tap(find.byKey(const Key('clear_button')));
        await tester.pump();

        // Verify state was updated (not the same as before clear tap)
        expect(bloc.state.expression.value, isNot(equals(expressionAfterDigits)));
        expect(bloc.state.expression.value, isEmpty);
      });

      testWidgets('ClearPressed event is correctly constructed', (WidgetTester tester) async {
        // Test that ClearPressed event can be constructed
        const event = ClearPressed();

        // Verify event properties
        expect(event, isA<ExpressionDisplayEvent>());
        expect(event.toString(), equals('ClearPressed()'));
      });

      testWidgets('tap interaction verification - event dispatched to BLoC', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Build a complex expression
        await tester.tap(find.text('9'));
        await tester.pump();
        await tester.tap(find.text('×'));
        await tester.pump();
        await tester.tap(find.text('8'));
        await tester.pump();
        expect(bloc.state.expression.value, equals('9×8'));

        // Verify initial state before clear
        expect(bloc.state.expression.isEmpty, isFalse);

        // Tap the clear button - this dispatches ClearPressed event
        await tester.tap(find.byKey(const Key('clear_button')));
        await tester.pump();

        // Verify ClearPressed event was dispatched and handled
        expect(bloc.state.expression.value, isEmpty);
        expect(bloc.state.expression.isEmpty, isTrue);
      });
    });

    group('Circular Shape Tests', () {
      testWidgets('button has circular shape decoration', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final clearButtonFinder = find.byKey(const Key('clear_button'));
        final container = tester.widget<Container>(
          find.descendant(
            of: clearButtonFinder,
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;

        // Verify the shape is circular
        expect(decoration.shape, equals(BoxShape.circle));
      });

      testWidgets('button decoration matches CalculatorButtonDecorations.clearButton', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final clearButtonFinder = find.byKey(const Key('clear_button'));
        final container = tester.widget<Container>(
          find.descendant(
            of: clearButtonFinder,
            matching: find.byType(Container),
          ).first,
        );

        final actualDecoration = container.decoration as BoxDecoration;
        final expectedDecoration = CalculatorButtonDecorations.clearButton;

        // Verify decoration properties match
        expect(actualDecoration.color, equals(expectedDecoration.color));
        expect(actualDecoration.shape, equals(expectedDecoration.shape));
      });

      testWidgets('circular shape matches other calculator buttons pattern', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Find clear button's container
        final clearButtonFinder = find.byKey(const Key('clear_button'));
        final clearContainer = tester.widget<Container>(
          find.descendant(
            of: clearButtonFinder,
            matching: find.byType(Container),
          ).first,
        );
        final clearDecoration = clearContainer.decoration as BoxDecoration;

        // Find parenthesis button's container for comparison
        final parenthesisButtonFinder = find.byKey(const Key('parenthesis_button'));
        final parenthesisContainer = tester.widget<Container>(
          find.descendant(
            of: parenthesisButtonFinder,
            matching: find.byType(Container),
          ).first,
        );
        final parenthesisDecoration = parenthesisContainer.decoration as BoxDecoration;

        // The clear button should have the same shape as parenthesis button
        expect(clearDecoration.shape, equals(parenthesisDecoration.shape));
        expect(clearDecoration.shape, equals(BoxShape.circle));
      });

      testWidgets('ClearButtonConfig.decoration has circular shape', (WidgetTester tester) async {
        // Verify the config decoration has circular shape
        final decoration = ClearButtonConfig.decoration;

        expect(decoration.shape, equals(BoxShape.circle));
        expect(decoration.color, equals(CalculatorColors.clearButtonBackground));
      });
    });

    group('Text Style Tests', () {
      testWidgets('button text has white color for contrast', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final textWidget = tester.widget<Text>(find.text('C'));
        final textStyle = textWidget.style!;

        // Verify text color is white for good contrast on gray background
        expect(textStyle.color, equals(Colors.white));
      });

      testWidgets('button text style matches ClearButtonConfig.textColor', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final textWidget = tester.widget<Text>(find.text('C'));
        final textStyle = textWidget.style!;

        expect(textStyle.color, equals(ClearButtonConfig.textColor));
        expect(textStyle.color, equals(CalculatorColors.lightButtonText));
      });
    });

    group('Button Presence in Grid Tests', () {
      testWidgets('clear button is present in calculator button grid', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Verify the clear button exists in the grid
        expect(find.byKey(const Key('clear_button')), findsOneWidget);
        expect(find.text('C'), findsOneWidget);
      });

      testWidgets('clear button is in the same row as parenthesis, %, and ÷', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Verify other buttons in the same row exist
        expect(find.text('C'), findsOneWidget);
        expect(find.text('()'), findsOneWidget);
        expect(find.text('%'), findsOneWidget);
        expect(find.text('÷'), findsOneWidget);
      });

      testWidgets('clear button has same gray color as parenthesis and power buttons', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Get clear button decoration
        final clearButtonFinder = find.byKey(const Key('clear_button'));
        final clearContainer = tester.widget<Container>(
          find.descendant(
            of: clearButtonFinder,
            matching: find.byType(Container),
          ).first,
        );
        final clearDecoration = clearContainer.decoration as BoxDecoration;

        // Get parenthesis button decoration
        final parenthesisButtonFinder = find.byKey(const Key('parenthesis_button'));
        final parenthesisContainer = tester.widget<Container>(
          find.descendant(
            of: parenthesisButtonFinder,
            matching: find.byType(Container),
          ).first,
        );
        final parenthesisDecoration = parenthesisContainer.decoration as BoxDecoration;

        // Get power button decoration
        final powerButtonFinder = find.byKey(const Key('power_button'));
        final powerContainer = tester.widget<Container>(
          find.descendant(
            of: powerButtonFinder,
            matching: find.byType(Container),
          ).first,
        );
        final powerDecoration = powerContainer.decoration as BoxDecoration;

        // All three should have the same gray color
        expect(clearDecoration.color, equals(parenthesisDecoration.color));
        expect(clearDecoration.color, equals(powerDecoration.color));
        expect(clearDecoration.color, equals(const Color(0xFF505050)));
      });
    });

    group('Integration with BLoC', () {
      testWidgets('button correctly integrates with ExpressionDisplayBloc for clearing', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Build expression: 2+3
        await tester.tap(find.text('2'));
        await tester.pump();

        await tester.tap(find.text('+'));
        await tester.pump();

        await tester.tap(find.text('3'));
        await tester.pump();

        // Verify the expression
        expect(bloc.state.expression.value, equals('2+3'));

        // Clear the expression
        await tester.tap(find.byKey(const Key('clear_button')));
        await tester.pump();

        // Verify the expression is cleared
        expect(bloc.state.expression.value, isEmpty);
      });

      testWidgets('clear button clears expression with parentheses', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Build expression: (2+3)
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

        // Verify the complete expression
        expect(bloc.state.expression.value, equals('(2+3)'));

        // Clear
        await tester.tap(find.byKey(const Key('clear_button')));
        await tester.pump();

        // Verify the expression is cleared
        expect(bloc.state.expression.value, isEmpty);
      });

      testWidgets('clear button clears expression with power operator', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Build expression with power operator: 2^3
        await tester.tap(find.text('2'));
        await tester.pump();

        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pump();

        await tester.tap(find.text('3'));
        await tester.pump();
        expect(bloc.state.expression.value, equals('2^3'));

        // Clear
        await tester.tap(find.byKey(const Key('clear_button')));
        await tester.pump();
        expect(bloc.state.expression.value, isEmpty);
      });

      testWidgets('clear button resets parenthesis toggle state', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Insert opening parenthesis
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pump();
        expect(bloc.state.expression.value, equals('('));

        // Clear
        await tester.tap(find.byKey(const Key('clear_button')));
        await tester.pump();
        expect(bloc.state.expression.value, isEmpty);

        // After clear, next parenthesis should be '(' again (toggle state reset)
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pump();
        expect(bloc.state.expression.value, equals('('));
      });

      testWidgets('clear button allows new expression after clearing', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Build first expression: 123
        await tester.tap(find.text('1'));
        await tester.pump();
        await tester.tap(find.text('2'));
        await tester.pump();
        await tester.tap(find.text('3'));
        await tester.pump();
        expect(bloc.state.expression.value, equals('123'));

        // Clear
        await tester.tap(find.byKey(const Key('clear_button')));
        await tester.pump();
        expect(bloc.state.expression.value, isEmpty);

        // Build new expression: 456
        await tester.tap(find.text('4'));
        await tester.pump();
        await tester.tap(find.text('5'));
        await tester.pump();
        await tester.tap(find.text('6'));
        await tester.pump();
        expect(bloc.state.expression.value, equals('456'));
      });

      testWidgets('clear button clears result after evaluation', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Build and evaluate expression: 2+3=5
        await tester.tap(find.text('2'));
        await tester.pump();
        await tester.tap(find.text('+'));
        await tester.pump();
        await tester.tap(find.text('3'));
        await tester.pump();
        await tester.tap(find.text('='));
        await tester.pump();

        // Verify result
        expect(bloc.state.result, equals('5'));

        // Clear
        await tester.tap(find.byKey(const Key('clear_button')));
        await tester.pump();

        // Verify expression and result are cleared
        expect(bloc.state.expression.value, isEmpty);
        expect(bloc.state.result, isNull);
      });
    });
  });
}
