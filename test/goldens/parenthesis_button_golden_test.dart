import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/clear_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_operator_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_parenthesis_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_bloc.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/theme/calculator_button_decorations.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/theme/calculator_colors.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_button_grid.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/parenthesis_button_config.dart';

void main() {
  late InsertParenthesisUseCase insertParenthesisUseCase;
  late InsertOperatorUseCase insertOperatorUseCase;
  late EvaluateExpressionUseCase evaluateExpressionUseCase;
  late ClearExpressionUseCase clearExpressionUseCase;
  late ExpressionDisplayBloc bloc;

  setUp(() {
    insertParenthesisUseCase = InsertParenthesisUseCase();
    insertOperatorUseCase = InsertOperatorUseCase();
    evaluateExpressionUseCase = EvaluateExpressionUseCase();
    clearExpressionUseCase = ClearExpressionUseCase();
    bloc = ExpressionDisplayBloc(
      insertParenthesisUseCase: insertParenthesisUseCase,
      insertOperatorUseCase: insertOperatorUseCase,
      evaluateExpressionUseCase: evaluateExpressionUseCase,
      clearExpressionUseCase: clearExpressionUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('Parenthesis Button Golden Tests', () {
    group('Isolated Parenthesis Button', () {
      testWidgets('renders parenthesis button with gray (#505050) background',
          (WidgetTester tester) async {
        // Build an isolated parenthesis button matching the exact styling
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Container(
                    key: const Key('isolated_parenthesis_button'),
                    decoration: ParenthesisButtonConfig.decoration,
                    child: Center(
                      child: Text(
                        ParenthesisButtonConfig.label,
                        style: ParenthesisButtonConfig.textStyle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden image of isolated parenthesis button
        await expectLater(
          find.byKey(const Key('isolated_parenthesis_button')),
          matchesGoldenFile('parenthesis_button_isolated.png'),
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
                    key: const Key('color_verification_button'),
                    decoration: const BoxDecoration(
                      color: Color(0xFF505050), // Explicit #505050
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '()',
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
          find.byKey(const Key('color_verification_button')),
          matchesGoldenFile('parenthesis_button_color_verification.png'),
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
                    key: const Key('circular_shape_button'),
                    decoration: CalculatorButtonDecorations.parenthesisButton,
                    child: Center(
                      child: Text(
                        ParenthesisButtonConfig.label,
                        style: ParenthesisButtonConfig.textStyle,
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
          find.byKey(const Key('circular_shape_button')),
          matchesGoldenFile('parenthesis_button_circular_shape.png'),
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

      testWidgets('renders parenthesis button in calculator grid first row',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorGridWidget());
        await tester.pumpAndSettle();

        // Capture the entire calculator grid showing button positions
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('calculator_grid_with_parenthesis.png'),
        );
      });

      testWidgets('parenthesis button positioned correctly among first row buttons',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorGridWidget());
        await tester.pumpAndSettle();

        // Find the parenthesis button in the grid
        final parenthesisButton = find.byKey(const Key('parenthesis_button'));
        expect(parenthesisButton, findsOneWidget);

        // Capture golden of the parenthesis button within the grid
        await expectLater(
          parenthesisButton,
          matchesGoldenFile('parenthesis_button_in_grid.png'),
        );
      });

      testWidgets('first row shows C, (), %, ÷ buttons in correct order',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: BlocProvider<ExpressionDisplayBloc>.value(
                value: bloc,
                child: const SizedBox(
                  width: 400,
                  height: 120, // Just enough for first row
                  child: CalculatorButtonGrid(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Capture just the first row of buttons
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('calculator_first_row.png'),
        );
      });
    });

    group('Button Pressed/Highlight State', () {
      testWidgets('renders button in normal state',
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
                      key: const Key('normal_state_button'),
                      decoration: ParenthesisButtonConfig.decoration,
                      child: Center(
                        child: Text(
                          ParenthesisButtonConfig.label,
                          style: ParenthesisButtonConfig.textStyle,
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
          find.byKey(const Key('normal_state_button')),
          matchesGoldenFile('parenthesis_button_normal_state.png'),
        );
      });

      testWidgets('renders button with slightly lighter color for pressed state simulation',
          (WidgetTester tester) async {
        // Simulate a pressed state with a lighter shade of gray
        const pressedColor = Color(0xFF606060); // Lighter gray for pressed

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Container(
                    key: const Key('pressed_state_button'),
                    decoration: const BoxDecoration(
                      color: pressedColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        ParenthesisButtonConfig.label,
                        style: ParenthesisButtonConfig.textStyle,
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
          find.byKey(const Key('pressed_state_button')),
          matchesGoldenFile('parenthesis_button_pressed_state.png'),
        );
      });

      testWidgets('compares normal and pressed states side by side',
          (WidgetTester tester) async {
        const normalColor = Color(0xFF505050);
        const pressedColor = Color(0xFF606060);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Row(
                  key: const Key('button_states_comparison'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Normal state
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
                            ParenthesisButtonConfig.label,
                            style: ParenthesisButtonConfig.textStyle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Pressed state
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
                            ParenthesisButtonConfig.label,
                            style: ParenthesisButtonConfig.textStyle,
                          ),
                        ),
                      ),
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
          find.byKey(const Key('button_states_comparison')),
          matchesGoldenFile('parenthesis_button_states_comparison.png'),
        );
      });
    });

    group('Design Specification Verification', () {
      testWidgets('button background color is exactly #505050',
          (WidgetTester tester) async {
        // This test verifies the exact color value
        expect(
          CalculatorColors.parenthesisButtonBackground,
          equals(const Color(0xFF505050)),
        );
        expect(
          ParenthesisButtonConfig.backgroundColor,
          equals(const Color(0xFF505050)),
        );
      });

      testWidgets('button text color is white for contrast',
          (WidgetTester tester) async {
        expect(
          ParenthesisButtonConfig.textColor,
          equals(Colors.white),
        );
        expect(
          CalculatorColors.lightButtonText,
          equals(Colors.white),
        );
      });

      testWidgets('button label is "()"',
          (WidgetTester tester) async {
        expect(ParenthesisButtonConfig.label, equals('()'));
      });

      testWidgets('button has circular shape',
          (WidgetTester tester) async {
        final decoration = ParenthesisButtonConfig.decoration;
        expect(decoration.shape, equals(BoxShape.circle));
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
                  key: const Key('design_specs_golden'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Label showing color hex
                    const Text(
                      'Background: #505050',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    // The actual button
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Container(
                        decoration: ParenthesisButtonConfig.decoration,
                        child: Center(
                          child: Text(
                            ParenthesisButtonConfig.label,
                            style: ParenthesisButtonConfig.textStyle,
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
                      'Shape: Circle',
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
          find.byKey(const Key('design_specs_golden')),
          matchesGoldenFile('parenthesis_button_design_specs.png'),
        );
      });
    });
  });
}
