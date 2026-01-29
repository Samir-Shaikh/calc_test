import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/clear_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/delete_character_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_operator_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_parenthesis_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_bloc.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_state.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/screens/calculator_screen.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/theme/calculator_colors.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/operator_button_config.dart';

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
      home: BlocProvider<ExpressionDisplayBloc>.value(
        value: bloc,
        child: const CalculatorScreen(),
      ),
    );
  }

  group('CalculatorScreen', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CalculatorScreen), findsOneWidget);
    });

    testWidgets('displays calculator button grid', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify digit buttons are visible
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('='), findsOneWidget);
    });

    testWidgets('displays expression area with initial state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initial state shows '0' in expression display - find by style (larger font)
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      final displayText = textWidgets.where((t) => 
        t.data == '0' && t.style?.fontSize == 48
      );
      expect(displayText.length, equals(1));
    });

    testWidgets('has black background', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(Colors.black));
    });
  });

  group('Error Toast Display - BLoC State', () {
    testWidgets('bloc emits evaluation error state for incomplete expression', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter an incomplete expression (e.g., "5+")
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('+'));
      await tester.pump();

      // Tap equals to trigger evaluation
      await tester.tap(find.byKey(const Key('equals_button')));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify bloc state has evaluation error
      expect(bloc.state.isEvaluationError, isTrue);
      expect(bloc.state.evaluationError, isNotNull);
      expect(bloc.state.evaluationError, isNotEmpty);
    });

    testWidgets('bloc emits error state for unbalanced parentheses', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter expression with unbalanced parentheses: "(5"
      await tester.tap(find.byKey(const Key('parenthesis_button')));
      await tester.pump();
      await tester.tap(find.text('5'));
      await tester.pump();

      // Tap equals to trigger evaluation
      await tester.tap(find.byKey(const Key('equals_button')));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify bloc state has evaluation error
      expect(bloc.state.isEvaluationError, isTrue);
      expect(bloc.state.evaluationError, isNotNull);
    });

    testWidgets('bloc emits error state for expression with only operator', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter just an operator
      await tester.tap(find.text('+'));
      await tester.pump();

      // Tap equals to trigger evaluation
      await tester.tap(find.byKey(const Key('equals_button')));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify bloc state has evaluation error
      expect(bloc.state.isEvaluationError, isTrue);
      expect(bloc.state.evaluationError, isNotNull);
    });

    testWidgets('no error for valid expression', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter valid expression: 5+3
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('+'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();

      // Tap equals
      await tester.tap(find.byKey(const Key('equals_button')));
      await tester.pump();

      // Verify no error state
      expect(bloc.state.isEvaluationError, isFalse);
      expect(bloc.state.evaluationError, isNull);
    });

    testWidgets('result is computed for valid expression', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter valid expression: 5+3
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('+'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();

      // Tap equals
      await tester.tap(find.byKey(const Key('equals_button')));
      await tester.pump();

      // Verify result is computed in bloc state
      expect(bloc.state.result, equals('8'));
    });

    testWidgets('error state clears when new digit is pressed', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter invalid expression and trigger error
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('+'));
      await tester.pump();
      await tester.tap(find.byKey(const Key('equals_button')));
      await tester.pump();

      // Verify error state
      expect(bloc.state.isEvaluationError, isTrue);

      // Press a new digit
      await tester.tap(find.text('3'));
      await tester.pump();

      // The state should no longer be in error state
      expect(bloc.state.isEvaluationError, isFalse);
    });

    testWidgets('clear button resets error state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter invalid expression and trigger error
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('+'));
      await tester.pump();
      await tester.tap(find.byKey(const Key('equals_button')));
      await tester.pump();

      // Press clear
      await tester.tap(find.text('C'));
      await tester.pump();

      // State should be reset
      expect(bloc.state.isEvaluationError, isFalse);
      expect(bloc.state.evaluationError, isNull);
      expect(bloc.state.expression.value, isEmpty);
    });

    testWidgets('error message contains meaningful description', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter invalid expression ending with operator
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('+'));
      await tester.pump();
      await tester.tap(find.byKey(const Key('equals_button')));
      await tester.pump();

      // Verify error message is descriptive (not just 'Error')
      expect(bloc.state.evaluationError, isNot(equals('Error')));
      expect(bloc.state.evaluationError!.length, greaterThan(5));
    });
  });

  group('Invalid Expression Error State - AC2 Verification', () {
    testWidgets('consecutive operators like 2++3 triggers evaluation error state', 
        (WidgetTester tester) async {
      // AC2: When an invalid expression like '2++3' is entered and equals is pressed,
      // the BLoC emits an evaluation error state which triggers toast display
      await tester.pumpWidget(createTestWidget());

      // Enter "2"
      await tester.tap(find.text('2'));
      await tester.pump();
      
      // Enter first "+"
      await tester.tap(find.text('+'));
      await tester.pump();
      
      // Enter second "+" (this creates consecutive operators)
      await tester.tap(find.text('+'));
      await tester.pump();
      
      // Enter "3"
      await tester.tap(find.text('3'));
      await tester.pump();

      // Verify expression is "2++3" (consecutive operators entered)
      expect(bloc.state.expression.value, equals('2++3'));

      // Tap equals to trigger evaluation
      await tester.tap(find.byKey(const Key('equals_button')));
      await tester.pump();

      // Verify error state is triggered (this triggers the BlocListener to show toast)
      expect(bloc.state.isEvaluationError, isTrue);
      expect(bloc.state.evaluationError, isNotNull);
      
      // The validation catches "Invalid consecutive operators"
      expect(bloc.state.evaluationError, contains('consecutive'));
    });

    testWidgets('expression ending with operator triggers error with descriptive message', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter "5+" - incomplete expression ending with operator
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('+'));
      await tester.pump();

      // Tap equals
      await tester.tap(find.byKey(const Key('equals_button')));
      await tester.pump();

      // Verify error state with descriptive message
      expect(bloc.state.isEvaluationError, isTrue);
      expect(bloc.state.evaluationError, contains('operator'));
    });

    testWidgets('unbalanced parentheses triggers error with descriptive message', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter "(5" - unbalanced parentheses
      await tester.tap(find.byKey(const Key('parenthesis_button')));
      await tester.pump();
      await tester.tap(find.text('5'));
      await tester.pump();

      // Tap equals
      await tester.tap(find.byKey(const Key('equals_button')));
      await tester.pump();

      // Verify error state with parenthesis-related error
      expect(bloc.state.isEvaluationError, isTrue);
      expect(bloc.state.evaluationError, contains('parenthesis'));
    });

    testWidgets('valid expression does not trigger error state', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter valid expression: 2+3
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('+'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();

      // Tap equals
      await tester.tap(find.byKey(const Key('equals_button')));
      await tester.pump();

      // No error state should be triggered
      expect(bloc.state.isEvaluationError, isFalse);
      expect(bloc.state.evaluationError, isNull);
      
      // Result should be computed
      expect(bloc.state.result, equals('5'));
    });

    testWidgets('expression with only minus operator triggers error', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter just "-" (allowed as negative sign)
      await tester.tap(find.text('-'));
      await tester.pump();

      // Tap equals
      await tester.tap(find.byKey(const Key('equals_button')));
      await tester.pump();

      // Error state should be triggered for invalid expression
      expect(bloc.state.isEvaluationError, isTrue);
      expect(bloc.state.evaluationError, isNotNull);
    });

    testWidgets('error state is properly set for BlocListener to trigger toast', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initial state - no error
      expect(bloc.state.isEvaluationError, isFalse);

      // Type valid expression parts
      await tester.tap(find.text('5'));
      await tester.pump();
      
      // Still no error
      expect(bloc.state.isEvaluationError, isFalse);

      await tester.tap(find.text('+'));
      await tester.pump();

      // Trigger error
      await tester.tap(find.byKey(const Key('equals_button')));
      await tester.pump();

      // Now should be in error state
      expect(bloc.state.isEvaluationError, isTrue);
      expect(bloc.state.evaluationError, isNotNull);
      
      // The evaluationError message is what gets displayed in the toast
      expect(bloc.state.evaluationError!.length, greaterThan(0));
    });
  });

  group('Equals Button Styling', () {
    testWidgets('equals button displays = label', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find equals button by key
      final equalsButton = find.byKey(const Key('equals_button'));
      expect(equalsButton, findsOneWidget);

      // Verify it displays '='
      expect(
        find.descendant(
          of: equalsButton,
          matching: find.text('='),
        ),
        findsOneWidget,
      );
    });

    testWidgets('equals button has orange background color (#FF9500)', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final equalsButtonFinder = find.byKey(const Key('equals_button'));
      expect(equalsButtonFinder, findsOneWidget);

      // Find the Container within the equals button
      final container = tester.widget<Container>(
        find.descendant(
          of: equalsButtonFinder,
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      
      // Verify orange background color (#FF9500)
      expect(decoration.color, equals(const Color(0xFFFF9500)));
      expect(decoration.color, equals(CalculatorColors.equalsButtonBackground));
    });

    testWidgets('equals button uses EqualsButtonConfig colors', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final equalsButtonFinder = find.byKey(const Key('equals_button'));
      
      final container = tester.widget<Container>(
        find.descendant(
          of: equalsButtonFinder,
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      
      // Verify it uses the configured background color
      expect(decoration.color, equals(EqualsButtonConfig.backgroundColor));
    });

    testWidgets('equals button has circular shape', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final equalsButtonFinder = find.byKey(const Key('equals_button'));
      
      final container = tester.widget<Container>(
        find.descendant(
          of: equalsButtonFinder,
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      
      // Verify circular shape
      expect(decoration.shape, equals(BoxShape.circle));
    });

    testWidgets('equals button text has white color', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final equalsButtonFinder = find.byKey(const Key('equals_button'));
      
      final textWidget = tester.widget<Text>(
        find.descendant(
          of: equalsButtonFinder,
          matching: find.text('='),
        ),
      );

      // Verify white text color
      expect(textWidget.style?.color, equals(Colors.white));
      expect(textWidget.style?.color, equals(EqualsButtonConfig.textColor));
    });

    testWidgets('equals button has correct font size', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final equalsButtonFinder = find.byKey(const Key('equals_button'));
      
      final textWidget = tester.widget<Text>(
        find.descendant(
          of: equalsButtonFinder,
          matching: find.text('='),
        ),
      );

      // Verify font size
      expect(textWidget.style?.fontSize, equals(24));
    });

    testWidgets('equals button has correct font weight', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final equalsButtonFinder = find.byKey(const Key('equals_button'));
      
      final textWidget = tester.widget<Text>(
        find.descendant(
          of: equalsButtonFinder,
          matching: find.text('='),
        ),
      );

      // Verify font weight
      expect(textWidget.style?.fontWeight, equals(FontWeight.w500));
    });

    testWidgets('equals button triggers evaluation on tap', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter valid expression
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('+'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();

      // Tap equals button
      await tester.tap(find.byKey(const Key('equals_button')));
      await tester.pump();

      // Verify result is computed
      expect(bloc.state.result, equals('4'));
    });
  });

  group('Division by Zero', () {
    testWidgets('division by zero shows result, not error state', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter 5÷0 - use button finder to avoid ambiguity with display
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('÷'));
      await tester.pump();
      
      // Find the '0' button specifically (the one in the button grid)
      final zeroButtons = find.text('0');
      // There are 2 '0' texts - one in display (48px) and one in button (24px)
      // We need to tap the button one
      final allZeroWidgets = tester.widgetList<Text>(zeroButtons);
      for (final widget in allZeroWidgets) {
        if (widget.style?.fontSize == 24) {
          // This is the button
          await tester.tap(find.byWidget(widget));
          break;
        }
      }
      await tester.pump();

      // Tap equals
      await tester.tap(find.byKey(const Key('equals_button')));
      await tester.pump();

      // Should show result (Infinity), not error state
      expect(bloc.state.isEvaluationError, isFalse);
      expect(bloc.state.result, isNotNull);
    });
  });

  group('Expression Display Integration', () {
    testWidgets('expression updates as buttons are tapped', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();

      expect(bloc.state.expression.value, equals('123'));
    });

    testWidgets('backspace removes last character', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      
      await tester.tap(find.text('⌫'));
      await tester.pump();

      expect(bloc.state.expression.value, equals('1'));
    });
  });

  group('BlocListener behavior', () {
    testWidgets('error state transition happens correctly', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initial state - no error
      expect(bloc.state.isEvaluationError, isFalse);

      // Type valid expression parts
      await tester.tap(find.text('5'));
      await tester.pump();
      
      // Still no error
      expect(bloc.state.isEvaluationError, isFalse);

      await tester.tap(find.text('+'));
      await tester.pump();

      // Trigger error
      await tester.tap(find.byKey(const Key('equals_button')));
      await tester.pump();

      // Now should be in error state
      expect(bloc.state.isEvaluationError, isTrue);
    });

    testWidgets('calculator screen has BlocListener configured', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify there is at least one BlocListener for ExpressionDisplayBloc
      // (there may be multiple due to test setup)
      expect(
        find.byType(BlocListener<ExpressionDisplayBloc, ExpressionDisplayState>), 
        findsAtLeastNWidgets(1),
      );
    });
  });
}
