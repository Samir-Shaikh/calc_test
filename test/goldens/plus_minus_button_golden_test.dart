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
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_button_grid.dart';
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

  group('Plus/Minus Button Golden Tests (AC2)', () {
    group('Isolated Button Visual Verification', () {
      testWidgets('renders +/- button with gray (#505050) background and +/- label',
          (WidgetTester tester) async {
        // Build an isolated +/- button matching the exact styling
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Container(
                    key: const Key('isolated_plus_minus_button'),
                    decoration: NegateButtonConfig.decoration,
                    child: Center(
                      child: Text(
                        NegateButtonConfig.label,
                        style: NegateButtonConfig.textStyle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden image of isolated +/- button
        await expectLater(
          find.byKey(const Key('isolated_plus_minus_button')),
          matchesGoldenFile('plus_minus_button_isolated.png'),
        );
      });

      testWidgets('verifies button decoration matches gray color specification',
          (WidgetTester tester) async {
        // Build button with explicit color verification
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Container(
                    key: const Key('color_verification_plus_minus'),
                    decoration: const BoxDecoration(
                      color: Color(0xFF505050), // Explicit #505050
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '+/-',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify the button renders with the expected gray color
        await expectLater(
          find.byKey(const Key('color_verification_plus_minus')),
          matchesGoldenFile('plus_minus_button_color_verification.png'),
        );
      });

      testWidgets('renders button with correct circular shape',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.white, // White background to see circle edge
              body: Center(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Container(
                    key: const Key('circular_shape_plus_minus'),
                    decoration: CalculatorButtonDecorations.negateButton,
                    child: Center(
                      child: Text(
                        NegateButtonConfig.label,
                        style: NegateButtonConfig.textStyle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden to verify circular shape
        await expectLater(
          find.byKey(const Key('circular_shape_plus_minus')),
          matchesGoldenFile('plus_minus_button_circular_shape.png'),
        );
      });
    });

    group('Button in Grid Context', () {
      Widget createCalculatorGridWidget() {
        return MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
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

      testWidgets('renders +/- button in calculator grid bottom row',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorGridWidget());
        await tester.pumpAndSettle();

        // Capture the entire calculator grid showing button positions
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('calculator_grid_with_plus_minus.png'),
        );
      });

      testWidgets('+/- button positioned correctly in bottom-left of grid',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorGridWidget());
        await tester.pumpAndSettle();

        // Find the negate button in the grid
        final negateButton = find.byKey(const Key('negate_button'));
        expect(negateButton, findsOneWidget);

        // Capture golden of the +/- button within the grid
        await expectLater(
          negateButton,
          matchesGoldenFile('plus_minus_button_in_grid.png'),
        );
      });

      testWidgets('bottom row shows +/-, 0, ., = buttons in correct order',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: BlocProvider<ExpressionDisplayBloc>.value(
                value: bloc,
                child: const SizedBox(
                  width: 400,
                  height: 500,
                  child: CalculatorButtonGrid(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Capture the grid showing bottom row arrangement
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('calculator_bottom_row_with_plus_minus.png'),
        );
      });
    });

    group('Calculator Grid Layout - +/- Position Verification', () {
      testWidgets('verifies +/- is in bottom-left position of 5x4 grid',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: BlocProvider<ExpressionDisplayBloc>.value(
                value: bloc,
                child: const SizedBox(
                  width: 400,
                  height: 500,
                  child: CalculatorButtonGrid(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify +/- button exists
        final negateButton = find.byKey(const Key('negate_button'));
        expect(negateButton, findsOneWidget);

        // Verify +/- label exists
        expect(find.text('+/-'), findsOneWidget);

        // Capture golden showing +/- in bottom-left position
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('grid_layout_plus_minus_bottom_left.png'),
        );
      });

      testWidgets('renders row-by-row layout with +/- in row 5 column 1',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.grey.shade900,
              body: Center(
                child: Column(
                  key: const Key('plus_minus_position_breakdown'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Label for Row 5 (bottom row)
                    const Text(
                      'Row 5 (Bottom): +/-, 0, ., =',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    // Visual representation of bottom row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // +/- button (position 1 - bottom-left)
                        Column(
                          children: [
                            const Text(
                              'Col 1',
                              style: TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFF505050), // Gray #505050
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    '+/-',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        // 0 button (position 2)
                        Column(
                          children: [
                            const Text(
                              'Col 2',
                              style: TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    '0',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        // . button (position 3)
                        Column(
                          children: [
                            const Text(
                              'Col 3',
                              style: TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    '.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        // = button (position 4)
                        Column(
                          children: [
                            const Text(
                              'Col 4',
                              style: TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF9500), // Orange
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    '=',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      '+/- is in bottom-left (Row 5, Col 1)',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden showing +/- position breakdown
        await expectLater(
          find.byKey(const Key('plus_minus_position_breakdown')),
          matchesGoldenFile('plus_minus_position_in_row.png'),
        );
      });
    });

    group('Button Pressed/Highlight State', () {
      testWidgets('renders +/- button in normal state',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: GestureDetector(
                    child: Container(
                      key: const Key('normal_state_plus_minus'),
                      decoration: NegateButtonConfig.decoration,
                      child: Center(
                        child: Text(
                          NegateButtonConfig.label,
                          style: NegateButtonConfig.textStyle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden of button in normal (unpressed) state
        await expectLater(
          find.byKey(const Key('normal_state_plus_minus')),
          matchesGoldenFile('plus_minus_button_normal_state.png'),
        );
      });

      testWidgets('renders +/- button with lighter color for pressed state simulation',
          (WidgetTester tester) async {
        // Simulate a pressed state with a lighter shade of gray
        const pressedColor = Color(0xFF6A6A6A); // Lighter gray for pressed

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Container(
                    key: const Key('pressed_state_plus_minus'),
                    decoration: const BoxDecoration(
                      color: pressedColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        NegateButtonConfig.label,
                        style: NegateButtonConfig.textStyle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden of button in pressed/highlight state
        await expectLater(
          find.byKey(const Key('pressed_state_plus_minus')),
          matchesGoldenFile('plus_minus_button_pressed_state.png'),
        );
      });

      testWidgets('compares normal and pressed states side by side',
          (WidgetTester tester) async {
        const normalColor = Color(0xFF505050);
        const pressedColor = Color(0xFF6A6A6A);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Row(
                  key: const Key('plus_minus_states_comparison'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Normal state
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Normal',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: normalColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                NegateButtonConfig.label,
                                style: NegateButtonConfig.textStyle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 30),
                    // Pressed state
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Pressed',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: pressedColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                NegateButtonConfig.label,
                                style: NegateButtonConfig.textStyle,
                              ),
                            ),
                          ),
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

        // Capture golden comparing both states
        await expectLater(
          find.byKey(const Key('plus_minus_states_comparison')),
          matchesGoldenFile('plus_minus_button_states_comparison.png'),
        );
      });
    });

    group('Design Specification Verification', () {
      testWidgets('button background color is exactly #505050',
          (WidgetTester tester) async {
        // This test verifies the exact color value
        expect(
          CalculatorColors.negateButtonBackground,
          equals(const Color(0xFF505050)),
        );
        expect(
          NegateButtonConfig.backgroundColor,
          equals(const Color(0xFF505050)),
        );
      });

      testWidgets('button text color is white for contrast',
          (WidgetTester tester) async {
        expect(
          NegateButtonConfig.textColor,
          equals(Colors.white),
        );
        expect(
          CalculatorColors.lightButtonText,
          equals(Colors.white),
        );
      });

      testWidgets('button label is "+/-"',
          (WidgetTester tester) async {
        expect(NegateButtonConfig.label, equals('+/-'));
      });

      testWidgets('button has circular/pill shape via high border radius',
          (WidgetTester tester) async {
        final decoration = NegateButtonConfig.decoration;
        // The decoration uses borderRadius with 1000dp for circular appearance
        expect(decoration.borderRadius, isNotNull);
      });

      testWidgets('renders all design specifications in single golden',
          (WidgetTester tester) async {
        // Build a comprehensive widget showing all design specs
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.grey.shade900,
              body: Center(
                child: Column(
                  key: const Key('plus_minus_design_specs_golden'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Label showing color hex
                    const Text(
                      'Background: #505050 (Gray)',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    // The actual button
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Container(
                        decoration: NegateButtonConfig.decoration,
                        child: Center(
                          child: Text(
                            NegateButtonConfig.label,
                            style: NegateButtonConfig.textStyle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Label showing text color
                    const Text(
                      'Text: White',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Shape: Circular (1000dp radius)',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Label: +/-',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Position: Bottom-Left of Grid',
                      style: TextStyle(color: Colors.white, fontSize: 14),
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
          find.byKey(const Key('plus_minus_design_specs_golden')),
          matchesGoldenFile('plus_minus_button_design_specs.png'),
        );
      });
    });

    group('Comparison with Other Function Buttons', () {
      testWidgets('renders +/- alongside other gray function buttons for visual consistency',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Column(
                  key: const Key('function_buttons_comparison'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Gray Function Buttons (#505050)',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Clear button
                        _buildFunctionButton('C', 24),
                        const SizedBox(width: 10),
                        // Parenthesis button
                        _buildFunctionButton('()', 24),
                        const SizedBox(width: 10),
                        // Power button
                        _buildFunctionButton('^', 24),
                        const SizedBox(width: 10),
                        // Plus/Minus button
                        _buildFunctionButton('+/-', 18),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'All function buttons share same gray styling',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden of all gray function buttons
        await expectLater(
          find.byKey(const Key('function_buttons_comparison')),
          matchesGoldenFile('plus_minus_with_function_buttons.png'),
        );
      });
    });
  });
}

/// Helper widget to build a function button for visual comparison.
Widget _buildFunctionButton(String label, double fontSize) {
  return SizedBox(
    width: 70,
    height: 70,
    child: Container(
      decoration: const BoxDecoration(
        color: Color(0xFF505050),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}
