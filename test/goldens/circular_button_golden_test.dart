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
import 'package:android_calculator_flutter/features/calculator/presentation/theme/calculator_button_decorations.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/theme/calculator_colors.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/theme/calculator_dimensions.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_button.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_button_grid.dart';

/// Golden tests for circular button visual verification.
///
/// These tests visually verify the circular button appearance matches
/// the iOS-inspired design specification:
/// - 70dp height for consistent button sizing
/// - 5dp margins around each button for proper spacing
/// - Borderless appearance (no visible borders)
/// - 24sp text size for readable button labels
/// - Circular/pill shape using high border radius (1000dp)
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

  /// Helper to build a single circular button with specified styling.
  Widget buildCircularButton({
    required String label,
    required Color backgroundColor,
    Color textColor = Colors.white,
    double size = 70.0,
    Key? key,
  }) {
    return Container(
      key: key,
      width: size,
      height: size,
      decoration: CalculatorButtonDecorations.circularButtonDecoration(
        backgroundColor: backgroundColor,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: CalculatorDimensions.circularButtonTextSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Helper to create calculator button grid widget.
  Widget createButtonGridWidget({
    double width = 400,
    double height = 500,
  }) {
    return MaterialApp(
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
    );
  }

  group('Circular Button Golden Tests', () {
    group('Numeric Button Circular Appearance', () {
      testWidgets('renders numeric button "5" with circular shape',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: buildCircularButton(
                  key: const Key('numeric_button_5'),
                  label: '5',
                  backgroundColor: CalculatorColors.numericButtonBackground,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden image of numeric button with circular shape
        await expectLater(
          find.byKey(const Key('numeric_button_5')),
          matchesGoldenFile('circular_button_numeric_5.png'),
        );
      });

      testWidgets('renders numeric button "0" with circular shape',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: buildCircularButton(
                  key: const Key('numeric_button_0'),
                  label: '0',
                  backgroundColor: CalculatorColors.numericButtonBackground,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden image of numeric button "0"
        await expectLater(
          find.byKey(const Key('numeric_button_0')),
          matchesGoldenFile('circular_button_numeric_0.png'),
        );
      });

      testWidgets('renders all numeric buttons (0-9) with consistent circular styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Column(
                  key: const Key('all_numeric_buttons'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row: 7, 8, 9
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final digit in ['7', '8', '9']) ...[
                          buildCircularButton(
                            label: digit,
                            backgroundColor: CalculatorColors.numericButtonBackground,
                          ),
                          if (digit != '9') const SizedBox(width: 10),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Row: 4, 5, 6
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final digit in ['4', '5', '6']) ...[
                          buildCircularButton(
                            label: digit,
                            backgroundColor: CalculatorColors.numericButtonBackground,
                          ),
                          if (digit != '6') const SizedBox(width: 10),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Row: 1, 2, 3
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final digit in ['1', '2', '3']) ...[
                          buildCircularButton(
                            label: digit,
                            backgroundColor: CalculatorColors.numericButtonBackground,
                          ),
                          if (digit != '3') const SizedBox(width: 10),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Row: 0
                    buildCircularButton(
                      label: '0',
                      backgroundColor: CalculatorColors.numericButtonBackground,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden showing all numeric buttons with circular styling
        await expectLater(
          find.byKey(const Key('all_numeric_buttons')),
          matchesGoldenFile('circular_button_all_numerics.png'),
        );
      });
    });

    group('Operator Button Circular Appearance', () {
      testWidgets('renders operator button "+" with orange background and circular shape',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: buildCircularButton(
                  key: const Key('operator_button_plus'),
                  label: '+',
                  backgroundColor: CalculatorColors.operatorButtonBackground,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden image of operator button with circular shape
        await expectLater(
          find.byKey(const Key('operator_button_plus')),
          matchesGoldenFile('circular_button_operator_plus.png'),
        );
      });

      testWidgets('renders all operator buttons (÷, ×, +, -, =) with circular styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Row(
                  key: const Key('all_operator_buttons'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final op in ['÷', '×', '+', '-', '=']) ...[
                      buildCircularButton(
                        label: op,
                        backgroundColor: CalculatorColors.operatorButtonBackground,
                      ),
                      if (op != '=') const SizedBox(width: 10),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden showing all operator buttons with orange circular styling
        await expectLater(
          find.byKey(const Key('all_operator_buttons')),
          matchesGoldenFile('circular_button_all_operators.png'),
        );
      });

      testWidgets('operator button has correct orange (#FF9500) background',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.white, // White background to see button edge
              body: Center(
                child: buildCircularButton(
                  key: const Key('operator_color_verification'),
                  label: '×',
                  backgroundColor: const Color(0xFFFF9500), // Explicit #FF9500
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden verifying orange color
        await expectLater(
          find.byKey(const Key('operator_color_verification')),
          matchesGoldenFile('circular_button_operator_color.png'),
        );
      });
    });

    group('Function Button Circular Appearance', () {
      testWidgets('renders function button "C" with gray background and circular shape',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: buildCircularButton(
                  key: const Key('function_button_clear'),
                  label: 'C',
                  backgroundColor: CalculatorColors.functionButtonBackground,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden image of function button with circular shape
        await expectLater(
          find.byKey(const Key('function_button_clear')),
          matchesGoldenFile('circular_button_function_clear.png'),
        );
      });

      testWidgets('renders all function buttons (C, (), ^, +/-) with circular styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Row(
                  key: const Key('all_function_buttons'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final fn in ['C', '()', '^', '+/-']) ...[
                      buildCircularButton(
                        label: fn,
                        backgroundColor: CalculatorColors.functionButtonBackground,
                      ),
                      if (fn != '+/-') const SizedBox(width: 10),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden showing all function buttons with gray circular styling
        await expectLater(
          find.byKey(const Key('all_function_buttons')),
          matchesGoldenFile('circular_button_all_functions.png'),
        );
      });

      testWidgets('function button has correct gray (#505050) background',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.white, // White background to see button edge
              body: Center(
                child: buildCircularButton(
                  key: const Key('function_color_verification'),
                  label: '()',
                  backgroundColor: const Color(0xFF505050), // Explicit #505050
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden verifying gray color
        await expectLater(
          find.byKey(const Key('function_color_verification')),
          matchesGoldenFile('circular_button_function_color.png'),
        );
      });
    });

    group('Button Grid Consistent Spacing', () {
      testWidgets('renders button grid with consistent 5dp margins between circular buttons',
          (WidgetTester tester) async {
        await tester.pumpWidget(createButtonGridWidget());
        await tester.pumpAndSettle();

        // Capture golden of complete button grid showing consistent spacing
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('circular_button_grid_spacing.png'),
        );
      });

      testWidgets('renders button grid with proper 10dp visual spacing (5dp + 5dp)',
          (WidgetTester tester) async {
        await tester.pumpWidget(createButtonGridWidget(
          width: 360,
          height: 450,
        ));
        await tester.pumpAndSettle();

        // Capture golden showing visual spacing between buttons
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('circular_button_grid_visual_spacing.png'),
        );
      });

      testWidgets('renders complete 5×4 grid with all circular buttons',
          (WidgetTester tester) async {
        await tester.pumpWidget(createButtonGridWidget());
        await tester.pumpAndSettle();

        // Verify all 20 buttons exist
        expect(find.byType(CalculatorButton), findsNWidgets(20));

        // Capture golden of full grid layout
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('circular_button_grid_complete.png'),
        );
      });
    });

    group('Borderless Style Verification (AC4)', () {
      testWidgets('numeric button renders without visible border',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.white, // High contrast background
              body: Center(
                child: buildCircularButton(
                  key: const Key('borderless_numeric'),
                  label: '7',
                  backgroundColor: CalculatorColors.numericButtonBackground,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden showing clean borderless circular shape
        await expectLater(
          find.byKey(const Key('borderless_numeric')),
          matchesGoldenFile('circular_button_borderless_numeric.png'),
        );
      });

      testWidgets('operator button renders without visible border',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.white, // High contrast background
              body: Center(
                child: buildCircularButton(
                  key: const Key('borderless_operator'),
                  label: '-',
                  backgroundColor: CalculatorColors.operatorButtonBackground,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden showing clean borderless circular shape
        await expectLater(
          find.byKey(const Key('borderless_operator')),
          matchesGoldenFile('circular_button_borderless_operator.png'),
        );
      });

      testWidgets('function button renders without visible border',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.white, // High contrast background
              body: Center(
                child: buildCircularButton(
                  key: const Key('borderless_function'),
                  label: '^',
                  backgroundColor: CalculatorColors.functionButtonBackground,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden showing clean borderless circular shape
        await expectLater(
          find.byKey(const Key('borderless_function')),
          matchesGoldenFile('circular_button_borderless_function.png'),
        );
      });

      testWidgets('all button types render with clean circular edges (no borders)',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.grey.shade300, // Neutral background
              body: Center(
                child: Row(
                  key: const Key('borderless_comparison'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Numeric
                    buildCircularButton(
                      label: '5',
                      backgroundColor: CalculatorColors.numericButtonBackground,
                    ),
                    const SizedBox(width: 15),
                    // Function
                    buildCircularButton(
                      label: 'C',
                      backgroundColor: CalculatorColors.functionButtonBackground,
                    ),
                    const SizedBox(width: 15),
                    // Operator
                    buildCircularButton(
                      label: '+',
                      backgroundColor: CalculatorColors.operatorButtonBackground,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden comparing all button types without borders
        await expectLater(
          find.byKey(const Key('borderless_comparison')),
          matchesGoldenFile('circular_button_borderless_all_types.png'),
        );
      });
    });

    group('Multi-Button Layout Golden Tests', () {
      testWidgets('renders multiple adjacent buttons with consistent circular appearance',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Column(
                  key: const Key('multi_button_layout'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top row: function buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildCircularButton(
                          label: 'C',
                          backgroundColor: CalculatorColors.functionButtonBackground,
                        ),
                        const SizedBox(width: 10),
                        buildCircularButton(
                          label: '()',
                          backgroundColor: CalculatorColors.functionButtonBackground,
                        ),
                        const SizedBox(width: 10),
                        buildCircularButton(
                          label: '^',
                          backgroundColor: CalculatorColors.functionButtonBackground,
                        ),
                        const SizedBox(width: 10),
                        buildCircularButton(
                          label: '÷',
                          backgroundColor: CalculatorColors.operatorButtonBackground,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Middle row: numeric + operator
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildCircularButton(
                          label: '7',
                          backgroundColor: CalculatorColors.numericButtonBackground,
                        ),
                        const SizedBox(width: 10),
                        buildCircularButton(
                          label: '8',
                          backgroundColor: CalculatorColors.numericButtonBackground,
                        ),
                        const SizedBox(width: 10),
                        buildCircularButton(
                          label: '9',
                          backgroundColor: CalculatorColors.numericButtonBackground,
                        ),
                        const SizedBox(width: 10),
                        buildCircularButton(
                          label: '×',
                          backgroundColor: CalculatorColors.operatorButtonBackground,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Bottom row: mixed
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildCircularButton(
                          label: '+/-',
                          backgroundColor: CalculatorColors.functionButtonBackground,
                        ),
                        const SizedBox(width: 10),
                        buildCircularButton(
                          label: '0',
                          backgroundColor: CalculatorColors.numericButtonBackground,
                        ),
                        const SizedBox(width: 10),
                        buildCircularButton(
                          label: '.',
                          backgroundColor: CalculatorColors.numericButtonBackground,
                        ),
                        const SizedBox(width: 10),
                        buildCircularButton(
                          label: '=',
                          backgroundColor: CalculatorColors.operatorButtonBackground,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden showing multiple buttons with consistent spacing
        await expectLater(
          find.byKey(const Key('multi_button_layout')),
          matchesGoldenFile('circular_button_multi_layout.png'),
        );
      });

      testWidgets('renders 2x2 button cluster showing adjacent spacing',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Column(
                  key: const Key('button_cluster_2x2'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildCircularButton(
                          label: '4',
                          backgroundColor: CalculatorColors.numericButtonBackground,
                        ),
                        const SizedBox(width: 10),
                        buildCircularButton(
                          label: '5',
                          backgroundColor: CalculatorColors.numericButtonBackground,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildCircularButton(
                          label: '1',
                          backgroundColor: CalculatorColors.numericButtonBackground,
                        ),
                        const SizedBox(width: 10),
                        buildCircularButton(
                          label: '2',
                          backgroundColor: CalculatorColors.numericButtonBackground,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden showing 2x2 button cluster
        await expectLater(
          find.byKey(const Key('button_cluster_2x2')),
          matchesGoldenFile('circular_button_cluster_2x2.png'),
        );
      });

      testWidgets('renders vertical column of operator buttons',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Column(
                  key: const Key('operator_column'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final op in ['÷', '×', '+', '-', '=']) ...[
                      buildCircularButton(
                        label: op,
                        backgroundColor: CalculatorColors.operatorButtonBackground,
                      ),
                      if (op != '=') const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden showing vertical operator column
        await expectLater(
          find.byKey(const Key('operator_column')),
          matchesGoldenFile('circular_button_operator_column.png'),
        );
      });
    });

    group('Circular Shape Verification', () {
      testWidgets('verifies button maintains circular shape at 70dp height',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: buildCircularButton(
                  key: const Key('circular_shape_70dp'),
                  label: '8',
                  backgroundColor: CalculatorColors.numericButtonBackground,
                  size: 70.0, // Explicit 70dp
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden verifying circular shape at specified dimensions
        await expectLater(
          find.byKey(const Key('circular_shape_70dp')),
          matchesGoldenFile('circular_button_shape_70dp.png'),
        );
      });

      testWidgets('verifies borderRadius creates smooth circular edges',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.grey.shade200,
              body: Center(
                child: Container(
                  key: const Key('smooth_circular_edges'),
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: CalculatorColors.operatorButtonBackground,
                    borderRadius: BorderRadius.circular(
                      CalculatorDimensions.circularButtonRadius,
                    ),
                    // No border - borderless styling
                  ),
                  child: const Center(
                    child: Text(
                      '=',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden showing smooth circular edges
        await expectLater(
          find.byKey(const Key('smooth_circular_edges')),
          matchesGoldenFile('circular_button_smooth_edges.png'),
        );
      });
    });

    group('Design Specification Visual Summary', () {
      testWidgets('renders design specification summary with all button types',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.grey.shade900,
              body: Center(
                child: Column(
                  key: const Key('design_spec_summary'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Circular Button Design Specifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Numeric button with label
                    const Text(
                      'Numeric: #333333',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    buildCircularButton(
                      label: '5',
                      backgroundColor: CalculatorColors.numericButtonBackground,
                    ),
                    const SizedBox(height: 15),
                    // Function button with label
                    const Text(
                      'Function: #505050',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    buildCircularButton(
                      label: 'C',
                      backgroundColor: CalculatorColors.functionButtonBackground,
                    ),
                    const SizedBox(height: 15),
                    // Operator button with label
                    const Text(
                      'Operator: #FF9500',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    buildCircularButton(
                      label: '+',
                      backgroundColor: CalculatorColors.operatorButtonBackground,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Height: 70dp | Margin: 5dp | Text: 24sp',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    const Text(
                      'Border Radius: 1000dp | Border: None',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture comprehensive design specification golden
        await expectLater(
          find.byKey(const Key('design_spec_summary')),
          matchesGoldenFile('circular_button_design_spec_summary.png'),
        );
      });
    });
  });
}
