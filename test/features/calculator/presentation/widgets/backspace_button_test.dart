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
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_event.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/theme/calculator_colors.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/theme/calculator_dimensions.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/backspace_button.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/backspace_button_config.dart';

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
          child: const BackspaceButton(),
        ),
      ),
    );
  }

  group('BackspaceButton Widget', () {
    group('Rendering', () {
      testWidgets('renders without errors', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(BackspaceButton), findsOneWidget);
      });

      testWidgets('displays delete/backspace icon', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Verify the backspace icon is displayed
        expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
      });

      testWidgets('uses correct icon from BackspaceButtonConfig',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final iconWidget = tester.widget<Icon>(find.byType(Icon));
        expect(iconWidget.icon, equals(BackspaceButtonConfig.icon));
      });

      testWidgets('contains GestureDetector for tap handling',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(GestureDetector), findsOneWidget);
      });

      testWidgets('contains Container for styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(Container), findsAtLeastNWidgets(1));
      });
    });

    group('Tap Interaction', () {
      testWidgets('dispatches BackspacePressed event when tapped',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // First add some content to the expression
        bloc.add(const NumericPressed('5'));
        bloc.add(const NumericPressed('6'));
        await tester.pump();

        // Verify expression has content
        expect(bloc.state.expression.value, equals('56'));

        // Tap the backspace button
        await tester.tap(find.byType(BackspaceButton));
        await tester.pump();

        // Verify the last character was deleted (BackspacePressed was dispatched)
        expect(bloc.state.expression.value, equals('5'));
      });

      testWidgets('multiple taps delete multiple characters',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Add content to the expression
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const NumericPressed('3'));
        await tester.pump();

        expect(bloc.state.expression.value, equals('123'));

        // Tap backspace twice
        await tester.tap(find.byType(BackspaceButton));
        await tester.pump();
        await tester.tap(find.byType(BackspaceButton));
        await tester.pump();

        // Verify two characters were deleted
        expect(bloc.state.expression.value, equals('1'));
      });

      testWidgets('tap on empty expression does not cause error',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Ensure expression is empty
        expect(bloc.state.expression.value, isEmpty);

        // Tap the backspace button - should not throw
        await tester.tap(find.byType(BackspaceButton));
        await tester.pump();

        // Expression should still be empty
        expect(bloc.state.expression.value, isEmpty);
      });

      testWidgets('clears evaluation error state when tapped',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Enter an invalid expression and trigger error
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const EqualsPressed());
        await tester.pump();

        // Verify error state
        expect(bloc.state.isEvaluationError, isTrue);

        // Add more content and tap backspace
        bloc.add(const NumericPressed('3'));
        await tester.pump();
        await tester.tap(find.byType(BackspaceButton));
        await tester.pump();

        // Error state should be cleared
        expect(bloc.state.isEvaluationError, isFalse);
      });
    });

    group('Accessibility', () {
      testWidgets('has semantic label for screen readers',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final iconWidget = tester.widget<Icon>(find.byType(Icon));
        expect(iconWidget.semanticLabel, equals('Backspace'));
        expect(iconWidget.semanticLabel, equals(BackspaceButtonConfig.semanticLabel));
      });

      testWidgets('icon widget has accessibility label from config',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Verify the icon has the correct semantic label
        final icon = tester.widget<Icon>(find.byIcon(Icons.backspace_outlined));
        expect(icon.semanticLabel, isNotNull);
        expect(icon.semanticLabel, isNotEmpty);
      });
    });

    group('Styling', () {
      testWidgets('has correct button size from CalculatorDimensions',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(BackspaceButton),
            matching: find.byType(Container),
          ).first,
        );

        expect(container.constraints?.maxWidth,
            equals(CalculatorDimensions.backspaceButtonSize));
        expect(container.constraints?.maxHeight,
            equals(CalculatorDimensions.backspaceButtonSize));
      });

      testWidgets('has gray background color (#505050)',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(BackspaceButton),
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, equals(const Color(0xFF505050)));
        expect(decoration.color, equals(CalculatorColors.backspaceButtonBackground));
      });

      testWidgets('has circular shape', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(BackspaceButton),
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.shape, equals(BoxShape.circle));
      });

      testWidgets('icon has white color for contrast',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final iconWidget = tester.widget<Icon>(find.byType(Icon));
        expect(iconWidget.color, equals(Colors.white));
        expect(iconWidget.color, equals(CalculatorColors.lightButtonText));
      });

      testWidgets('icon has correct size from BackspaceButtonConfig',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final iconWidget = tester.widget<Icon>(find.byType(Icon));
        expect(iconWidget.size, equals(24));
        expect(iconWidget.size, equals(BackspaceButtonConfig.iconSize));
      });

      testWidgets('uses decoration from BackspaceButtonConfig',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(BackspaceButton),
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;
        final configDecoration = BackspaceButtonConfig.decoration;

        expect(decoration.color, equals(configDecoration.color));
        expect(decoration.shape, equals(configDecoration.shape));
      });
    });

    group('Icon Widget Configuration', () {
      testWidgets('iconWidget getter returns properly configured icon',
          (WidgetTester tester) async {
        final iconWidget = BackspaceButtonConfig.iconWidget;

        expect(iconWidget.icon, equals(Icons.backspace_outlined));
        expect(iconWidget.size, equals(24));
        expect(iconWidget.color, equals(Colors.white));
        expect(iconWidget.semanticLabel, equals('Backspace'));
      });
    });
  });
}
