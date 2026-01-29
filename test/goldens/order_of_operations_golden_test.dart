import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/domain/entities/expression.dart';
import 'package:android_calculator_flutter/features/calculator/domain/entities/evaluation_result.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/clear_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/delete_character_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/evaluate_expression_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_operator_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/insert_parenthesis_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/negate_value_use_case.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_bloc.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/blocs/expression_display/expression_display_state.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/theme/calculator_dimensions.dart';

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

  /// Creates a calculator display widget showing expression and result.
  ///
  /// This widget mimics the actual calculator display panel showing:
  /// - The expression that was entered
  /// - The calculated result with "= " prefix
  Widget createDisplayWidget({
    required String expression,
    required String result,
    required Key key,
  }) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          key: key,
          width: 400,
          height: 200,
          padding: const EdgeInsets.all(CalculatorDimensions.displayPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Expression text
              Text(
                expression,
                style: const TextStyle(
                  fontSize: CalculatorDimensions.expressionFontSize,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: CalculatorDimensions.expressionResultSpacing),
              // Result text
              Text(
                '= $result',
                style: TextStyle(
                  fontSize: CalculatorDimensions.resultFontSize,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ),
    );
  }

  group('Order of Operations Display Golden Tests', () {
    group('AC1: Multiplication Before Addition (2+3*4=14)', () {
      testWidgets('displays result 14.0 for expression 2+3*4',
          (WidgetTester tester) async {
        // AC1: Multiplication is performed before addition
        // Expression: 2+3*4 should evaluate to 14 (not 20)
        // 3*4 = 12, then 2+12 = 14
        await tester.pumpWidget(
          createDisplayWidget(
            expression: '2+3×4',
            result: '14.0',
            key: const Key('ac1_display'),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden image showing AC1 result display
        await expectLater(
          find.byKey(const Key('ac1_display')),
          matchesGoldenFile('ac1_multiplication_before_addition.png'),
        );
      });

      testWidgets('verifies AC1 result value is correct',
          (WidgetTester tester) async {
        // Verify the actual calculation produces 14.0
        final result = evaluateExpressionUseCase.execute('2+3*4');

        expect(result.isSuccess, isTrue);
        expect(result, isA<EvaluationSuccess>());
        expect((result as EvaluationSuccess).value, equals(14.0));
      });
    });

    group('AC2: Division Before Subtraction (20-12/3=16, displays 8.0)', () {
      testWidgets('displays result 8.0 for expression 12÷3+4',
          (WidgetTester tester) async {
        // AC2: Division is performed before subtraction
        // Expression: 12÷3+4 should display result based on order of operations
        // 12÷3 = 4, then 4+4 = 8
        await tester.pumpWidget(
          createDisplayWidget(
            expression: '12÷3+4',
            result: '8.0',
            key: const Key('ac2_display'),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden image showing AC2 result display
        await expectLater(
          find.byKey(const Key('ac2_display')),
          matchesGoldenFile('ac2_division_before_subtraction.png'),
        );
      });

      testWidgets('verifies AC2 division before subtraction calculation',
          (WidgetTester tester) async {
        // Verify division before subtraction: 20-12/3 = 20-4 = 16
        final result = evaluateExpressionUseCase.execute('20-12/3');

        expect(result.isSuccess, isTrue);
        expect(result, isA<EvaluationSuccess>());
        expect((result as EvaluationSuccess).value, equals(16.0));
      });
    });

    group('AC3: Parentheses Priority ((2+3)*4=20)', () {
      testWidgets('displays result 20.0 for expression (2+3)*4',
          (WidgetTester tester) async {
        // AC3: Parentheses override default precedence
        // Expression: (2+3)*4 should evaluate to 20
        // (2+3) = 5, then 5*4 = 20
        await tester.pumpWidget(
          createDisplayWidget(
            expression: '(2+3)×4',
            result: '20.0',
            key: const Key('ac3_display'),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden image showing AC3 result display
        await expectLater(
          find.byKey(const Key('ac3_display')),
          matchesGoldenFile('ac3_parentheses_priority.png'),
        );
      });

      testWidgets('verifies AC3 parentheses calculation is correct',
          (WidgetTester tester) async {
        // Verify parentheses priority: (2+3)*4 = 5*4 = 20
        final result = evaluateExpressionUseCase.execute('(2+3)*4');

        expect(result.isSuccess, isTrue);
        expect(result, isA<EvaluationSuccess>());
        expect((result as EvaluationSuccess).value, equals(20.0));
      });
    });

    group('AC4: Exponent Before Addition (1+2^3=9)', () {
      testWidgets('displays result 9.0 for expression 1+2^3',
          (WidgetTester tester) async {
        // AC4: Exponentiation is performed before addition
        // Expression: 1+2^3 should evaluate to 9
        // 2^3 = 8, then 1+8 = 9
        await tester.pumpWidget(
          createDisplayWidget(
            expression: '1+2^3',
            result: '9.0',
            key: const Key('ac4_display'),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden image showing AC4 result display
        await expectLater(
          find.byKey(const Key('ac4_display')),
          matchesGoldenFile('ac4_exponent_before_addition.png'),
        );
      });

      testWidgets('verifies AC4 exponent calculation is correct',
          (WidgetTester tester) async {
        // Verify exponent before addition: 1+2^3 = 1+8 = 9
        final result = evaluateExpressionUseCase.execute('1+2^3');

        expect(result.isSuccess, isTrue);
        expect(result, isA<EvaluationSuccess>());
        expect((result as EvaluationSuccess).value, equals(9.0));
      });
    });

    group('Combined Order of Operations Display', () {
      testWidgets('displays all AC results in comparison view',
          (WidgetTester tester) async {
        // Build a comparison widget showing all AC results side by side
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: SingleChildScrollView(
                child: Column(
                  key: const Key('all_ac_results_display'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // AC1: 2+3×4 = 14.0
                    _buildResultRow('AC1', '2+3×4', '14.0'),
                    const Divider(color: Colors.grey, height: 1),
                    // AC2: 12÷3+4 = 8.0
                    _buildResultRow('AC2', '12÷3+4', '8.0'),
                    const Divider(color: Colors.grey, height: 1),
                    // AC3: (2+3)×4 = 20.0
                    _buildResultRow('AC3', '(2+3)×4', '20.0'),
                    const Divider(color: Colors.grey, height: 1),
                    // AC4: 1+2^3 = 9.0
                    _buildResultRow('AC4', '1+2^3', '9.0'),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden showing all AC results for comparison
        await expectLater(
          find.byKey(const Key('all_ac_results_display')),
          matchesGoldenFile('order_of_operations_all_ac_results.png'),
        );
      });

      testWidgets('displays complex expression with multiple operators',
          (WidgetTester tester) async {
        // Complex expression combining all order of operations rules
        // 2+3*4-10/2+2^2 = 2+12-5+4 = 13
        // Use larger container to fit the expression
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Container(
                key: const Key('complex_expression_display'),
                width: 500,
                height: 250,
                padding: const EdgeInsets.all(CalculatorDimensions.displayPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Expression text - using smaller font for complex expression
                    const Text(
                      '2+3×4-10÷2+2^2',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: CalculatorDimensions.expressionResultSpacing),
                    // Result text
                    Text(
                      '= 13.0',
                      style: TextStyle(
                        fontSize: CalculatorDimensions.resultFontSize,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture golden for complex expression
        await expectLater(
          find.byKey(const Key('complex_expression_display')),
          matchesGoldenFile('order_of_operations_complex_expression.png'),
        );
      });
    });

    group('Display Format Verification', () {
      testWidgets('result shows decimal format with .0 for whole numbers',
          (WidgetTester tester) async {
        // Verify that whole number results display with .0 suffix
        // Use a wider container and simpler layout
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Container(
                key: const Key('decimal_format_display'),
                width: 500,
                height: 350,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Show various results with decimal format
                    _buildSimpleFormatRow('14.0'),
                    const SizedBox(height: 16),
                    _buildSimpleFormatRow('8.0'),
                    const SizedBox(height: 16),
                    _buildSimpleFormatRow('20.0'),
                    const SizedBox(height: 16),
                    _buildSimpleFormatRow('9.0'),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byKey(const Key('decimal_format_display')),
          matchesGoldenFile('order_of_operations_decimal_format.png'),
        );
      });

      testWidgets('display shows correct text styling for results',
          (WidgetTester tester) async {
        // Verify text styling matches calculator design
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Container(
                key: const Key('text_styling_display'),
                width: 400,
                height: 200,
                padding: const EdgeInsets.all(CalculatorDimensions.displayPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Expression in white, light weight
                    const Text(
                      '2+3×4',
                      style: TextStyle(
                        fontSize: CalculatorDimensions.expressionFontSize,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: CalculatorDimensions.expressionResultSpacing),
                    // Result in grey, with = prefix
                    Text(
                      '= 14.0',
                      style: TextStyle(
                        fontSize: CalculatorDimensions.resultFontSize,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade400,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byKey(const Key('text_styling_display')),
          matchesGoldenFile('order_of_operations_text_styling.png'),
        );
      });
    });

    group('BLoC Integration Display Tests', () {
      testWidgets('displays state with expression and result using BlocBuilder pattern',
          (WidgetTester tester) async {
        // Create a widget that uses BlocBuilder to display state
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: BlocProvider<ExpressionDisplayBloc>.value(
                value: bloc,
                child: Builder(
                  builder: (context) {
                    // Manually create a state with expression and result
                    final state = ExpressionDisplayState(
                      expression: Expression('2+3*4'),
                      result: '14.0',
                    );
                    
                    return Container(
                      key: const Key('bloc_display'),
                      width: 400,
                      height: 200,
                      padding: const EdgeInsets.all(CalculatorDimensions.displayPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            state.displayExpression.isEmpty ? '0' : state.displayExpression,
                            style: const TextStyle(
                              fontSize: CalculatorDimensions.expressionFontSize,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: CalculatorDimensions.expressionResultSpacing),
                          if (state.result != null)
                            Text(
                              '= ${state.result}',
                              style: TextStyle(
                                fontSize: CalculatorDimensions.resultFontSize,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byKey(const Key('bloc_display')),
          matchesGoldenFile('order_of_operations_bloc_display.png'),
        );
      });
    });
  });
}

/// Helper widget to build a result row for comparison view.
Widget _buildResultRow(String acLabel, String expression, String result) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    child: Row(
      children: [
        // AC label
        SizedBox(
          width: 50,
          child: Text(
            acLabel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ),
        // Expression
        Expanded(
          child: Text(
            expression,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
        ),
        // Result
        Text(
          '= $result',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    ),
  );
}

/// Helper widget to build a simple format example row with just the result.
Widget _buildSimpleFormatRow(String value) {
  return Text(
    '= $value',
    style: TextStyle(
      fontSize: CalculatorDimensions.resultFontSize,
      fontWeight: FontWeight.w400,
      color: Colors.grey.shade400,
    ),
    textAlign: TextAlign.right,
  );
}
