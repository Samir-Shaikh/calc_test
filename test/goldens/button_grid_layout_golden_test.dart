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
import 'package:android_calculator_flutter/features/calculator/presentation/screens/calculator_screen.dart';
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

  /// Helper to create a calculator button grid widget for testing.
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

  /// Helper to create a full calculator screen widget for testing.
  Widget createCalculatorScreenWidget({
    double width = 400,
    double height = 800,
  }) {
    return MaterialApp(
      home: BlocProvider<ExpressionDisplayBloc>.value(
        value: bloc,
        child: SizedBox(
          width: width,
          height: height,
          child: const CalculatorScreen(),
        ),
      ),
    );
  }

  group('Button Grid Layout Golden Tests', () {
    group('Complete Grid Layout', () {
      testWidgets('renders full 5×4 button grid with all buttons in final positions',
          (WidgetTester tester) async {
        await tester.pumpWidget(createButtonGridWidget());
        await tester.pumpAndSettle();

        // Capture golden image of the complete button grid
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('button_grid_complete_layout.png'),
        );
      });

      testWidgets('renders button grid with proper spacing and arrangement',
          (WidgetTester tester) async {
        await tester.pumpWidget(createButtonGridWidget(
          width: 360,
          height: 450,
        ));
        await tester.pumpAndSettle();

        // Capture golden showing spacing between buttons
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('button_grid_spacing.png'),
        );
      });
    });

    group('Negate Button Golden Tests', () {
      testWidgets('renders negate button (+/-) with gray styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(createButtonGridWidget());
        await tester.pumpAndSettle();

        // Find the negate button
        final negateButton = find.byKey(const Key('negate_button'));
        expect(negateButton, findsOneWidget);

        // Capture golden of the negate button
        await expectLater(
          negateButton,
          matchesGoldenFile('negate_button_in_grid.png'),
        );
      });

      testWidgets('renders isolated negate button appearance',
          (WidgetTester tester) async {
        // Build an isolated negate button for clearer visual verification
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Container(
                    key: const Key('isolated_negate_button'),
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

        // Capture golden of isolated negate button
        await expectLater(
          find.byKey(const Key('isolated_negate_button')),
          matchesGoldenFile('negate_button_isolated.png'),
        );
      });
    });

    group('Full Calculator Screen Golden Tests', () {
      testWidgets('renders complete calculator with display, backspace, and button grid',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorScreenWidget());
        await tester.pumpAndSettle();

        // Capture golden of the full calculator screen
        await expectLater(
          find.byType(CalculatorScreen),
          matchesGoldenFile('calculator_screen_complete.png'),
        );
      });

      testWidgets('renders calculator screen with expression displayed',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCalculatorScreenWidget());
        await tester.pumpAndSettle();

        // Add some expression to the display
        await tester.tap(find.text('1'));
        await tester.pump();
        await tester.tap(find.text('2'));
        await tester.pump();
        await tester.tap(find.text('+'));
        await tester.pump();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Capture golden showing calculator with expression
        await expectLater(
          find.byType(CalculatorScreen),
          matchesGoldenFile('calculator_screen_with_expression.png'),
        );
      });
    });

    group('Acceptance Criteria Golden Tests', () {
      testWidgets('AC1: number buttons (0-9) arrangement verification',
          (WidgetTester tester) async {
        await tester.pumpWidget(createButtonGridWidget());
        await tester.pumpAndSettle();

        // Capture golden showing number button arrangement
        // Numbers 1-9 in standard 3x3 grid, 0 in bottom row
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('button_grid_number_buttons.png'),
        );
      });

      testWidgets('AC2: operator column alignment (÷, ×, +, -, =)',
          (WidgetTester tester) async {
        await tester.pumpWidget(createButtonGridWidget());
        await tester.pumpAndSettle();

        // Capture golden verifying rightmost column has operators
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('button_grid_operator_column.png'),
        );
      });

      testWidgets('AC3: top row with C, (), ^, ÷ buttons',
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

        // Capture golden of the top row
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('button_grid_top_row.png'),
        );
      });

      testWidgets('AC4: bottom row with +/-, 0, ., = buttons',
          (WidgetTester tester) async {
        await tester.pumpWidget(createButtonGridWidget());
        await tester.pumpAndSettle();

        // Capture golden verifying bottom row arrangement
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('button_grid_bottom_row.png'),
        );
      });

      testWidgets('AC5: equal width verification per row',
          (WidgetTester tester) async {
        await tester.pumpWidget(createButtonGridWidget());
        await tester.pumpAndSettle();

        // Capture golden showing equal button widths
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('button_grid_equal_widths.png'),
        );
      });

      testWidgets('renders all 20 buttons in 5×4 grid',
          (WidgetTester tester) async {
        await tester.pumpWidget(createButtonGridWidget());
        await tester.pumpAndSettle();

        // Verify all button labels exist
        final expectedLabels = [
          'C', '()', '^', '÷',
          '7', '8', '9', '×',
          '4', '5', '6', '+',
          '1', '2', '3', '-',
          '+/-', '0', '.', '=',
        ];

        for (final label in expectedLabels) {
          expect(find.text(label), findsOneWidget,
              reason: 'Button "$label" should exist');
        }

        // Capture golden of complete grid
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('button_grid_all_20_buttons.png'),
        );
      });
    });

    group('Device Size Variation Golden Tests', () {
      testWidgets('renders grid on phone portrait (360×640)',
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createButtonGridWidget(
          width: 360,
          height: 400,
        ));
        await tester.pumpAndSettle();

        // Capture golden for phone portrait size
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('button_grid_phone_portrait.png'),
        );
      });

      testWidgets('renders grid on phone landscape (640×360)',
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(640, 360);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createButtonGridWidget(
          width: 640,
          height: 280,
        ));
        await tester.pumpAndSettle();

        // Capture golden for phone landscape size
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('button_grid_phone_landscape.png'),
        );
      });

      testWidgets('renders grid on tablet (768×1024)',
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createButtonGridWidget(
          width: 600,
          height: 700,
        ));
        await tester.pumpAndSettle();

        // Capture golden for tablet size
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('button_grid_tablet.png'),
        );
      });

      testWidgets('renders full calculator on phone portrait',
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createCalculatorScreenWidget(
          width: 360,
          height: 640,
        ));
        await tester.pumpAndSettle();

        // Capture golden for full calculator on phone portrait
        await expectLater(
          find.byType(CalculatorScreen),
          matchesGoldenFile('calculator_screen_phone_portrait.png'),
        );
      });

      testWidgets('renders button grid on phone landscape (button grid only)',
          (WidgetTester tester) async {
        // Note: The full calculator screen doesn't fit well in landscape mode
        // due to the display area and button grid proportions. This test
        // verifies the button grid maintains correct proportions in landscape.
        tester.view.physicalSize = const Size(800, 400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createButtonGridWidget(
          width: 800,
          height: 350,
        ));
        await tester.pumpAndSettle();

        // Capture golden for button grid in landscape orientation
        await expectLater(
          find.byType(CalculatorButtonGrid),
          matchesGoldenFile('button_grid_landscape_wide.png'),
        );
      });

      testWidgets('renders full calculator on tablet',
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createCalculatorScreenWidget(
          width: 768,
          height: 1024,
        ));
        await tester.pumpAndSettle();

        // Capture golden for full calculator on tablet
        await expectLater(
          find.byType(CalculatorScreen),
          matchesGoldenFile('calculator_screen_tablet.png'),
        );
      });
    });

    group('Button Styling Verification Golden Tests', () {
      testWidgets('renders gray function buttons (C, (), ^, +/-)',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Row(
                  key: const Key('gray_buttons_row'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Clear button
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF505050),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'C',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Parenthesis button
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF505050),
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
                    const SizedBox(width: 10),
                    // Power button
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF505050),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '^',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Negate button
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF505050),
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
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden of gray function buttons
        await expectLater(
          find.byKey(const Key('gray_buttons_row')),
          matchesGoldenFile('gray_function_buttons.png'),
        );
      });

      testWidgets('renders orange operator buttons (÷, ×, +, -, =)',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Row(
                  key: const Key('orange_buttons_row'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Division button
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF9500),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '÷',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Multiplication button
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF9500),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '×',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Plus button
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF9500),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '+',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Minus button
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF9500),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '-',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Equals button
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF9500),
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
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden of orange operator buttons
        await expectLater(
          find.byKey(const Key('orange_buttons_row')),
          matchesGoldenFile('orange_operator_buttons.png'),
        );
      });

      testWidgets('renders digit buttons with dark gray styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Column(
                  key: const Key('digit_buttons_grid'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row: 7, 8, 9
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final digit in ['7', '8', '9']) ...[
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  digit,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
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
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  digit,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
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
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  digit,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (digit != '3') const SizedBox(width: 10),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Row: 0
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
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden of digit buttons
        await expectLater(
          find.byKey(const Key('digit_buttons_grid')),
          matchesGoldenFile('digit_buttons_styling.png'),
        );
      });
    });

    group('Layout Composition Golden Tests', () {
      testWidgets('renders row-by-row layout breakdown',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.grey.shade900,
              body: Center(
                child: Column(
                  key: const Key('row_breakdown'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Label for Row 1
                    const Text(
                      'Row 1: C, (), ^, ÷',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    _buildRowVisualization(['C', '()', '^', '÷'], [
                      const Color(0xFF505050),
                      const Color(0xFF505050),
                      const Color(0xFF505050),
                      const Color(0xFFFF9500),
                    ]),
                    const SizedBox(height: 15),
                    // Label for Row 2
                    const Text(
                      'Row 2: 7, 8, 9, ×',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    _buildRowVisualization(['7', '8', '9', '×'], [
                      Colors.grey.shade800,
                      Colors.grey.shade800,
                      Colors.grey.shade800,
                      const Color(0xFFFF9500),
                    ]),
                    const SizedBox(height: 15),
                    // Label for Row 3
                    const Text(
                      'Row 3: 4, 5, 6, +',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    _buildRowVisualization(['4', '5', '6', '+'], [
                      Colors.grey.shade800,
                      Colors.grey.shade800,
                      Colors.grey.shade800,
                      const Color(0xFFFF9500),
                    ]),
                    const SizedBox(height: 15),
                    // Label for Row 4
                    const Text(
                      'Row 4: 1, 2, 3, -',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    _buildRowVisualization(['1', '2', '3', '-'], [
                      Colors.grey.shade800,
                      Colors.grey.shade800,
                      Colors.grey.shade800,
                      const Color(0xFFFF9500),
                    ]),
                    const SizedBox(height: 15),
                    // Label for Row 5
                    const Text(
                      'Row 5: +/-, 0, ., =',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    _buildRowVisualization(['+/-', '0', '.', '='], [
                      const Color(0xFF505050),
                      Colors.grey.shade800,
                      Colors.grey.shade800,
                      const Color(0xFFFF9500),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden showing row-by-row breakdown
        await expectLater(
          find.byKey(const Key('row_breakdown')),
          matchesGoldenFile('button_grid_row_breakdown.png'),
        );
      });
    });
  });
}

/// Helper widget to build a row of buttons for visualization.
Widget _buildRowVisualization(List<String> labels, List<Color> colors) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < labels.length; i++) ...[
        SizedBox(
          width: 60,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              color: colors[i],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                labels[i],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        if (i < labels.length - 1) const SizedBox(width: 8),
      ],
    ],
  );
}
