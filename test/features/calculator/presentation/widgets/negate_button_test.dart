import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/clear_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/delete_character_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_operator_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_parenthesis_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/negate_value_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_bloc.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/theme/calculator_dimensions.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_button_grid.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/clear_button_config.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/negate_button_config.dart';

void main() {
  late InsertParenthesisUseCase insertParenthesisUseCase;
  late InsertOperatorUseCase insertOperatorUseCase;
  late EvaluateExpressionUseCase evaluateExpressionUseCase;
  late ClearExpressionUseCase clearExpressionUseCase;
  late DeleteCharacterUseCase deleteCharacterUseCase;
  late NegateValueUseCase negateValueUseCase;
  late ExpressionDisplayBloc bloc;

  setUp(() {
    insertParenthesisUseCase = InsertParenthesisUseCase();
    insertOperatorUseCase = InsertOperatorUseCase();
    evaluateExpressionUseCase = EvaluateExpressionUseCase();
    clearExpressionUseCase = ClearExpressionUseCase();
    deleteCharacterUseCase = DeleteCharacterUseCase();
    negateValueUseCase = NegateValueUseCase();
    bloc = ExpressionDisplayBloc(
      insertParenthesisUseCase: insertParenthesisUseCase,
      insertOperatorUseCase: insertOperatorUseCase,
      evaluateExpressionUseCase: evaluateExpressionUseCase,
      clearExpressionUseCase: clearExpressionUseCase,
      deleteCharacterUseCase: deleteCharacterUseCase,
      negateValueUseCase: negateValueUseCase,
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
          child: const SizedBox(
            width: 400,
            height: 500,
            child: CalculatorButtonGrid(),
          ),
        ),
      ),
    );
  }

  group('Negate Button - Label Display (AC2)', () {
    testWidgets('displays negate button with correct +/- label',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify the button displays '+/-' text as specified in AC2
      expect(find.text('+/-'), findsOneWidget);
    });

    testWidgets('negate button label matches NegateButtonConfig.label',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify the label matches the config
      expect(find.text(NegateButtonConfig.label), findsOneWidget);
      expect(NegateButtonConfig.label, equals('+/-'));
    });

    testWidgets('negate button has correct key identifier',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify the button can be found by its key
      expect(find.byKey(const Key('negate_button')), findsOneWidget);
    });

    testWidgets('+/- label text is visible and readable',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final negateButtonFinder = find.byKey(const Key('negate_button'));

      // Find the Text widget inside the button
      final textWidget = tester.widget<Text>(
        find.descendant(
          of: negateButtonFinder,
          matching: find.text('+/-'),
        ),
      );

      // Verify text has a style (is styled, not plain)
      expect(textWidget.style, isNotNull);
      // Verify font size is appropriate for readability (24sp as per specs)
      expect(textWidget.style?.fontSize, equals(CalculatorDimensions.circularButtonTextSize));
    });
  });

  group('Negate Button - Tap Behavior', () {
    testWidgets('tapping negate button on empty expression inserts minus sign',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initial state should be empty
      expect(bloc.state.expression.value, isEmpty);

      // Tap the negate button
      await tester.tap(find.byKey(const Key('negate_button')));
      await tester.pump();

      // Expression should have minus sign to start a negative number
      expect(bloc.state.expression.value, equals('-'));
    });

    testWidgets('tapping negate button negates a positive number',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter a positive number
      await tester.tap(find.text('5'));
      await tester.pump();
      expect(bloc.state.expression.value, equals('5'));

      // Tap the negate button
      await tester.tap(find.byKey(const Key('negate_button')));
      await tester.pump();

      // Number should be negated
      expect(bloc.state.expression.value, equals('-5'));
    });

    testWidgets('tapping negate button toggles negative number back to positive',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter a number and negate it
      await tester.tap(find.text('7'));
      await tester.pump();
      await tester.tap(find.byKey(const Key('negate_button')));
      await tester.pump();
      expect(bloc.state.expression.value, equals('-7'));

      // Tap negate again to make it positive
      await tester.tap(find.byKey(const Key('negate_button')));
      await tester.pump();

      // Number should be positive again
      expect(bloc.state.expression.value, equals('7'));
    });

    testWidgets('tapping negate button works with multi-digit numbers',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter a multi-digit number
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();
      expect(bloc.state.expression.value, equals('123'));

      // Tap the negate button
      await tester.tap(find.byKey(const Key('negate_button')));
      await tester.pump();

      // Number should be negated
      expect(bloc.state.expression.value, equals('-123'));
    });

    testWidgets('tapping negate button works with decimal numbers',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter a decimal number
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.text('.'));
      await tester.pump();
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('4'));
      await tester.pump();
      expect(bloc.state.expression.value, equals('3.14'));

      // Tap the negate button
      await tester.tap(find.byKey(const Key('negate_button')));
      await tester.pump();

      // Decimal number should be negated
      expect(bloc.state.expression.value, equals('-3.14'));
    });

    testWidgets('negate button can be tapped multiple times to toggle sign',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter a number
      await tester.tap(find.text('9'));
      await tester.pump();
      expect(bloc.state.expression.value, equals('9'));

      // Toggle multiple times
      await tester.tap(find.byKey(const Key('negate_button')));
      await tester.pump();
      expect(bloc.state.expression.value, equals('-9'));

      await tester.tap(find.byKey(const Key('negate_button')));
      await tester.pump();
      expect(bloc.state.expression.value, equals('9'));

      await tester.tap(find.byKey(const Key('negate_button')));
      await tester.pump();
      expect(bloc.state.expression.value, equals('-9'));
    });
  });

  group('Negate Button - Gray Function Button Styling', () {
    testWidgets('negate button uses gray background color matching C button',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final negateButtonFinder = find.byKey(const Key('negate_button'));
      expect(negateButtonFinder, findsOneWidget);

      // Get the container with decoration
      final container = tester.widget<Container>(
        find.descendant(
          of: negateButtonFinder,
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;

      // Verify negate button uses the correct background color
      expect(decoration.color, equals(NegateButtonConfig.backgroundColor));

      // Verify it matches the clear button's background color
      expect(decoration.color, equals(ClearButtonConfig.backgroundColor));
    });

    testWidgets('negate button background color is #505050 gray',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final negateButtonFinder = find.byKey(const Key('negate_button'));
      final container = tester.widget<Container>(
        find.descendant(
          of: negateButtonFinder,
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;

      // Verify the specific gray color (#505050)
      expect(decoration.color, equals(const Color(0xFF505050)));
    });

    testWidgets('negate button has circular shape via high border radius',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final negateButtonFinder = find.byKey(const Key('negate_button'));
      final container = tester.widget<Container>(
        find.descendant(
          of: negateButtonFinder,
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;

      // Verify the button has circular shape via high border radius (1000dp)
      // The calculator uses BorderRadius.circular(1000.0) for pill/circular appearance
      expect(decoration.borderRadius, isNotNull);
      final borderRadius = decoration.borderRadius as BorderRadius;
      expect(
        borderRadius.topLeft.x,
        equals(CalculatorDimensions.circularButtonRadius),
      );
      expect(
        borderRadius.topRight.x,
        equals(CalculatorDimensions.circularButtonRadius),
      );
      expect(
        borderRadius.bottomLeft.x,
        equals(CalculatorDimensions.circularButtonRadius),
      );
      expect(
        borderRadius.bottomRight.x,
        equals(CalculatorDimensions.circularButtonRadius),
      );
    });

    testWidgets('negate button text is white for good contrast',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final negateButtonFinder = find.byKey(const Key('negate_button'));

      // Find the Text widget inside the button
      final textWidget = tester.widget<Text>(
        find.descendant(
          of: negateButtonFinder,
          matching: find.text('+/-'),
        ),
      );

      // Verify text color is white
      expect(textWidget.style?.color, equals(Colors.white));
    });

    testWidgets('negate button styling is consistent with other function buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Get negate button container
      final negateButtonFinder = find.byKey(const Key('negate_button'));
      final negateContainer = tester.widget<Container>(
        find.descendant(
          of: negateButtonFinder,
          matching: find.byType(Container),
        ).first,
      );
      final negateDecoration = negateContainer.decoration as BoxDecoration;

      // Get clear button container for comparison
      final clearButtonFinder = find.byKey(const Key('clear_button'));
      final clearContainer = tester.widget<Container>(
        find.descendant(
          of: clearButtonFinder,
          matching: find.byType(Container),
        ).first,
      );
      final clearDecoration = clearContainer.decoration as BoxDecoration;

      // Verify both buttons have the same background color
      expect(negateDecoration.color, equals(clearDecoration.color));

      // Verify both buttons have the same border radius for circular shape
      expect(negateDecoration.borderRadius, equals(clearDecoration.borderRadius));
    });

    testWidgets('negate button has borderless appearance',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final negateButtonFinder = find.byKey(const Key('negate_button'));
      final container = tester.widget<Container>(
        find.descendant(
          of: negateButtonFinder,
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;

      // Verify borderless styling (no visible border or transparent border)
      if (decoration.border != null) {
        final border = decoration.border as Border;
        expect(border.top.color, equals(Colors.transparent));
      }
    });
  });

  group('Negate Button - Position in Grid (Bottom-Left)', () {
    testWidgets('negate button is in the bottom row (Row 5)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final negateButton = find.byKey(const Key('negate_button'));
      final button0 = find.text('0');
      final decimalButton = find.text('.');
      final equalsButton = find.byKey(const Key('equals_button'));

      // All buttons exist
      expect(negateButton, findsOneWidget);
      expect(button0, findsOneWidget);
      expect(decimalButton, findsOneWidget);
      expect(equalsButton, findsOneWidget);

      // Get Y positions
      final negateY = tester.getCenter(negateButton).dy;
      final zeroY = tester.getCenter(button0).dy;
      final decimalY = tester.getCenter(decimalButton).dy;
      final equalsY = tester.getCenter(equalsButton).dy;

      // Verify all are in the same row (within tolerance)
      const tolerance = 5.0;
      expect((negateY - zeroY).abs(), lessThan(tolerance),
          reason: '+/- and 0 should be in the same row');
      expect((negateY - decimalY).abs(), lessThan(tolerance),
          reason: '+/- and . should be in the same row');
      expect((negateY - equalsY).abs(), lessThan(tolerance),
          reason: '+/- and = should be in the same row');
    });

    testWidgets('negate button is leftmost in the bottom row (bottom-left position)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final negateX = tester.getCenter(find.byKey(const Key('negate_button'))).dx;
      final zeroX = tester.getCenter(find.text('0')).dx;
      final decimalX = tester.getCenter(find.text('.')).dx;
      final equalsX = tester.getCenter(find.byKey(const Key('equals_button'))).dx;

      // Verify left-to-right order: +/- < 0 < . < =
      expect(negateX, lessThan(zeroX),
          reason: '+/- should be left of 0');
      expect(zeroX, lessThan(decimalX),
          reason: '0 should be left of .');
      expect(decimalX, lessThan(equalsX),
          reason: '. should be left of =');
    });

    testWidgets('negate button is below digit row 4 (1, 2, 3)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final negateY = tester.getCenter(find.byKey(const Key('negate_button'))).dy;
      final digit1Y = tester.getCenter(find.text('1')).dy;

      // Negate button should be below the 1-2-3 row
      expect(negateY, greaterThan(digit1Y),
          reason: '+/- should be below the 1-2-3 row');
    });

    testWidgets('negate button is in column 1 of the 5-row button grid',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Compare negate button X position with buttons in column 1 of other rows
      final negateX = tester.getCenter(find.byKey(const Key('negate_button'))).dx;
      final clearX = tester.getCenter(find.byKey(const Key('clear_button'))).dx;
      final digit7X = tester.getCenter(find.text('7')).dx;
      final digit4X = tester.getCenter(find.text('4')).dx;
      final digit1X = tester.getCenter(find.text('1')).dx;

      // All column 1 buttons should be aligned (within tolerance)
      const tolerance = 5.0;
      expect((negateX - clearX).abs(), lessThan(tolerance),
          reason: '+/- should be aligned with C button');
      expect((negateX - digit7X).abs(), lessThan(tolerance),
          reason: '+/- should be aligned with 7');
      expect((negateX - digit4X).abs(), lessThan(tolerance),
          reason: '+/- should be aligned with 4');
      expect((negateX - digit1X).abs(), lessThan(tolerance),
          reason: '+/- should be aligned with 1');
    });

    testWidgets('bottom row layout follows spec: +/-, 0, ., =',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Get all button positions in bottom row
      final negatePos = tester.getCenter(find.byKey(const Key('negate_button')));
      final zeroPos = tester.getCenter(find.text('0'));
      final decimalPos = tester.getCenter(find.text('.'));
      final equalsPos = tester.getCenter(find.byKey(const Key('equals_button')));

      // Verify horizontal ordering (left to right)
      expect(negatePos.dx < zeroPos.dx, isTrue,
          reason: '+/- should be first (leftmost)');
      expect(zeroPos.dx < decimalPos.dx, isTrue,
          reason: '0 should be second');
      expect(decimalPos.dx < equalsPos.dx, isTrue,
          reason: '. should be third');

      // Verify all are on the same row
      const tolerance = 5.0;
      expect((negatePos.dy - zeroPos.dy).abs(), lessThan(tolerance));
      expect((zeroPos.dy - decimalPos.dy).abs(), lessThan(tolerance));
      expect((decimalPos.dy - equalsPos.dy).abs(), lessThan(tolerance));
    });
  });

  group('Negate Button - Integration with Calculator', () {
    testWidgets('negate works correctly in complex expression workflow',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Build expression with negate: -5+3
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.byKey(const Key('negate_button')));
      await tester.pump();
      expect(bloc.state.expression.value, equals('-5'));

      await tester.tap(find.text('+'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();

      expect(bloc.state.expression.value, equals('-5+3'));
    });

    testWidgets('clear button resets expression after negate operation',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter and negate a number
      await tester.tap(find.text('4'));
      await tester.pump();
      await tester.tap(find.byKey(const Key('negate_button')));
      await tester.pump();
      expect(bloc.state.expression.value, equals('-4'));

      // Clear the expression
      await tester.tap(find.byKey(const Key('clear_button')));
      await tester.pump();

      expect(bloc.state.expression.value, isEmpty);
    });

    testWidgets('negate on empty then add digits creates negative number',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap negate first on empty expression
      await tester.tap(find.byKey(const Key('negate_button')));
      await tester.pump();
      expect(bloc.state.expression.value, equals('-'));

      // Add digits
      await tester.tap(find.text('4'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();

      expect(bloc.state.expression.value, equals('-42'));
    });
  });
}
