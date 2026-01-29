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
import 'package:android_calculator_flutter/features/calculator/presentation/theme/calculator_dimensions.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_button.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_button_grid.dart';

/// Comprehensive widget tests for circular button styling specifications.
///
/// These tests verify that all calculator buttons conform to the circular
/// design specifications:
/// - 70dp height for consistent button sizing
/// - 5dp margins around each button for proper spacing
/// - Borderless appearance for iOS-inspired styling
/// - 24sp text size for readable button labels
/// - Circular/pill shape using high border radius (1000dp)
void main() {
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

  Widget createTestWidget() {
    return MaterialApp(
      home: Scaffold(
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

  /// Helper to find button by key and get container
  Container findContainerByKey(WidgetTester tester, Key buttonKey) {
    final buttonFinder = find.byKey(buttonKey);
    return tester.widget<Container>(
      find.descendant(
        of: buttonFinder,
        matching: find.byType(Container),
      ).first,
    );
  }

  /// Helper to find Padding widget by key
  Padding findPaddingByKey(WidgetTester tester, Key buttonKey) {
    final buttonFinder = find.byKey(buttonKey);
    return tester.widget<Padding>(
      find.descendant(
        of: buttonFinder,
        matching: find.byType(Padding),
      ).first,
    );
  }

  /// Helper to find SizedBox widget by key
  SizedBox findSizedBoxByKey(WidgetTester tester, Key buttonKey) {
    final buttonFinder = find.byKey(buttonKey);
    return tester.widget<SizedBox>(
      find.descendant(
        of: buttonFinder,
        matching: find.byType(SizedBox),
      ).first,
    );
  }

  /// Helper to check if a decoration has borderless styling
  /// (either null border or a transparent border with zero width)
  bool isBorderless(BoxDecoration decoration) {
    if (decoration.border == null) return true;
    // Some buttons use a transparent border with zero width
    if (decoration.border is Border) {
      final border = decoration.border as Border;
      return border.top.color.alpha == 0 && border.top.width == 0;
    }
    return false;
  }

  /// Helper to check if a decoration has circular styling
  /// (either BoxShape.circle or high borderRadius >= 1000)
  bool isCircularStyling(BoxDecoration decoration) {
    if (decoration.shape == BoxShape.circle) return true;
    if (decoration.borderRadius != null) {
      final borderRadius = decoration.borderRadius as BorderRadius;
      return borderRadius.topLeft.x >= 1000.0;
    }
    return false;
  }

  group('Circular Button Design Specifications', () {
    group('Button Height Constraint (70dp)', () {
      testWidgets('function button "C" (clear) has height of 70.0',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final sizedBox = findSizedBoxByKey(tester, const Key('clear_button'));
        expect(sizedBox.height, equals(70.0));
        expect(sizedBox.height, equals(CalculatorDimensions.circularButtonHeight));
      });

      testWidgets('parenthesis button has height of 70.0',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final sizedBox = findSizedBoxByKey(tester, const Key('parenthesis_button'));
        expect(sizedBox.height, equals(70.0));
      });

      testWidgets('power button has height of 70.0',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final sizedBox = findSizedBoxByKey(tester, const Key('power_button'));
        expect(sizedBox.height, equals(70.0));
      });

      testWidgets('negate button has height of 70.0',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final sizedBox = findSizedBoxByKey(tester, const Key('negate_button'));
        expect(sizedBox.height, equals(70.0));
      });

      testWidgets('equals button has height of 70.0',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final sizedBox = findSizedBoxByKey(tester, const Key('equals_button'));
        expect(sizedBox.height, equals(70.0));
      });

      testWidgets('CalculatorButton widget enforces consistent height',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Find all CalculatorButton widgets
        final buttonFinders = find.byType(CalculatorButton);
        expect(buttonFinders, findsWidgets);

        // Each CalculatorButton should contain a SizedBox with height 70.0
        final buttonCount = tester.widgetList(buttonFinders).length;
        expect(buttonCount, equals(20)); // 5 rows x 4 buttons

        // Verify the SizedBox height for a sample of buttons
        final clearSizedBox = findSizedBoxByKey(tester, const Key('clear_button'));
        final equalsSizedBox = findSizedBoxByKey(tester, const Key('equals_button'));
        final negateSizedBox = findSizedBoxByKey(tester, const Key('negate_button'));

        expect(clearSizedBox.height, equals(equalsSizedBox.height));
        expect(equalsSizedBox.height, equals(negateSizedBox.height));
        expect(negateSizedBox.height, equals(70.0));
      });
    });

    group('Button Margin/Padding (5dp)', () {
      testWidgets('clear button has EdgeInsets.all(5.0) margin',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final padding = findPaddingByKey(tester, const Key('clear_button'));
        expect(padding.padding, equals(const EdgeInsets.all(5.0)));
        expect(
          padding.padding,
          equals(const EdgeInsets.all(CalculatorDimensions.circularButtonMargin)),
        );
      });

      testWidgets('parenthesis button has EdgeInsets.all(5.0) margin',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final padding = findPaddingByKey(tester, const Key('parenthesis_button'));
        expect(padding.padding, equals(const EdgeInsets.all(5.0)));
      });

      testWidgets('power button has EdgeInsets.all(5.0) margin',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final padding = findPaddingByKey(tester, const Key('power_button'));
        expect(padding.padding, equals(const EdgeInsets.all(5.0)));
      });

      testWidgets('negate button has EdgeInsets.all(5.0) margin',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final padding = findPaddingByKey(tester, const Key('negate_button'));
        expect(padding.padding, equals(const EdgeInsets.all(5.0)));
      });

      testWidgets('equals button has EdgeInsets.all(5.0) margin',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final padding = findPaddingByKey(tester, const Key('equals_button'));
        expect(padding.padding, equals(const EdgeInsets.all(5.0)));
      });

      testWidgets('all keyed buttons have consistent 5dp margin',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final buttonKeys = [
          const Key('clear_button'),
          const Key('parenthesis_button'),
          const Key('power_button'),
          const Key('negate_button'),
          const Key('equals_button'),
        ];

        for (final key in buttonKeys) {
          final padding = findPaddingByKey(tester, key);
          expect(
            padding.padding,
            equals(const EdgeInsets.all(5.0)),
            reason: 'Button with key $key should have 5dp margin',
          );
        }
      });
    });

    group('Circular Shape Decoration (borderRadius >= 1000)', () {
      testWidgets('clear button has circular styling (high borderRadius)',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final container = findContainerByKey(tester, const Key('clear_button'));
        final decoration = container.decoration as BoxDecoration;

        // The buttons use borderRadius (not BoxShape.circle) for circular appearance
        expect(isCircularStyling(decoration), isTrue);
        expect(decoration.borderRadius, isNotNull);
        final borderRadius = decoration.borderRadius as BorderRadius;
        expect(borderRadius.topLeft.x, greaterThanOrEqualTo(1000.0));
      });

      testWidgets('parenthesis button has circular styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final container = findContainerByKey(tester, const Key('parenthesis_button'));
        final decoration = container.decoration as BoxDecoration;

        expect(isCircularStyling(decoration), isTrue);
      });

      testWidgets('power button has circular styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final container = findContainerByKey(tester, const Key('power_button'));
        final decoration = container.decoration as BoxDecoration;

        expect(isCircularStyling(decoration), isTrue);
      });

      testWidgets('negate button has circular styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final container = findContainerByKey(tester, const Key('negate_button'));
        final decoration = container.decoration as BoxDecoration;

        expect(isCircularStyling(decoration), isTrue);
      });

      testWidgets('equals button has circular styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final container = findContainerByKey(tester, const Key('equals_button'));
        final decoration = container.decoration as BoxDecoration;

        expect(isCircularStyling(decoration), isTrue);
      });

      testWidgets('all keyed buttons have circular styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final buttonKeys = [
          const Key('clear_button'),
          const Key('parenthesis_button'),
          const Key('power_button'),
          const Key('negate_button'),
          const Key('equals_button'),
        ];

        for (final key in buttonKeys) {
          final container = findContainerByKey(tester, key);
          final decoration = container.decoration as BoxDecoration;
          expect(
            isCircularStyling(decoration),
            isTrue,
            reason: 'Button with key $key should have circular styling',
          );
        }
      });

      testWidgets('borderRadius exactly equals CalculatorDimensions.circularButtonRadius',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final container = findContainerByKey(tester, const Key('clear_button'));
        final decoration = container.decoration as BoxDecoration;
        final borderRadius = decoration.borderRadius as BorderRadius;

        expect(
          borderRadius.topLeft.x,
          equals(CalculatorDimensions.circularButtonRadius),
        );
        expect(borderRadius.topLeft.x, equals(1000.0));
      });

      testWidgets('all corners have same borderRadius for symmetric shape',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final container = findContainerByKey(tester, const Key('clear_button'));
        final decoration = container.decoration as BoxDecoration;
        final borderRadius = decoration.borderRadius as BorderRadius;

        // All corners should have identical radius
        expect(borderRadius.topLeft, equals(borderRadius.topRight));
        expect(borderRadius.topRight, equals(borderRadius.bottomRight));
        expect(borderRadius.bottomRight, equals(borderRadius.bottomLeft));
      });
    });

    group('Borderless Styling (no visible border)', () {
      testWidgets('clear button has borderless styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final container = findContainerByKey(tester, const Key('clear_button'));
        final decoration = container.decoration as BoxDecoration;

        expect(isBorderless(decoration), isTrue);
      });

      testWidgets('parenthesis button has borderless styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final container = findContainerByKey(tester, const Key('parenthesis_button'));
        final decoration = container.decoration as BoxDecoration;

        expect(isBorderless(decoration), isTrue);
      });

      testWidgets('power button has borderless styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final container = findContainerByKey(tester, const Key('power_button'));
        final decoration = container.decoration as BoxDecoration;

        expect(isBorderless(decoration), isTrue);
      });

      testWidgets('negate button has borderless styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final container = findContainerByKey(tester, const Key('negate_button'));
        final decoration = container.decoration as BoxDecoration;

        expect(isBorderless(decoration), isTrue);
      });

      testWidgets('equals button has borderless styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final container = findContainerByKey(tester, const Key('equals_button'));
        final decoration = container.decoration as BoxDecoration;

        expect(isBorderless(decoration), isTrue);
      });

      testWidgets('all keyed buttons have borderless styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final buttonKeys = [
          const Key('clear_button'),
          const Key('parenthesis_button'),
          const Key('power_button'),
          const Key('negate_button'),
          const Key('equals_button'),
        ];

        for (final key in buttonKeys) {
          final container = findContainerByKey(tester, key);
          final decoration = container.decoration as BoxDecoration;
          expect(
            isBorderless(decoration),
            isTrue,
            reason: 'Button with key $key should have borderless styling',
          );
        }
      });
    });

    group('Text Size (24sp)', () {
      testWidgets('clear button text "C" has fontSize 24.0',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final textWidget = tester.widget<Text>(find.text('C'));
        expect(textWidget.style?.fontSize, equals(24.0));
        expect(
          textWidget.style?.fontSize,
          equals(CalculatorDimensions.circularButtonTextSize),
        );
      });

      testWidgets('parenthesis button text "()" has fontSize 24.0',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final textWidget = tester.widget<Text>(find.text('()'));
        expect(textWidget.style?.fontSize, equals(24.0));
      });

      testWidgets('power button text "^" has fontSize 24.0',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final textWidget = tester.widget<Text>(find.text('^'));
        expect(textWidget.style?.fontSize, equals(24.0));
      });

      testWidgets('negate button text "+/-" has fontSize 24.0',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final textWidget = tester.widget<Text>(find.text('+/-'));
        expect(textWidget.style?.fontSize, equals(24.0));
      });

      testWidgets('equals button text "=" has fontSize 24.0',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final textWidget = tester.widget<Text>(find.text('='));
        expect(textWidget.style?.fontSize, equals(24.0));
      });

      testWidgets('all digit buttons (0-9) have fontSize 24.0',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        for (var i = 0; i <= 9; i++) {
          final textWidget = tester.widget<Text>(find.text('$i'));
          expect(
            textWidget.style?.fontSize,
            equals(24.0),
            reason: 'Digit $i should have fontSize 24.0',
          );
        }
      });

      testWidgets('all operator buttons have fontSize 24.0',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        const operators = ['+', '-', '×', '÷'];
        for (final op in operators) {
          final textWidget = tester.widget<Text>(find.text(op));
          expect(
            textWidget.style?.fontSize,
            equals(24.0),
            reason: 'Operator $op should have fontSize 24.0',
          );
        }
      });

      testWidgets('decimal button text "." has fontSize 24.0',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final textWidget = tester.widget<Text>(find.text('.'));
        expect(textWidget.style?.fontSize, equals(24.0));
      });

      testWidgets('all button labels have fontSize 24.0',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final buttonLabels = [
          'C', '()', '^', '÷',
          '7', '8', '9', '×',
          '4', '5', '6', '+',
          '1', '2', '3', '-',
          '+/-', '0', '.', '=',
        ];

        for (final label in buttonLabels) {
          final textWidget = tester.widget<Text>(find.text(label));
          expect(
            textWidget.style?.fontSize,
            equals(24.0),
            reason: 'Button "$label" should have fontSize 24.0',
          );
        }
      });
    });

    group('Consistent Circular Styling Across Button Types', () {
      testWidgets('all keyed buttons have same height',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final clearSizedBox = findSizedBoxByKey(tester, const Key('clear_button'));
        final parenthesisSizedBox = findSizedBoxByKey(tester, const Key('parenthesis_button'));
        final powerSizedBox = findSizedBoxByKey(tester, const Key('power_button'));
        final negateSizedBox = findSizedBoxByKey(tester, const Key('negate_button'));
        final equalsSizedBox = findSizedBoxByKey(tester, const Key('equals_button'));

        expect(clearSizedBox.height, equals(parenthesisSizedBox.height));
        expect(parenthesisSizedBox.height, equals(powerSizedBox.height));
        expect(powerSizedBox.height, equals(negateSizedBox.height));
        expect(negateSizedBox.height, equals(equalsSizedBox.height));
        expect(equalsSizedBox.height, equals(70.0));
      });

      testWidgets('all keyed buttons have same margin',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final clearPadding = findPaddingByKey(tester, const Key('clear_button'));
        final parenthesisPadding = findPaddingByKey(tester, const Key('parenthesis_button'));
        final powerPadding = findPaddingByKey(tester, const Key('power_button'));
        final negatePadding = findPaddingByKey(tester, const Key('negate_button'));
        final equalsPadding = findPaddingByKey(tester, const Key('equals_button'));

        expect(clearPadding.padding, equals(parenthesisPadding.padding));
        expect(parenthesisPadding.padding, equals(powerPadding.padding));
        expect(powerPadding.padding, equals(negatePadding.padding));
        expect(negatePadding.padding, equals(equalsPadding.padding));
        expect(equalsPadding.padding, equals(const EdgeInsets.all(5.0)));
      });

      testWidgets('all keyed buttons have circular styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final buttonKeys = [
          const Key('clear_button'),
          const Key('parenthesis_button'),
          const Key('power_button'),
          const Key('negate_button'),
          const Key('equals_button'),
        ];

        for (final key in buttonKeys) {
          final container = findContainerByKey(tester, key);
          final decoration = container.decoration as BoxDecoration;
          expect(
            isCircularStyling(decoration),
            isTrue,
            reason: 'Button with key $key should have circular styling',
          );
        }
      });
    });

    group('Visual Spacing Between Adjacent Buttons', () {
      testWidgets('adjacent buttons have 10dp visual spacing (5dp + 5dp margins)',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Verify that the combined margins create 10dp visual spacing
        // Each button has 5dp margin, so adjacent buttons have 5 + 5 = 10dp spacing
        final combinedSpacing = CalculatorDimensions.circularButtonMargin * 2;
        expect(combinedSpacing, equals(10.0));
      });

      testWidgets('grid padding matches button margin for edge consistency',
          (WidgetTester tester) async {
        // Verify that gridPadding equals circularButtonMargin
        expect(
          CalculatorDimensions.gridPadding,
          equals(CalculatorDimensions.circularButtonMargin),
        );
        expect(CalculatorDimensions.gridPadding, equals(5.0));
      });
    });

    group('Dimension Constant Verification', () {
      test('circularButtonHeight equals 70.0', () {
        expect(CalculatorDimensions.circularButtonHeight, equals(70.0));
      });

      test('circularButtonMargin equals 5.0', () {
        expect(CalculatorDimensions.circularButtonMargin, equals(5.0));
      });

      test('circularButtonTextSize equals 24.0', () {
        expect(CalculatorDimensions.circularButtonTextSize, equals(24.0));
      });

      test('circularButtonRadius equals 1000.0', () {
        expect(CalculatorDimensions.circularButtonRadius, equals(1000.0));
      });

      test('aliases match circular button constants', () {
        expect(
          CalculatorDimensions.buttonHeight,
          equals(CalculatorDimensions.circularButtonHeight),
        );
        expect(
          CalculatorDimensions.buttonMargin,
          equals(CalculatorDimensions.circularButtonMargin),
        );
        expect(
          CalculatorDimensions.buttonTextSize,
          equals(CalculatorDimensions.circularButtonTextSize),
        );
        expect(
          CalculatorDimensions.buttonBorderRadius,
          equals(CalculatorDimensions.circularButtonRadius),
        );
      });
    });

    group('Total Button Count', () {
      testWidgets('grid contains exactly 20 buttons (5 rows x 4 buttons)',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final buttonFinder = find.byType(CalculatorButton);
        expect(buttonFinder, findsNWidgets(20));
      });

      testWidgets('all expected button labels are present',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final expectedLabels = [
          'C', '()', '^', '÷',
          '7', '8', '9', '×',
          '4', '5', '6', '+',
          '1', '2', '3', '-',
          '+/-', '0', '.', '=',
        ];

        for (final label in expectedLabels) {
          expect(
            find.text(label),
            findsOneWidget,
            reason: 'Button with label "$label" should exist exactly once',
          );
        }
      });
    });
  });
}
