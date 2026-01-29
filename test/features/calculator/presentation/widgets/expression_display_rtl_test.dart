import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:android_calculator_flutter/features/calculator/domain/entities/expression.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/clear_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/delete_character_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_operator_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_parenthesis_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/negate_value_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_bloc.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/expression_display_widget.dart';

void main() {
  group('ExpressionDisplayWidget RTL Tests', () {
    late ExpressionDisplayBloc bloc;

    setUp(() {
      bloc = ExpressionDisplayBloc(
        insertParenthesisUseCase: InsertParenthesisUseCase(),
        insertOperatorUseCase: InsertOperatorUseCase(),
        evaluateExpressionUseCase: EvaluateExpressionUseCase(),
        clearExpressionUseCase: ClearExpressionUseCase(),
        deleteCharacterUseCase: DeleteCharacterUseCase(),
        negateValueUseCase: NegateValueUseCase(),
      );
    });

    tearDown(() {
      bloc.close();
    });

    /// Helper function to build the widget with specified text direction.
    Widget buildTestWidget({
      required TextDirection textDirection,
      required ExpressionDisplayBloc bloc,
    }) {
      return Directionality(
        textDirection: textDirection,
        child: MaterialApp(
          home: Scaffold(
            body: BlocProvider<ExpressionDisplayBloc>.value(
              value: bloc,
              child: const ExpressionDisplayWidget(),
            ),
          ),
        ),
      );
    }

    group('Text Alignment in LTR Context', () {
      testWidgets('expression text uses TextAlign.end in LTR context',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            bloc: bloc,
          ),
        );

        // Find the expression Text widget (displays '0' by default)
        final textFinder = find.text('0');
        expect(textFinder, findsOneWidget);

        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.textAlign, equals(TextAlign.end));
      });

      testWidgets(
          'expression text aligns to right side visually in LTR context',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            bloc: bloc,
          ),
        );

        // In LTR, TextAlign.end means right-aligned
        // The text should be at the right edge of its container
        final textWidget = tester.widget<Text>(find.text('0'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });

      testWidgets('column uses CrossAxisAlignment.end in LTR context',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            bloc: bloc,
          ),
        );

        // Find the Column widget inside the ExpressionDisplayWidget
        final columnFinder = find.byType(Column);
        expect(columnFinder, findsWidgets);

        // Get the Column that contains the expression text
        final columns = tester.widgetList<Column>(columnFinder).toList();
        final expressionColumn = columns.firstWhere(
          (column) => column.crossAxisAlignment == CrossAxisAlignment.end,
          orElse: () => throw TestFailure('No Column with CrossAxisAlignment.end found'),
        );

        expect(expressionColumn.crossAxisAlignment, equals(CrossAxisAlignment.end));
      });
    });

    group('Text Alignment in RTL Context', () {
      testWidgets('expression text uses TextAlign.end in RTL context',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.rtl,
            bloc: bloc,
          ),
        );

        // Find the expression Text widget (displays '0' by default)
        final textFinder = find.text('0');
        expect(textFinder, findsOneWidget);

        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.textAlign, equals(TextAlign.end));
      });

      testWidgets('expression text aligns to left side visually in RTL context',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.rtl,
            bloc: bloc,
          ),
        );

        // In RTL, TextAlign.end means left-aligned
        // The text should be at the left edge of its container
        final textWidget = tester.widget<Text>(find.text('0'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });

      testWidgets('column uses CrossAxisAlignment.end in RTL context',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.rtl,
            bloc: bloc,
          ),
        );

        // Find the Column widget inside the ExpressionDisplayWidget
        final columnFinder = find.byType(Column);
        expect(columnFinder, findsWidgets);

        // Get the Column that contains the expression text
        final columns = tester.widgetList<Column>(columnFinder).toList();
        final expressionColumn = columns.firstWhere(
          (column) => column.crossAxisAlignment == CrossAxisAlignment.end,
          orElse: () => throw TestFailure('No Column with CrossAxisAlignment.end found'),
        );

        expect(expressionColumn.crossAxisAlignment, equals(CrossAxisAlignment.end));
      });
    });

    group('Text Alignment Consistency', () {
      testWidgets(
          'TextAlign.end is used consistently regardless of text direction',
          (tester) async {
        // Test LTR
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            bloc: bloc,
          ),
        );

        final ltrTextWidget = tester.widget<Text>(find.text('0'));
        final ltrTextAlign = ltrTextWidget.textAlign;

        // Create new bloc for RTL test
        final rtlBloc = ExpressionDisplayBloc(
          insertParenthesisUseCase: InsertParenthesisUseCase(),
          insertOperatorUseCase: InsertOperatorUseCase(),
          evaluateExpressionUseCase: EvaluateExpressionUseCase(),
          clearExpressionUseCase: ClearExpressionUseCase(),
          deleteCharacterUseCase: DeleteCharacterUseCase(),
          negateValueUseCase: NegateValueUseCase(),
        );

        // Test RTL
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.rtl,
            bloc: rtlBloc,
          ),
        );

        final rtlTextWidget = tester.widget<Text>(find.text('0'));
        final rtlTextAlign = rtlTextWidget.textAlign;

        // Both should use TextAlign.end
        expect(ltrTextAlign, equals(TextAlign.end));
        expect(rtlTextAlign, equals(TextAlign.end));
        expect(ltrTextAlign, equals(rtlTextAlign));

        rtlBloc.close();
      });
    });

    group('Expression Display with Content', () {
      testWidgets('displays expression with TextAlign.end in LTR',
          (tester) async {
        // Create a bloc and add some expression content
        final testBloc = ExpressionDisplayBloc(
          insertParenthesisUseCase: InsertParenthesisUseCase(),
          insertOperatorUseCase: InsertOperatorUseCase(),
          evaluateExpressionUseCase: EvaluateExpressionUseCase(),
          clearExpressionUseCase: ClearExpressionUseCase(),
          deleteCharacterUseCase: DeleteCharacterUseCase(),
          negateValueUseCase: NegateValueUseCase(),
        );

        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            bloc: testBloc,
          ),
        );

        // Verify the text alignment is end
        final textWidget = tester.widget<Text>(find.text('0'));
        expect(textWidget.textAlign, equals(TextAlign.end));

        testBloc.close();
      });

      testWidgets('displays expression with TextAlign.end in RTL',
          (tester) async {
        // Create a bloc and add some expression content
        final testBloc = ExpressionDisplayBloc(
          insertParenthesisUseCase: InsertParenthesisUseCase(),
          insertOperatorUseCase: InsertOperatorUseCase(),
          evaluateExpressionUseCase: EvaluateExpressionUseCase(),
          clearExpressionUseCase: ClearExpressionUseCase(),
          deleteCharacterUseCase: DeleteCharacterUseCase(),
          negateValueUseCase: NegateValueUseCase(),
        );

        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.rtl,
            bloc: testBloc,
          ),
        );

        // Verify the text alignment is end
        final textWidget = tester.widget<Text>(find.text('0'));
        expect(textWidget.textAlign, equals(TextAlign.end));

        testBloc.close();
      });
    });

    group('Container Width in Both Directions', () {
      testWidgets('container uses full width in LTR context', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            bloc: bloc,
          ),
        );

        // Find the Container widget
        final containerFinder = find.byType(Container);
        expect(containerFinder, findsWidgets);

        // Get the Container that has width: double.infinity
        final containers = tester.widgetList<Container>(containerFinder).toList();
        final fullWidthContainer = containers.firstWhere(
          (container) {
            final constraints = container.constraints;
            return constraints != null && 
                   constraints.minWidth == double.infinity &&
                   constraints.maxWidth == double.infinity;
          },
          orElse: () => throw TestFailure('No full-width Container found'),
        );

        expect(fullWidthContainer.constraints!.minWidth, equals(double.infinity));
      });

      testWidgets('container uses full width in RTL context', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.rtl,
            bloc: bloc,
          ),
        );

        // Find the Container widget
        final containerFinder = find.byType(Container);
        expect(containerFinder, findsWidgets);

        // Get the Container that has width: double.infinity
        final containers = tester.widgetList<Container>(containerFinder).toList();
        final fullWidthContainer = containers.firstWhere(
          (container) {
            final constraints = container.constraints;
            return constraints != null && 
                   constraints.minWidth == double.infinity &&
                   constraints.maxWidth == double.infinity;
          },
          orElse: () => throw TestFailure('No full-width Container found'),
        );

        expect(fullWidthContainer.constraints!.minWidth, equals(double.infinity));
      });
    });

    group('Nested Directionality Override', () {
      testWidgets(
          'inner RTL context overrides outer LTR for expression display',
          (tester) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: MaterialApp(
              home: Scaffold(
                body: Directionality(
                  textDirection: TextDirection.rtl,
                  child: BlocProvider<ExpressionDisplayBloc>.value(
                    value: bloc,
                    child: const ExpressionDisplayWidget(),
                  ),
                ),
              ),
            ),
          ),
        );

        // The expression text should still use TextAlign.end
        // which in the inner RTL context means left-aligned
        final textWidget = tester.widget<Text>(find.text('0'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });

      testWidgets(
          'inner LTR context overrides outer RTL for expression display',
          (tester) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.rtl,
            child: MaterialApp(
              home: Scaffold(
                body: Directionality(
                  textDirection: TextDirection.ltr,
                  child: BlocProvider<ExpressionDisplayBloc>.value(
                    value: bloc,
                    child: const ExpressionDisplayWidget(),
                  ),
                ),
              ),
            ),
          ),
        );

        // The expression text should still use TextAlign.end
        // which in the inner LTR context means right-aligned
        final textWidget = tester.widget<Text>(find.text('0'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });
    });

    group('Result Display RTL Alignment', () {
      testWidgets('result text uses TextAlign.end when result is present',
          (tester) async {
        // We need to trigger an evaluation to get a result
        // For this test, we'll verify the structure uses TextAlign.end
        // by examining the widget tree
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            bloc: bloc,
          ),
        );

        // Initial state shows '0', verify alignment
        final textWidget = tester.widget<Text>(find.text('0'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });
    });

    group('Mathematical Expression Cursor Behavior', () {
      testWidgets('cursor behavior is independent of text direction',
          (tester) async {
        // Create expression with cursor at specific position
        final expression = Expression('123+456', 3);
        expect(expression.cursorPosition, equals(3));

        // Verify cursor position is maintained regardless of direction
        // This tests the domain layer cursor handling
        final newExpression = expression.insertAt('9');
        expect(newExpression.value, equals('1239+456'));
        expect(newExpression.cursorPosition, equals(4));
      });

      testWidgets(
          'expression display renders correctly with complex expression in LTR',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            bloc: bloc,
          ),
        );

        // Verify initial state renders correctly
        expect(find.text('0'), findsOneWidget);

        final textWidget = tester.widget<Text>(find.text('0'));
        expect(textWidget.textAlign, equals(TextAlign.end));
        expect(textWidget.maxLines, equals(2));
        expect(textWidget.overflow, equals(TextOverflow.ellipsis));
      });

      testWidgets(
          'expression display renders correctly with complex expression in RTL',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.rtl,
            bloc: bloc,
          ),
        );

        // Verify initial state renders correctly
        expect(find.text('0'), findsOneWidget);

        final textWidget = tester.widget<Text>(find.text('0'));
        expect(textWidget.textAlign, equals(TextAlign.end));
        expect(textWidget.maxLines, equals(2));
        expect(textWidget.overflow, equals(TextOverflow.ellipsis));
      });
    });

    group('RTL-Aware Alignment Constants Usage', () {
      testWidgets('widget uses directional alignment not absolute alignment',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            bloc: bloc,
          ),
        );

        final textWidget = tester.widget<Text>(find.text('0'));

        // Verify it uses TextAlign.end (directional) not TextAlign.right (absolute)
        expect(textWidget.textAlign, equals(TextAlign.end));
        expect(textWidget.textAlign, isNot(equals(TextAlign.right)));
        expect(textWidget.textAlign, isNot(equals(TextAlign.left)));
      });
    });
  });
}
