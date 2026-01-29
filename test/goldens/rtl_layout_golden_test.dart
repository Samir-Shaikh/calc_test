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
import 'package:android_calculator_flutter/features/calculator/presentation/screens/calculator_screen.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_button_grid.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/expression_display_widget.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/result_display_widget.dart';

/// Golden tests for RTL (Right-to-Left) layout visual verification.
///
/// These tests visually verify the calculator screen appearance in RTL mode,
/// ensuring proper mirroring and alignment for RTL languages like Arabic,
/// Hebrew, and Persian.
///
/// ## RTL Layout Behavior
///
/// In RTL mode:
/// - The button grid is horizontally mirrored (e.g., C, (), ^, ÷ becomes ÷, ^, (), C)
/// - The backspace button appears on the left side (logical end)
/// - Text alignment uses directional values (TextAlign.end)
/// - Expression display aligns to the left (logical end in RTL)
/// - All calculations produce the same results as LTR mode
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

  /// Helper to create a calculator screen widget in RTL mode.
  Widget createCalculatorScreenRTL({
    double width = 400,
    double height = 800,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
        home: BlocProvider<ExpressionDisplayBloc>.value(
          value: bloc,
          child: SizedBox(
            width: width,
            height: height,
            child: const CalculatorScreen(),
          ),
        ),
      ),
    );
  }

  /// Helper to create a calculator screen widget in LTR mode.
  Widget createCalculatorScreenLTR({
    double width = 400,
    double height = 800,
  }) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BlocProvider<ExpressionDisplayBloc>.value(
          value: bloc,
          child: SizedBox(
            width: width,
            height: height,
            child: const CalculatorScreen(),
          ),
        ),
      ),
    );
  }

  /// Helper to create a button grid widget in RTL mode.
  Widget createButtonGridRTL({
    double width = 400,
    double height = 500,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
        home: Scaffold(
          backgroundColor: Colors.black,
          body: BlocProvider<ExpressionDisplayBloc>.value(
            value: bloc,
            child: SizedBox(
              width: width,
              height: height,
              child: const CalculatorButtonGrid(),
            ),
          ),
        ),
      ),
    );
  }

  /// Helper to create expression display widget in RTL mode.
  /// Uses adequate height (250px) to accommodate the expression and result display.
  Widget createExpressionDisplayRTL({double height = 250}) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
        home: Scaffold(
          backgroundColor: Colors.black,
          body: BlocProvider<ExpressionDisplayBloc>.value(
            value: bloc,
            child: Container(
              key: const Key('expression_display_rtl'),
              width: 400,
              height: height,
              padding: const EdgeInsets.all(16),
              child: const ExpressionDisplayWidget(),
            ),
          ),
        ),
      ),
    );
  }

  /// Helper to create result display widget in RTL mode.
  Widget createResultDisplayRTL({required String result}) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Container(
            key: const Key('result_display_rtl'),
            width: 400,
            height: 100,
            padding: const EdgeInsets.all(16),
            child: ResultDisplayWidget(result: result),
          ),
        ),
      ),
    );
  }

  group('RTL Layout Golden Tests', () {
    group('Calculator Screen RTL Layout', () {
      testWidgets('calculator screen renders correctly in RTL mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorScreenRTL());
        await tester.pumpAndSettle();

        // Capture golden image of calculator screen in RTL mode
        await expectLater(
          find.byType(CalculatorScreen),
          matchesGoldenFile('calculator_screen_rtl.png'),
        );
      });

      testWidgets('calculator screen RTL with expression displays correctly',
          (WidgetTester tester) async {
        // Add an expression to display
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const NumericPressed('5'));
        bloc.add(const NumericPressed('6'));

        await tester.pumpWidget(createCalculatorScreenRTL());
        await tester.pumpAndSettle();

        // Capture golden image of calculator with expression in RTL mode
        await expectLater(
          find.byType(CalculatorScreen),
          matchesGoldenFile('calculator_screen_rtl_with_expression.png'),
        );
      });

      testWidgets('calculator screen RTL with result displays correctly',
          (WidgetTester tester) async {
        // Add an expression and evaluate
        bloc.add(const NumericPressed('2'));
        bloc.add(const NumericPressed('5'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('7'));
        bloc.add(const EqualsPressed());

        await tester.pumpWidget(createCalculatorScreenRTL());
        await tester.pumpAndSettle();

        // Capture golden image of calculator with result in RTL mode
        await expectLater(
          find.byType(CalculatorScreen),
          matchesGoldenFile('calculator_screen_rtl_with_result.png'),
        );
      });
    });

    group('Button Grid RTL Mirroring', () {
      testWidgets('button grid is horizontally mirrored in RTL mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createButtonGridRTL());
        await tester.pumpAndSettle();

        // Capture golden image of button grid in RTL mode
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('button_grid_rtl.png'),
        );
      });

      testWidgets('operator column is on the left in RTL mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createButtonGridRTL());
        await tester.pumpAndSettle();

        // Verify operator positions - they should be on the left in RTL
        final divideX = tester.getCenter(find.text('÷')).dx;
        final digit7X = tester.getCenter(find.text('7')).dx;

        // In RTL, operator (÷) should be to the left of digit 7
        expect(divideX, lessThan(digit7X),
            reason: 'In RTL, operator column should be on the left');

        // Capture golden showing operator column on left
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('button_grid_rtl_operator_column_left.png'),
        );
      });

      testWidgets('digit row 7-8-9 is mirrored to 9-8-7 in RTL mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createButtonGridRTL());
        await tester.pumpAndSettle();

        // Get positions
        final pos7 = tester.getCenter(find.text('7')).dx;
        final pos8 = tester.getCenter(find.text('8')).dx;
        final pos9 = tester.getCenter(find.text('9')).dx;

        // In RTL: 9 should be left of 8, and 8 should be left of 7
        expect(pos9, lessThan(pos8), reason: 'In RTL, 9 should be left of 8');
        expect(pos8, lessThan(pos7), reason: 'In RTL, 8 should be left of 7');

        // Capture golden showing mirrored digit row
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('button_grid_rtl_digit_row_mirrored.png'),
        );
      });
    });

    group('Expression Display RTL Alignment', () {
      testWidgets('expression display aligns to left (logical end) in RTL mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createExpressionDisplayRTL());
        await tester.pumpAndSettle();

        // Capture golden image of expression display in RTL mode
        await expectLater(
          find.byKey(const Key('expression_display_rtl')),
          matchesGoldenFile('expression_display_rtl_alignment.png'),
        );
      });

      testWidgets('expression with numbers displays correctly in RTL mode',
          (WidgetTester tester) async {
        // Add expression
        bloc.add(const NumericPressed('9'));
        bloc.add(const NumericPressed('8'));
        bloc.add(const NumericPressed('7'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NumericPressed('6'));
        bloc.add(const NumericPressed('5'));
        bloc.add(const NumericPressed('4'));

        await tester.pumpWidget(createExpressionDisplayRTL());
        await tester.pumpAndSettle();

        // Capture golden image of expression in RTL mode
        await expectLater(
          find.byKey(const Key('expression_display_rtl')),
          matchesGoldenFile('expression_display_rtl_with_numbers.png'),
        );
      });
    });

    group('Result Display RTL Alignment', () {
      testWidgets('result display aligns to left (logical end) in RTL mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createResultDisplayRTL(result: '42'));
        await tester.pumpAndSettle();

        // Capture golden image of result display in RTL mode
        await expectLater(
          find.byKey(const Key('result_display_rtl')),
          matchesGoldenFile('result_display_rtl_alignment.png'),
        );
      });

      testWidgets('negative result displays correctly in RTL mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createResultDisplayRTL(result: '-123.45'));
        await tester.pumpAndSettle();

        // Capture golden image of negative result in RTL mode
        await expectLater(
          find.byKey(const Key('result_display_rtl')),
          matchesGoldenFile('result_display_rtl_negative.png'),
        );
      });

      testWidgets('large result displays correctly in RTL mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createResultDisplayRTL(result: '9876543210'));
        await tester.pumpAndSettle();

        // Capture golden image of large result in RTL mode
        await expectLater(
          find.byKey(const Key('result_display_rtl')),
          matchesGoldenFile('result_display_rtl_large_number.png'),
        );
      });
    });

    group('LTR vs RTL Layout Comparison', () {
      testWidgets('RTL layout mirrors LTR correctly',
          (WidgetTester tester) async {
        // First capture LTR layout
        final ltrBloc = ExpressionDisplayBloc(
          insertParenthesisUseCase: insertParenthesisUseCase,
          insertOperatorUseCase: insertOperatorUseCase,
          evaluateExpressionUseCase: evaluateExpressionUseCase,
          clearExpressionUseCase: clearExpressionUseCase,
          deleteCharacterUseCase: deleteCharacterUseCase,
          negateValueUseCase: negateValueUseCase,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: BlocProvider<ExpressionDisplayBloc>.value(
                value: ltrBloc,
                child: const SizedBox(
                  width: 400,
                  height: 800,
                  child: CalculatorScreen(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(CalculatorScreen),
          matchesGoldenFile('calculator_screen_ltr_comparison.png'),
        );

        ltrBloc.close();

        // Now capture RTL layout for comparison
        await tester.pumpWidget(createCalculatorScreenRTL());
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(CalculatorScreen),
          matchesGoldenFile('calculator_screen_rtl_comparison.png'),
        );
      });

      testWidgets('button positions are horizontally mirrored between LTR and RTL',
          (WidgetTester tester) async {
        // Test LTR positions
        final ltrBloc = ExpressionDisplayBloc(
          insertParenthesisUseCase: insertParenthesisUseCase,
          insertOperatorUseCase: insertOperatorUseCase,
          evaluateExpressionUseCase: evaluateExpressionUseCase,
          clearExpressionUseCase: clearExpressionUseCase,
          deleteCharacterUseCase: deleteCharacterUseCase,
          negateValueUseCase: negateValueUseCase,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                backgroundColor: Colors.black,
                body: BlocProvider<ExpressionDisplayBloc>.value(
                  value: ltrBloc,
                  child: const SizedBox(
                    width: 400,
                    height: 500,
                    child: CalculatorButtonGrid(),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final ltrClearX = tester.getCenter(find.text('C')).dx;
        final ltrDivideX = tester.getCenter(find.text('÷')).dx;

        // In LTR: C is on the left, ÷ is on the right
        expect(ltrClearX, lessThan(ltrDivideX),
            reason: 'In LTR, C should be to the left of ÷');

        ltrBloc.close();

        // Test RTL positions
        await tester.pumpWidget(createButtonGridRTL());
        await tester.pumpAndSettle();

        final rtlClearX = tester.getCenter(find.text('C')).dx;
        final rtlDivideX = tester.getCenter(find.text('÷')).dx;

        // In RTL: ÷ is on the left, C is on the right (mirrored)
        expect(rtlDivideX, lessThan(rtlClearX),
            reason: 'In RTL, ÷ should be to the left of C');

        // Capture golden for RTL button grid mirroring
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('button_grid_rtl_mirrored_comparison.png'),
        );
      });
    });

    group('Edge Cases - Long Expressions in RTL', () {
      testWidgets('long expression displays correctly in RTL mode',
          (WidgetTester tester) async {
        // Add a long expression
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const NumericPressed('5'));
        bloc.add(const NumericPressed('6'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NumericPressed('7'));
        bloc.add(const NumericPressed('8'));
        bloc.add(const NumericPressed('9'));
        bloc.add(const OperatorPressed('-'));
        bloc.add(const NumericPressed('9'));
        bloc.add(const NumericPressed('8'));
        bloc.add(const NumericPressed('7'));

        await tester.pumpWidget(createExpressionDisplayRTL(height: 300));
        await tester.pumpAndSettle();

        // Capture golden image of long expression in RTL mode
        await expectLater(
          find.byKey(const Key('expression_display_rtl')),
          matchesGoldenFile('expression_display_rtl_long_expression.png'),
        );
      });

      testWidgets('expression with parentheses displays correctly in RTL mode',
          (WidgetTester tester) async {
        // Add expression with parentheses
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('0'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('5'));
        bloc.add(const ParenthesisPressed()); // )
        bloc.add(const OperatorPressed('×'));
        bloc.add(const ParenthesisPressed()); // (
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('-'));
        bloc.add(const NumericPressed('1'));
        bloc.add(const ParenthesisPressed()); // )

        await tester.pumpWidget(createExpressionDisplayRTL(height: 300));
        await tester.pumpAndSettle();

        // Capture golden image of expression with parentheses in RTL mode
        await expectLater(
          find.byKey(const Key('expression_display_rtl')),
          matchesGoldenFile('expression_display_rtl_parentheses.png'),
        );
      });

      testWidgets('expression with decimal numbers displays correctly in RTL mode',
          (WidgetTester tester) async {
        // Add expression with decimals
        bloc.add(const NumericPressed('3'));
        bloc.add(const DecimalPressed());
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('5'));
        bloc.add(const NumericPressed('9'));
        bloc.add(const OperatorPressed('×'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const DecimalPressed());
        bloc.add(const NumericPressed('7'));
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('8'));

        await tester.pumpWidget(createExpressionDisplayRTL(height: 300));
        await tester.pumpAndSettle();

        // Capture golden image of decimal expression in RTL mode
        await expectLater(
          find.byKey(const Key('expression_display_rtl')),
          matchesGoldenFile('expression_display_rtl_decimal.png'),
        );
      });

      testWidgets('expression with power operator displays correctly in RTL mode',
          (WidgetTester tester) async {
        // Add expression with power
        bloc.add(const NumericPressed('2'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('0'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const PowerOperatorPressed());
        bloc.add(const NumericPressed('4'));

        await tester.pumpWidget(createExpressionDisplayRTL(height: 300));
        await tester.pumpAndSettle();

        // Capture golden image of power expression in RTL mode
        await expectLater(
          find.byKey(const Key('expression_display_rtl')),
          matchesGoldenFile('expression_display_rtl_power.png'),
        );
      });

      testWidgets('negative number expression displays correctly in RTL mode',
          (WidgetTester tester) async {
        // Add expression with negative number
        bloc.add(const NumericPressed('5'));
        bloc.add(const NegatePressed());
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('0'));

        await tester.pumpWidget(createExpressionDisplayRTL());
        await tester.pumpAndSettle();

        // Capture golden image of negative expression in RTL mode
        await expectLater(
          find.byKey(const Key('expression_display_rtl')),
          matchesGoldenFile('expression_display_rtl_negative_number.png'),
        );
      });

      testWidgets('very long expression with overflow displays correctly in RTL mode',
          (WidgetTester tester) async {
        // Add a very long expression that might overflow
        for (int i = 0; i < 5; i++) {
          bloc.add(const NumericPressed('9'));
          bloc.add(const NumericPressed('9'));
          bloc.add(const NumericPressed('9'));
          if (i < 4) {
            bloc.add(const OperatorPressed('+'));
          }
        }

        await tester.pumpWidget(createExpressionDisplayRTL(height: 300));
        await tester.pumpAndSettle();

        // Capture golden image of overflowing expression in RTL mode
        await expectLater(
          find.byKey(const Key('expression_display_rtl')),
          matchesGoldenFile('expression_display_rtl_overflow.png'),
        );
      });
    });

    group('Calculator Screen RTL at Different Screen Sizes', () {
      testWidgets('calculator screen RTL renders correctly on phone portrait',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorScreenRTL(
          width: 360,
          height: 640,
        ));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(CalculatorScreen),
          matchesGoldenFile('calculator_screen_rtl_phone_portrait.png'),
        );
      });

      testWidgets('calculator screen RTL renders correctly on phone landscape',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorScreenRTL(
          width: 640,
          height: 360,
        ));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(CalculatorScreen),
          matchesGoldenFile('calculator_screen_rtl_phone_landscape.png'),
        );
      });

      testWidgets('calculator screen RTL renders correctly on tablet',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorScreenRTL(
          width: 768,
          height: 1024,
        ));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(CalculatorScreen),
          matchesGoldenFile('calculator_screen_rtl_tablet.png'),
        );
      });
    });

    group('RTL Visual Summary', () {
      testWidgets('comprehensive RTL layout visual verification',
          (WidgetTester tester) async {
        // Add some content to show full functionality
        bloc.add(const NumericPressed('1'));
        bloc.add(const NumericPressed('2'));
        bloc.add(const NumericPressed('3'));
        bloc.add(const OperatorPressed('+'));
        bloc.add(const NumericPressed('4'));
        bloc.add(const NumericPressed('5'));
        bloc.add(const NumericPressed('6'));

        await tester.pumpWidget(createCalculatorScreenRTL());
        await tester.pumpAndSettle();

        // Verify basic RTL layout properties
        final clearX = tester.getCenter(find.text('C')).dx;
        final divideX = tester.getCenter(find.text('÷')).dx;
        expect(divideX, lessThan(clearX),
            reason: 'In RTL, ÷ should be to the left of C');

        final digit1X = tester.getCenter(find.text('1')).dx;
        final digit3X = tester.getCenter(find.text('3')).dx;
        expect(digit3X, lessThan(digit1X),
            reason: 'In RTL, 3 should be to the left of 1');

        // Capture comprehensive golden
        await expectLater(
          find.byType(CalculatorScreen),
          matchesGoldenFile('calculator_screen_rtl_comprehensive.png'),
        );
      });
    });
  });
}
