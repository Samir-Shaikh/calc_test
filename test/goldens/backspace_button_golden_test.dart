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
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/backspace_button.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/backspace_button_config.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_button_grid.dart';

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

  group('Backspace Button Golden Tests', () {
    group('Isolated Backspace Button', () {
      testWidgets('renders backspace button with gray (#505050) background',
          (WidgetTester tester) async {
        // Build an isolated backspace button matching the exact styling
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Container(
                    key: const Key('isolated_backspace_button'),
                    decoration: BackspaceButtonConfig.decoration,
                    child: Center(
                      child: BackspaceButtonConfig.iconWidget,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden image of isolated backspace button
        await expectLater(
          find.byKey(const Key('isolated_backspace_button')),
          matchesGoldenFile('backspace_button_isolated.png'),
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
                    child: Center(
                      child: Icon(
                        Icons.backspace_outlined,
                        size: 24,
                        color: Colors.white,
                        semanticLabel: 'Backspace',
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
          matchesGoldenFile('backspace_button_color_verification.png'),
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
                    decoration: CalculatorButtonDecorations.backspaceButton,
                    child: Center(
                      child: BackspaceButtonConfig.iconWidget,
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
          matchesGoldenFile('backspace_button_circular_shape.png'),
        );
      });
    });

    group('Button in Context', () {
      testWidgets('renders backspace button above calculator grid right-aligned',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: BlocProvider<ExpressionDisplayBloc>.value(
                value: bloc,
                child: SizedBox(
                  key: const Key('backspace_button_in_context'),
                  width: 400,
                  height: 600,
                  child: Column(
                    children: [
                      // Backspace button row - right-aligned
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: CalculatorDimensions.backspaceRowHorizontalPadding,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: CalculatorDimensions.backspaceButtonBottomSpacing,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              BackspaceButton(),
                            ],
                          ),
                        ),
                      ),
                      // Button grid
                      const Expanded(
                        child: CalculatorButtonGrid(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden showing backspace button positioned above grid
        await expectLater(
          find.byKey(const Key('backspace_button_in_context')),
          matchesGoldenFile('backspace_button_in_context.png'),
        );
      });

      testWidgets('backspace button positioned correctly with right alignment',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: BlocProvider<ExpressionDisplayBloc>.value(
                value: bloc,
                child: SizedBox(
                  key: const Key('backspace_row_alignment'),
                  width: 400,
                  height: 100,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CalculatorDimensions.backspaceRowHorizontalPadding,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        BackspaceButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden showing right-aligned backspace button
        await expectLater(
          find.byKey(const Key('backspace_row_alignment')),
          matchesGoldenFile('backspace_button_right_aligned.png'),
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
                      decoration: BackspaceButtonConfig.decoration,
                      child: Center(
                        child: BackspaceButtonConfig.iconWidget,
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
          matchesGoldenFile('backspace_button_normal_state.png'),
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
                      child: Icon(
                        BackspaceButtonConfig.icon,
                        size: BackspaceButtonConfig.iconSize,
                        color: BackspaceButtonConfig.iconColor,
                        semanticLabel: BackspaceButtonConfig.semanticLabel,
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
          matchesGoldenFile('backspace_button_pressed_state.png'),
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
                          child: BackspaceButtonConfig.iconWidget,
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
                          child: Icon(
                            BackspaceButtonConfig.icon,
                            size: BackspaceButtonConfig.iconSize,
                            color: BackspaceButtonConfig.iconColor,
                            semanticLabel: BackspaceButtonConfig.semanticLabel,
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
          matchesGoldenFile('backspace_button_states_comparison.png'),
        );
      });
    });

    group('Icon Visibility and Sizing', () {
      testWidgets('icon is appropriately sized and visible',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: SizedBox(
                  key: const Key('icon_visibility_test'),
                  width: 120,
                  height: 120,
                  child: Container(
                    decoration: BackspaceButtonConfig.decoration,
                    child: Center(
                      child: BackspaceButtonConfig.iconWidget,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden showing icon visibility
        await expectLater(
          find.byKey(const Key('icon_visibility_test')),
          matchesGoldenFile('backspace_button_icon_visibility.png'),
        );
      });

      testWidgets('icon scales appropriately with different button sizes',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Row(
                  key: const Key('icon_sizing_comparison'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Small button (actual size from dimensions)
                    SizedBox(
                      width: CalculatorDimensions.backspaceButtonSize,
                      height: CalculatorDimensions.backspaceButtonSize,
                      child: Container(
                        decoration: BackspaceButtonConfig.decoration,
                        child: Center(
                          child: BackspaceButtonConfig.iconWidget,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Medium button
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Container(
                        decoration: BackspaceButtonConfig.decoration,
                        child: Center(
                          child: BackspaceButtonConfig.iconWidget,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Large button
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Container(
                        decoration: BackspaceButtonConfig.decoration,
                        child: Center(
                          child: BackspaceButtonConfig.iconWidget,
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

        // Capture golden showing icon at different button sizes
        await expectLater(
          find.byKey(const Key('icon_sizing_comparison')),
          matchesGoldenFile('backspace_button_icon_sizing.png'),
        );
      });

      testWidgets('icon contrast against gray background',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.grey.shade800,
              body: Center(
                child: Column(
                  key: const Key('icon_contrast_test'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'White icon on #505050 background',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Container(
                        decoration: BackspaceButtonConfig.decoration,
                        child: Center(
                          child: BackspaceButtonConfig.iconWidget,
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

        // Capture golden showing icon contrast
        await expectLater(
          find.byKey(const Key('icon_contrast_test')),
          matchesGoldenFile('backspace_button_icon_contrast.png'),
        );
      });
    });

    group('Design Specification Verification', () {
      testWidgets('button background color is exactly #505050',
          (WidgetTester tester) async {
        // This test verifies the exact color value
        expect(
          CalculatorColors.backspaceButtonBackground,
          equals(const Color(0xFF505050)),
        );
        expect(
          BackspaceButtonConfig.backgroundColor,
          equals(const Color(0xFF505050)),
        );
      });

      testWidgets('button icon color is white for contrast',
          (WidgetTester tester) async {
        expect(
          BackspaceButtonConfig.iconColor,
          equals(Colors.white),
        );
        expect(
          CalculatorColors.lightButtonText,
          equals(Colors.white),
        );
      });

      testWidgets('button icon is backspace_outlined',
          (WidgetTester tester) async {
        expect(BackspaceButtonConfig.icon, equals(Icons.backspace_outlined));
      });

      testWidgets('button has circular shape',
          (WidgetTester tester) async {
        final decoration = BackspaceButtonConfig.decoration;
        expect(decoration.shape, equals(BoxShape.circle));
      });

      testWidgets('button has correct size from CalculatorDimensions',
          (WidgetTester tester) async {
        expect(CalculatorDimensions.backspaceButtonSize, equals(48.0));
      });

      testWidgets('icon has correct size from BackspaceButtonConfig',
          (WidgetTester tester) async {
        expect(BackspaceButtonConfig.iconSize, equals(24));
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
                        decoration: BackspaceButtonConfig.decoration,
                        child: Center(
                          child: BackspaceButtonConfig.iconWidget,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Label showing icon color
                    const Text(
                      'Icon: White',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Shape: Circle',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Icon: backspace_outlined',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Button Size: ${CalculatorDimensions.backspaceButtonSize}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Icon Size: ${BackspaceButtonConfig.iconSize}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
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
          matchesGoldenFile('backspace_button_design_specs.png'),
        );
      });
    });
  });
}
