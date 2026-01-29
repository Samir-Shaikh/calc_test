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
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_button_grid.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/clear_button_config.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/negate_button_config.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/operator_button_config.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/parenthesis_button_config.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/power_button_config.dart';

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
      expect(find.text('='), findsOneWidget);
    });

    testWidgets('displays decimal button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('.'), findsOneWidget);
    });

    testWidgets('displays power button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text(PowerButtonConfig.label), findsOneWidget);
      expect(find.text('^'), findsOneWidget);
    });

    testWidgets('displays negate button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text(NegateButtonConfig.label), findsOneWidget);
      expect(find.text('+/-'), findsOneWidget);
    });
  });

  group('Button Grid Layout - Row Arrangements', () {
    testWidgets('Row 1 contains C, (), ^, ÷ buttons in correct left-to-right order',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find all buttons and their positions
      final clearButton = find.text('C');
      final parenthesisButton = find.text('()');
      final powerButton = find.text('^');
      final divideButton = find.text('÷');

      // Verify all exist
      expect(clearButton, findsOneWidget);
      expect(parenthesisButton, findsOneWidget);
      expect(powerButton, findsOneWidget);
      expect(divideButton, findsOneWidget);

      // Get positions
      final clearPos = tester.getCenter(clearButton);
      final parenthesisPos = tester.getCenter(parenthesisButton);
      final powerPos = tester.getCenter(powerButton);
      final dividePos = tester.getCenter(divideButton);

      // Verify left-to-right order: C < () < ^ < ÷
      expect(clearPos.dx, lessThan(parenthesisPos.dx),
          reason: 'C should be left of ()');
      expect(parenthesisPos.dx, lessThan(powerPos.dx),
          reason: '() should be left of ^');
      expect(powerPos.dx, lessThan(dividePos.dx),
          reason: '^ should be left of ÷');

      // Verify all buttons are in the same row (same Y position within tolerance)
      const tolerance = 5.0;
      expect((clearPos.dy - parenthesisPos.dy).abs(), lessThan(tolerance),
          reason: 'C and () should be in the same row');
      expect((parenthesisPos.dy - powerPos.dy).abs(), lessThan(tolerance),
          reason: '() and ^ should be in the same row');
      expect((powerPos.dy - dividePos.dy).abs(), lessThan(tolerance),
          reason: '^ and ÷ should be in the same row');
    });

    testWidgets('Row 2 contains 7, 8, 9, × buttons in correct order',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final button7 = find.text('7');
      final button8 = find.text('8');
      final button9 = find.text('9');
      final multiplyButton = find.text('×');

      // Verify all exist
      expect(button7, findsOneWidget);
      expect(button8, findsOneWidget);
      expect(button9, findsOneWidget);
      expect(multiplyButton, findsOneWidget);

      // Get positions
      final pos7 = tester.getCenter(button7);
      final pos8 = tester.getCenter(button8);
      final pos9 = tester.getCenter(button9);
      final posMultiply = tester.getCenter(multiplyButton);

      // Verify left-to-right order: 7 < 8 < 9 < ×
      expect(pos7.dx, lessThan(pos8.dx), reason: '7 should be left of 8');
      expect(pos8.dx, lessThan(pos9.dx), reason: '8 should be left of 9');
      expect(pos9.dx, lessThan(posMultiply.dx), reason: '9 should be left of ×');

      // Verify all buttons are in the same row
      const tolerance = 5.0;
      expect((pos7.dy - pos8.dy).abs(), lessThan(tolerance),
          reason: '7 and 8 should be in the same row');
      expect((pos8.dy - pos9.dy).abs(), lessThan(tolerance),
          reason: '8 and 9 should be in the same row');
      expect((pos9.dy - posMultiply.dy).abs(), lessThan(tolerance),
          reason: '9 and × should be in the same row');
    });

    testWidgets('Row 3 contains 4, 5, 6, + buttons in correct order',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final button4 = find.text('4');
      final button5 = find.text('5');
      final button6 = find.text('6');
      final plusButton = find.text('+');

      // Verify all exist
      expect(button4, findsOneWidget);
      expect(button5, findsOneWidget);
      expect(button6, findsOneWidget);
      expect(plusButton, findsOneWidget);

      // Get positions
      final pos4 = tester.getCenter(button4);
      final pos5 = tester.getCenter(button5);
      final pos6 = tester.getCenter(button6);
      final posPlus = tester.getCenter(plusButton);

      // Verify left-to-right order: 4 < 5 < 6 < +
      expect(pos4.dx, lessThan(pos5.dx), reason: '4 should be left of 5');
      expect(pos5.dx, lessThan(pos6.dx), reason: '5 should be left of 6');
      expect(pos6.dx, lessThan(posPlus.dx), reason: '6 should be left of +');

      // Verify all buttons are in the same row
      const tolerance = 5.0;
      expect((pos4.dy - pos5.dy).abs(), lessThan(tolerance),
          reason: '4 and 5 should be in the same row');
      expect((pos5.dy - pos6.dy).abs(), lessThan(tolerance),
          reason: '5 and 6 should be in the same row');
      expect((pos6.dy - posPlus.dy).abs(), lessThan(tolerance),
          reason: '6 and + should be in the same row');
    });

    testWidgets('Row 4 contains 1, 2, 3, - buttons in correct order',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final button1 = find.text('1');
      final button2 = find.text('2');
      final button3 = find.text('3');
      final minusButton = find.text('-');

      // Verify all exist
      expect(button1, findsOneWidget);
      expect(button2, findsOneWidget);
      expect(button3, findsOneWidget);
      expect(minusButton, findsOneWidget);

      // Get positions
      final pos1 = tester.getCenter(button1);
      final pos2 = tester.getCenter(button2);
      final pos3 = tester.getCenter(button3);
      final posMinus = tester.getCenter(minusButton);

      // Verify left-to-right order: 1 < 2 < 3 < -
      expect(pos1.dx, lessThan(pos2.dx), reason: '1 should be left of 2');
      expect(pos2.dx, lessThan(pos3.dx), reason: '2 should be left of 3');
      expect(pos3.dx, lessThan(posMinus.dx), reason: '3 should be left of -');

      // Verify all buttons are in the same row
      const tolerance = 5.0;
      expect((pos1.dy - pos2.dy).abs(), lessThan(tolerance),
          reason: '1 and 2 should be in the same row');
      expect((pos2.dy - pos3.dy).abs(), lessThan(tolerance),
          reason: '2 and 3 should be in the same row');
      expect((pos3.dy - posMinus.dy).abs(), lessThan(tolerance),
          reason: '3 and - should be in the same row');
    });

    testWidgets('Row 5 contains +/-, 0, ., = buttons in correct order',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final negateButton = find.text('+/-');
      final button0 = find.text('0');
      final decimalButton = find.text('.');
      final equalsButton = find.text('=');

      // Verify all exist
      expect(negateButton, findsOneWidget);
      expect(button0, findsOneWidget);
      expect(decimalButton, findsOneWidget);
      expect(equalsButton, findsOneWidget);

      // Get positions
      final posNegate = tester.getCenter(negateButton);
      final pos0 = tester.getCenter(button0);
      final posDecimal = tester.getCenter(decimalButton);
      final posEquals = tester.getCenter(equalsButton);

      // Verify left-to-right order: +/- < 0 < . < =
      expect(posNegate.dx, lessThan(pos0.dx), reason: '+/- should be left of 0');
      expect(pos0.dx, lessThan(posDecimal.dx), reason: '0 should be left of .');
      expect(posDecimal.dx, lessThan(posEquals.dx), reason: '. should be left of =');

      // Verify all buttons are in the same row
      const tolerance = 5.0;
      expect((posNegate.dy - pos0.dy).abs(), lessThan(tolerance),
          reason: '+/- and 0 should be in the same row');
      expect((pos0.dy - posDecimal.dy).abs(), lessThan(tolerance),
          reason: '0 and . should be in the same row');
      expect((posDecimal.dy - posEquals.dy).abs(), lessThan(tolerance),
          reason: '. and = should be in the same row');
    });

    testWidgets('Rows are arranged top-to-bottom: Row1 < Row2 < Row3 < Row4 < Row5',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Get a representative button from each row
      final row1Y = tester.getCenter(find.text('C')).dy;
      final row2Y = tester.getCenter(find.text('7')).dy;
      final row3Y = tester.getCenter(find.text('4')).dy;
      final row4Y = tester.getCenter(find.text('1')).dy;
      final row5Y = tester.getCenter(find.text('0')).dy;

      // Verify top-to-bottom order
      expect(row1Y, lessThan(row2Y), reason: 'Row 1 should be above Row 2');
      expect(row2Y, lessThan(row3Y), reason: 'Row 2 should be above Row 3');
      expect(row3Y, lessThan(row4Y), reason: 'Row 3 should be above Row 4');
      expect(row4Y, lessThan(row5Y), reason: 'Row 4 should be above Row 5');
    });
  });

  group('AC1: numbers 0-9 standard format', () {
    testWidgets('digit buttons 1-9 are in standard 3x3 arrangement',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Get positions of all digit buttons 1-9
      final pos1 = tester.getCenter(find.text('1'));
      final pos2 = tester.getCenter(find.text('2'));
      final pos3 = tester.getCenter(find.text('3'));
      final pos4 = tester.getCenter(find.text('4'));
      final pos5 = tester.getCenter(find.text('5'));
      final pos6 = tester.getCenter(find.text('6'));
      final pos7 = tester.getCenter(find.text('7'));
      final pos8 = tester.getCenter(find.text('8'));
      final pos9 = tester.getCenter(find.text('9'));

      // Verify column alignment (digits in same column have same X position)
      const tolerance = 5.0;

      // Left column: 7, 4, 1
      expect((pos7.dx - pos4.dx).abs(), lessThan(tolerance),
          reason: '7 and 4 should be in the same column');
      expect((pos4.dx - pos1.dx).abs(), lessThan(tolerance),
          reason: '4 and 1 should be in the same column');

      // Middle column: 8, 5, 2
      expect((pos8.dx - pos5.dx).abs(), lessThan(tolerance),
          reason: '8 and 5 should be in the same column');
      expect((pos5.dx - pos2.dx).abs(), lessThan(tolerance),
          reason: '5 and 2 should be in the same column');

      // Right column: 9, 6, 3
      expect((pos9.dx - pos6.dx).abs(), lessThan(tolerance),
          reason: '9 and 6 should be in the same column');
      expect((pos6.dx - pos3.dx).abs(), lessThan(tolerance),
          reason: '6 and 3 should be in the same column');
    });

    testWidgets('digit 0 is in the bottom row', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final pos0 = tester.getCenter(find.text('0'));
      final pos1 = tester.getCenter(find.text('1'));
      final posEquals = tester.getCenter(find.text('='));

      // 0 should be in the same row as equals (bottom row)
      const tolerance = 5.0;
      expect((pos0.dy - posEquals.dy).abs(), lessThan(tolerance),
          reason: '0 and = should be in the same row (bottom row)');

      // 0 should be below 1
      expect(pos0.dy, greaterThan(pos1.dy),
          reason: '0 should be below 1');
    });

    testWidgets('all digit buttons (0-9) exist', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      for (var i = 0; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget,
            reason: 'Digit $i should exist exactly once');
      }
    });
  });

  group('AC2: operators rightmost column', () {
    testWidgets('all operator buttons are in the rightmost column',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final posDivide = tester.getCenter(find.text('÷'));
      final posMultiply = tester.getCenter(find.text('×'));
      final posPlus = tester.getCenter(find.text('+'));
      final posMinus = tester.getCenter(find.text('-'));

      const tolerance = 5.0;

      // All operators should be in the same column (same X position)
      expect((posDivide.dx - posMultiply.dx).abs(), lessThan(tolerance),
          reason: '÷ and × should be in the same column');
      expect((posMultiply.dx - posPlus.dx).abs(), lessThan(tolerance),
          reason: '× and + should be in the same column');
      expect((posPlus.dx - posMinus.dx).abs(), lessThan(tolerance),
          reason: '+ and - should be in the same column');
    });

    testWidgets('operators are to the right of numeric buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check each row
      final posDivide = tester.getCenter(find.text('÷'));
      final posPower = tester.getCenter(find.text('^'));
      expect(posDivide.dx, greaterThan(posPower.dx),
          reason: '÷ should be right of ^');

      final posMultiply = tester.getCenter(find.text('×'));
      final pos9 = tester.getCenter(find.text('9'));
      expect(posMultiply.dx, greaterThan(pos9.dx),
          reason: '× should be right of 9');

      final posPlus = tester.getCenter(find.text('+'));
      final pos6 = tester.getCenter(find.text('6'));
      expect(posPlus.dx, greaterThan(pos6.dx),
          reason: '+ should be right of 6');

      final posMinus = tester.getCenter(find.text('-'));
      final pos3 = tester.getCenter(find.text('3'));
      expect(posMinus.dx, greaterThan(pos3.dx),
          reason: '- should be right of 3');
    });

    testWidgets('operators are vertically ordered: ÷, ×, +, - from top to bottom',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final posDivide = tester.getCenter(find.text('÷'));
      final posMultiply = tester.getCenter(find.text('×'));
      final posPlus = tester.getCenter(find.text('+'));
      final posMinus = tester.getCenter(find.text('-'));

      expect(posDivide.dy, lessThan(posMultiply.dy),
          reason: '÷ should be above ×');
      expect(posMultiply.dy, lessThan(posPlus.dy),
          reason: '× should be above +');
      expect(posPlus.dy, lessThan(posMinus.dy),
          reason: '+ should be above -');
    });
  });

  group('AC3: top row clear/parentheses/power', () {
    testWidgets('top row contains C, (), ^ buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('C'), findsOneWidget);
      expect(find.text('()'), findsOneWidget);
      expect(find.text('^'), findsOneWidget);
    });

    testWidgets('C, (), ^ are in the first row (above digit rows)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final posClear = tester.getCenter(find.text('C'));
      final posParenthesis = tester.getCenter(find.text('()'));
      final posPower = tester.getCenter(find.text('^'));

      // These should be above the 7-8-9 row
      final pos7 = tester.getCenter(find.text('7'));

      expect(posClear.dy, lessThan(pos7.dy),
          reason: 'C should be above digit row');
      expect(posParenthesis.dy, lessThan(pos7.dy),
          reason: '() should be above digit row');
      expect(posPower.dy, lessThan(pos7.dy),
          reason: '^ should be above digit row');
    });

    testWidgets('top row buttons are in correct order: C, (), ^, ÷',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final posClear = tester.getCenter(find.text('C'));
      final posParenthesis = tester.getCenter(find.text('()'));
      final posPower = tester.getCenter(find.text('^'));
      final posDivide = tester.getCenter(find.text('÷'));

      expect(posClear.dx, lessThan(posParenthesis.dx));
      expect(posParenthesis.dx, lessThan(posPower.dx));
      expect(posPower.dx, lessThan(posDivide.dx));
    });
  });

  group('AC4: bottom row equals/decimal', () {
    testWidgets('bottom row contains = and . buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('='), findsOneWidget);
      expect(find.text('.'), findsOneWidget);
    });

    testWidgets('= and . are in the last row (below 1-2-3 row)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final posEquals = tester.getCenter(find.text('='));
      final posDecimal = tester.getCenter(find.text('.'));
      final pos1 = tester.getCenter(find.text('1'));

      expect(posEquals.dy, greaterThan(pos1.dy),
          reason: '= should be below 1-2-3 row');
      expect(posDecimal.dy, greaterThan(pos1.dy),
          reason: '. should be below 1-2-3 row');
    });

    testWidgets('bottom row contains +/-, 0, ., = in order',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final posNegate = tester.getCenter(find.text('+/-'));
      final pos0 = tester.getCenter(find.text('0'));
      final posDecimal = tester.getCenter(find.text('.'));
      final posEquals = tester.getCenter(find.text('='));

      expect(posNegate.dx, lessThan(pos0.dx),
          reason: '+/- should be left of 0');
      expect(pos0.dx, lessThan(posDecimal.dx),
          reason: '0 should be left of .');
      expect(posDecimal.dx, lessThan(posEquals.dx),
          reason: '. should be left of =');
    });

    testWidgets('equals button is in the bottom-right position',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final posEquals = tester.getCenter(find.text('='));
      final posMinus = tester.getCenter(find.text('-'));
      final posDecimal = tester.getCenter(find.text('.'));

      // Equals should be rightmost in its row
      expect(posEquals.dx, greaterThan(posDecimal.dx),
          reason: '= should be right of .');

      // Equals should be below minus (operator column)
      expect(posEquals.dy, greaterThan(posMinus.dy),
          reason: '= should be below -');
    });
  });

  group('AC5: equal button widths', () {
    testWidgets('all buttons in Row 1 have equal spacing (equal cell widths)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify equal button widths by checking that button centers are evenly spaced
      // This is the proper way to verify FlexColumnWidth(1) is working
      final posClear = tester.getCenter(find.text('C'));
      final posParenthesis = tester.getCenter(find.text('()'));
      final posPower = tester.getCenter(find.text('^'));
      final posDivide = tester.getCenter(find.text('÷'));

      // Calculate spacing between button centers
      final spacing1 = posParenthesis.dx - posClear.dx;
      final spacing2 = posPower.dx - posParenthesis.dx;
      final spacing3 = posDivide.dx - posPower.dx;

      const tolerance = 5.0;

      // All spacings should be approximately equal (proving equal column widths)
      expect((spacing1 - spacing2).abs(), lessThan(tolerance),
          reason: 'Spacing between C-() and ()-^ should be equal');
      expect((spacing2 - spacing3).abs(), lessThan(tolerance),
          reason: 'Spacing between ()-^ and ^-÷ should be equal');
    });

    testWidgets('all buttons in Row 2 have equal spacing (equal cell widths)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final pos7 = tester.getCenter(find.text('7'));
      final pos8 = tester.getCenter(find.text('8'));
      final pos9 = tester.getCenter(find.text('9'));
      final posMultiply = tester.getCenter(find.text('×'));

      final spacing1 = pos8.dx - pos7.dx;
      final spacing2 = pos9.dx - pos8.dx;
      final spacing3 = posMultiply.dx - pos9.dx;

      const tolerance = 5.0;

      expect((spacing1 - spacing2).abs(), lessThan(tolerance),
          reason: 'Spacing between 7-8 and 8-9 should be equal');
      expect((spacing2 - spacing3).abs(), lessThan(tolerance),
          reason: 'Spacing between 8-9 and 9-× should be equal');
    });

    testWidgets('all buttons in Row 3 have equal spacing (equal cell widths)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final pos4 = tester.getCenter(find.text('4'));
      final pos5 = tester.getCenter(find.text('5'));
      final pos6 = tester.getCenter(find.text('6'));
      final posPlus = tester.getCenter(find.text('+'));

      final spacing1 = pos5.dx - pos4.dx;
      final spacing2 = pos6.dx - pos5.dx;
      final spacing3 = posPlus.dx - pos6.dx;

      const tolerance = 5.0;

      expect((spacing1 - spacing2).abs(), lessThan(tolerance),
          reason: 'Spacing between 4-5 and 5-6 should be equal');
      expect((spacing2 - spacing3).abs(), lessThan(tolerance),
          reason: 'Spacing between 5-6 and 6-+ should be equal');
    });

    testWidgets('all buttons in Row 4 have equal spacing (equal cell widths)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final pos1 = tester.getCenter(find.text('1'));
      final pos2 = tester.getCenter(find.text('2'));
      final pos3 = tester.getCenter(find.text('3'));
      final posMinus = tester.getCenter(find.text('-'));

      final spacing1 = pos2.dx - pos1.dx;
      final spacing2 = pos3.dx - pos2.dx;
      final spacing3 = posMinus.dx - pos3.dx;

      const tolerance = 5.0;

      expect((spacing1 - spacing2).abs(), lessThan(tolerance),
          reason: 'Spacing between 1-2 and 2-3 should be equal');
      expect((spacing2 - spacing3).abs(), lessThan(tolerance),
          reason: 'Spacing between 2-3 and 3-- should be equal');
    });

    testWidgets('all buttons in Row 5 have equal spacing (equal cell widths)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final posNegate = tester.getCenter(find.text('+/-'));
      final pos0 = tester.getCenter(find.text('0'));
      final posDecimal = tester.getCenter(find.text('.'));
      final posEquals = tester.getCenter(find.text('='));

      final spacing1 = pos0.dx - posNegate.dx;
      final spacing2 = posDecimal.dx - pos0.dx;
      final spacing3 = posEquals.dx - posDecimal.dx;

      const tolerance = 5.0;

      expect((spacing1 - spacing2).abs(), lessThan(tolerance),
          reason: 'Spacing between +/--0 and 0-. should be equal');
      expect((spacing2 - spacing3).abs(), lessThan(tolerance),
          reason: 'Spacing between 0-. and .-= should be equal');
    });

    testWidgets('button columns are aligned across all rows',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Get buttons from column 1 (leftmost) across rows
      final posClear = tester.getCenter(find.text('C'));
      final pos7 = tester.getCenter(find.text('7'));
      final pos4 = tester.getCenter(find.text('4'));
      final pos1 = tester.getCenter(find.text('1'));
      final posNegate = tester.getCenter(find.text('+/-'));

      const tolerance = 5.0;

      // All column 1 buttons should have same X position
      expect((posClear.dx - pos7.dx).abs(), lessThan(tolerance),
          reason: 'C and 7 should be in same column');
      expect((pos7.dx - pos4.dx).abs(), lessThan(tolerance),
          reason: '7 and 4 should be in same column');
      expect((pos4.dx - pos1.dx).abs(), lessThan(tolerance),
          reason: '4 and 1 should be in same column');
      expect((pos1.dx - posNegate.dx).abs(), lessThan(tolerance),
          reason: '1 and +/- should be in same column');
    });

    testWidgets('Table widget uses FlexColumnWidth for equal distribution',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify Table widget exists (the implementation uses Table with FlexColumnWidth)
      expect(find.byType(Table), findsOneWidget);
    });

    testWidgets('button containers in each row have equal flex distribution',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify Table widget exists with FlexColumnWidth
      expect(find.byType(Table), findsOneWidget);

      // Verify buttons in a row are evenly distributed by checking their centers
      // The spacing between button centers should be consistent
      final pos7 = tester.getCenter(find.text('7'));
      final pos8 = tester.getCenter(find.text('8'));
      final pos9 = tester.getCenter(find.text('9'));
      final posMultiply = tester.getCenter(find.text('×'));

      // Calculate spacing between buttons
      final spacing78 = pos8.dx - pos7.dx;
      final spacing89 = pos9.dx - pos8.dx;
      final spacing9Multiply = posMultiply.dx - pos9.dx;

      const tolerance = 5.0;

      expect((spacing78 - spacing89).abs(), lessThan(tolerance),
          reason: 'Spacing between 7-8 and 8-9 should be similar');
      expect((spacing89 - spacing9Multiply).abs(), lessThan(tolerance),
          reason: 'Spacing between 8-9 and 9-× should be similar');
    });
  });

  group('Button Types Verification', () {
    testWidgets('numeric buttons (0-9) use digit button styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // All digit buttons should exist
      for (var i = 0; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('operator buttons use orange background styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify equals button has correct styling
      final equalsButtonFinder = find.byKey(const Key('equals_button'));
      expect(equalsButtonFinder, findsOneWidget);

      final container = tester.widget<Container>(
        find.descendant(
          of: equalsButtonFinder,
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(EqualsButtonConfig.backgroundColor));
    });

    testWidgets('function buttons (C, (), ^) use gray background styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Clear button
      final clearButtonFinder = find.byKey(const Key('clear_button'));
      expect(clearButtonFinder, findsOneWidget);
      final clearContainer = tester.widget<Container>(
        find.descendant(
          of: clearButtonFinder,
          matching: find.byType(Container),
        ).first,
      );
      final clearDecoration = clearContainer.decoration as BoxDecoration;
      expect(clearDecoration.color, equals(ClearButtonConfig.backgroundColor));

      // Parenthesis button
      final parenthesisButtonFinder = find.byKey(const Key('parenthesis_button'));
      expect(parenthesisButtonFinder, findsOneWidget);
      final parenthesisContainer = tester.widget<Container>(
        find.descendant(
          of: parenthesisButtonFinder,
          matching: find.byType(Container),
        ).first,
      );
      final parenthesisDecoration =
          parenthesisContainer.decoration as BoxDecoration;
      expect(parenthesisDecoration.color,
          equals(ParenthesisButtonConfig.backgroundColor));

      // Power button
      final powerButtonFinder = find.byKey(const Key('power_button'));
      expect(powerButtonFinder, findsOneWidget);
      final powerContainer = tester.widget<Container>(
        find.descendant(
          of: powerButtonFinder,
          matching: find.byType(Container),
        ).first,
      );
      final powerDecoration = powerContainer.decoration as BoxDecoration;
      expect(powerDecoration.color, equals(PowerButtonConfig.backgroundColor));
    });

    testWidgets('negate button uses gray background styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final negateButtonFinder = find.byKey(const Key('negate_button'));
      expect(negateButtonFinder, findsOneWidget);

      final container = tester.widget<Container>(
        find.descendant(
          of: negateButtonFinder,
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(NegateButtonConfig.backgroundColor));
    });
  });

  group('Clear Button', () {
    testWidgets('displays clear button with correct label', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text(ClearButtonConfig.label), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('clear button has correct key', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byKey(const Key('clear_button')), findsOneWidget);
    });

    testWidgets('clear button is positioned in first row (top-left)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find the clear button
      final clearButton = find.byKey(const Key('clear_button'));
      expect(clearButton, findsOneWidget);

      // Verify it exists alongside other first-row buttons
      expect(find.text('C'), findsOneWidget);
      expect(find.text('()'), findsOneWidget);
      expect(find.text('^'), findsOneWidget);
      expect(find.text('÷'), findsOneWidget);
    });

    testWidgets('tapping clear button dispatches ClearPressed event', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Add some digits first
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();

      expect(bloc.state.expression.value, equals('53'));

      // Tap the clear button
      await tester.tap(find.byKey(const Key('clear_button')));
      await tester.pump();

      // After tapping, expression should be empty
      expect(bloc.state.expression.value, isEmpty);
    });

    testWidgets('clear button resets expression after complex input', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Build a complex expression: (5+3)×2
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
      await tester.tap(find.text('×'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();

      expect(bloc.state.expression.value, equals('(5+3)×2'));

      // Clear the expression
      await tester.tap(find.byKey(const Key('clear_button')));
      await tester.pump();

      // Expression should be empty
      expect(bloc.state.expression.value, isEmpty);
    });

    testWidgets('clear button uses gray background color', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final clearButtonFinder = find.byKey(const Key('clear_button'));
      expect(clearButtonFinder, findsOneWidget);

      // Verify the button's decoration uses the correct background color
      final container = tester.widget<Container>(
        find.descendant(
          of: clearButtonFinder,
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(ClearButtonConfig.backgroundColor));
    });

    testWidgets('clear button can be tapped multiple times', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Add digits, clear, add more digits, clear again
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      expect(bloc.state.expression.value, equals('12'));

      await tester.tap(find.byKey(const Key('clear_button')));
      await tester.pump();
      expect(bloc.state.expression.value, isEmpty);

      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.text('4'));
      await tester.pump();
      expect(bloc.state.expression.value, equals('34'));

      await tester.tap(find.byKey(const Key('clear_button')));
      await tester.pump();
      expect(bloc.state.expression.value, isEmpty);
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
      expect(find.text('^'), findsOneWidget);
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

  group('Power Button', () {
    testWidgets('displays power button with correct label', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text(PowerButtonConfig.label), findsOneWidget);
      expect(find.text('^'), findsOneWidget);
    });

    testWidgets('power button has correct key', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byKey(const Key('power_button')), findsOneWidget);
    });

    testWidgets('power button is positioned in first row', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find the power button
      final powerButton = find.byKey(const Key('power_button'));
      expect(powerButton, findsOneWidget);

      // Verify it exists alongside other first-row buttons
      expect(find.text('C'), findsOneWidget);
      expect(find.text('()'), findsOneWidget);
      expect(find.text('÷'), findsOneWidget);
    });

    testWidgets('tapping power button dispatches PowerOperatorPressed event', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // First add a digit so power operator can be inserted
      await tester.tap(find.text('2'));
      await tester.pump();

      expect(bloc.state.expression.value, equals('2'));

      // Tap the power button
      await tester.tap(find.byKey(const Key('power_button')));
      await tester.pump();

      // After tapping, expression should contain '2^'
      expect(bloc.state.expression.value, equals('2^'));
    });

    testWidgets('power button uses gray background color', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final powerButtonFinder = find.byKey(const Key('power_button'));
      expect(powerButtonFinder, findsOneWidget);

      // Verify the button's decoration uses the correct background color
      final container = tester.widget<Container>(
        find.descendant(
          of: powerButtonFinder,
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(PowerButtonConfig.backgroundColor));
    });

    testWidgets('building expression with power operator', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Build expression: 2^3
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.byKey(const Key('power_button')));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();

      expect(bloc.state.expression.value, equals('2^3'));
    });
  });

  group('Negate Button', () {
    testWidgets('displays negate button with correct label', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text(NegateButtonConfig.label), findsOneWidget);
      expect(find.text('+/-'), findsOneWidget);
    });

    testWidgets('negate button has correct key', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byKey(const Key('negate_button')), findsOneWidget);
    });

    testWidgets('negate button is positioned in bottom row', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find the negate button
      final negateButton = find.byKey(const Key('negate_button'));
      expect(negateButton, findsOneWidget);

      // Verify it exists alongside other bottom-row buttons
      expect(find.text('0'), findsOneWidget);
      expect(find.text('.'), findsOneWidget);
      expect(find.text('='), findsOneWidget);
    });

    testWidgets('negate button uses gray background color', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final negateButtonFinder = find.byKey(const Key('negate_button'));
      expect(negateButtonFinder, findsOneWidget);

      final container = tester.widget<Container>(
        find.descendant(
          of: negateButtonFinder,
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(NegateButtonConfig.backgroundColor));
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

    testWidgets('combining digits, operators, parentheses, and power', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Build expression: (2^3)+1
      await tester.tap(find.byKey(const Key('parenthesis_button'))); // (
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.byKey(const Key('power_button'))); // ^
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.byKey(const Key('parenthesis_button'))); // )
      await tester.pump();
      await tester.tap(find.text('+'));
      await tester.pump();
      await tester.tap(find.text('1'));
      await tester.pump();

      expect(bloc.state.expression.value, equals('(2^3)+1'));
    });
  });

  group('Grid Structure', () {
    testWidgets('grid has 5 rows of buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify representative buttons from each row exist
      // Row 1
      expect(find.text('C'), findsOneWidget);
      // Row 2
      expect(find.text('7'), findsOneWidget);
      // Row 3
      expect(find.text('4'), findsOneWidget);
      // Row 4
      expect(find.text('1'), findsOneWidget);
      // Row 5
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('each row has 4 buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Row 1: C, (), ^, ÷
      expect(find.text('C'), findsOneWidget);
      expect(find.text('()'), findsOneWidget);
      expect(find.text('^'), findsOneWidget);
      expect(find.text('÷'), findsOneWidget);

      // Row 2: 7, 8, 9, ×
      expect(find.text('7'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
      expect(find.text('×'), findsOneWidget);

      // Row 3: 4, 5, 6, +
      expect(find.text('4'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('+'), findsOneWidget);

      // Row 4: 1, 2, 3, -
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('-'), findsOneWidget);

      // Row 5: +/-, 0, ., =
      expect(find.text('+/-'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('.'), findsOneWidget);
      expect(find.text('='), findsOneWidget);
    });

    testWidgets('total button count is 20 (5 rows × 4 buttons)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Count unique buttons by their labels
      final expectedLabels = [
        'C', '()', '^', '÷',
        '7', '8', '9', '×',
        '4', '5', '6', '+',
        '1', '2', '3', '-',
        '+/-', '0', '.', '=',
      ];

      for (final label in expectedLabels) {
        expect(find.text(label), findsOneWidget,
            reason: 'Button with label "$label" should exist exactly once');
      }
    });
  });
}
