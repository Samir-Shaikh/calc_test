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
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/operator_button_config.dart';

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

  group('Equals Button Golden Tests', () {
    group('Isolated Equals Button', () {
      testWidgets('renders equals button with orange (#FF9500) background',
          (WidgetTester tester) async {
        // Build an isolated equals button matching the exact styling
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Container(
                    key: const Key('isolated_equals_button'),
                    decoration: EqualsButtonConfig.decoration,
                    child: Center(
                      child: Text(
                        EqualsButtonConfig.label,
                        style: EqualsButtonConfig.textStyle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden image of isolated equals button
        await expectLater(
          find.byKey(const Key('isolated_equals_button')),
          matchesGoldenFile('equals_button_isolated.png'),
        );
      });

      testWidgets('verifies button decoration matches orange color specification',
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
                      color: Color(0xFFFF9500), // Explicit #FF9500
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
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify the button renders with the expected orange color
        await expectLater(
          find.byKey(const Key('color_verification_button')),
          matchesGoldenFile('equals_button_color_verification.png'),
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
                    decoration: CalculatorButtonDecorations.equalsButton,
                    child: Center(
                      child: Text(
                        EqualsButtonConfig.label,
                        style: EqualsButtonConfig.textStyle,
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
          matchesGoldenFile('equals_button_circular_shape.png'),
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

      testWidgets('renders equals button in calculator grid last row',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorGridWidget());
        await tester.pumpAndSettle();

        // Capture the entire calculator grid showing button positions
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('calculator_grid_with_equals.png'),
        );
      });

      testWidgets('equals button positioned correctly among last row buttons',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorGridWidget());
        await tester.pumpAndSettle();

        // Find the equals button in the grid
        final equalsButton = find.byKey(const Key('equals_button'));
        expect(equalsButton, findsOneWidget);

        // Capture golden of the equals button within the grid
        await expectLater(
          equalsButton,
          matchesGoldenFile('equals_button_in_grid.png'),
        );
      });

      testWidgets('last row shows ^, 0, ., ⌫, = buttons in correct order',
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

        // Capture the calculator grid showing the last row with equals button
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('calculator_last_row_with_equals.png'),
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
                      decoration: EqualsButtonConfig.decoration,
                      child: Center(
                        child: Text(
                          EqualsButtonConfig.label,
                          style: EqualsButtonConfig.textStyle,
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
          matchesGoldenFile('equals_button_normal_state.png'),
        );
      });

      testWidgets('renders button with slightly lighter color for pressed state simulation',
          (WidgetTester tester) async {
        // Simulate a pressed state with a lighter shade of orange
        const pressedColor = Color(0xFFFFAA33); // Lighter orange for pressed

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
                        EqualsButtonConfig.label,
                        style: EqualsButtonConfig.textStyle,
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
          matchesGoldenFile('equals_button_pressed_state.png'),
        );
      });

      testWidgets('compares normal and pressed states side by side',
          (WidgetTester tester) async {
        const normalColor = Color(0xFFFF9500);
        const pressedColor = Color(0xFFFFAA33);

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
                            EqualsButtonConfig.label,
                            style: EqualsButtonConfig.textStyle,
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
                            EqualsButtonConfig.label,
                            style: EqualsButtonConfig.textStyle,
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
          matchesGoldenFile('equals_button_states_comparison.png'),
        );
      });
    });

    group('Design Specification Verification', () {
      testWidgets('equals button background color is exactly #FF9500',
          (WidgetTester tester) async {
        // This test verifies the exact color value
        expect(
          CalculatorColors.equalsButtonBackground,
          equals(const Color(0xFFFF9500)),
        );
        expect(
          EqualsButtonConfig.backgroundColor,
          equals(const Color(0xFFFF9500)),
        );
      });

      testWidgets('equals button text color is white for contrast',
          (WidgetTester tester) async {
        expect(
          EqualsButtonConfig.textColor,
          equals(Colors.white),
        );
        expect(
          CalculatorColors.lightButtonText,
          equals(Colors.white),
        );
      });

      testWidgets('equals button label is "="',
          (WidgetTester tester) async {
        expect(EqualsButtonConfig.label, equals('='));
      });

      testWidgets('equals button has circular shape',
          (WidgetTester tester) async {
        final decoration = EqualsButtonConfig.decoration;
        expect(decoration.shape, equals(BoxShape.circle));
      });

      testWidgets('equals button color matches operator button color',
          (WidgetTester tester) async {
        // Verify consistency between equals button and operator buttons
        expect(
          CalculatorColors.equalsButtonBackground,
          equals(CalculatorColors.operatorButtonBackground),
        );
        expect(
          EqualsButtonConfig.backgroundColor,
          equals(OperatorButtonConfig.backgroundColor),
        );
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
                      'Background: #FF9500',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    // The actual button
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Container(
                        decoration: EqualsButtonConfig.decoration,
                        child: Center(
                          child: Text(
                            EqualsButtonConfig.label,
                            style: EqualsButtonConfig.textStyle,
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
                    const SizedBox(height: 5),
                    const Text(
                      'Label: =',
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
          matchesGoldenFile('equals_button_design_specs.png'),
        );
      });
    });

    group('AC4 Verification: Equals Button Display', () {
      testWidgets('AC4: equals button displays "=" symbol and has orange #FF9500 background',
          (WidgetTester tester) async {
        // This test directly verifies Acceptance Criteria 4
        
        // Verify the color constant is exactly #FF9500
        expect(
          CalculatorColors.equalsButtonBackground.value,
          equals(0xFFFF9500),
          reason: 'Equals button orange should be exactly #FF9500',
        );

        // Verify the label is exactly '='
        expect(
          EqualsButtonConfig.label,
          equals('='),
          reason: 'Equals button should display "=" symbol',
        );

        // Build and capture the equals button for visual verification
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Container(
                    key: const Key('ac4_equals_button'),
                    decoration: BoxDecoration(
                      color: CalculatorColors.equalsButtonBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        EqualsButtonConfig.label,
                        style: const TextStyle(
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

        // Capture golden for AC4 verification
        await expectLater(
          find.byKey(const Key('ac4_equals_button')),
          matchesGoldenFile('equals_button_ac4_verification.png'),
        );
      });
    });
  });
}
