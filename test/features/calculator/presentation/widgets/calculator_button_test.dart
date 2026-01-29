import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_button.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/theme/calculator_dimensions.dart';

void main() {
  group('CalculatorButton Widget Tests', () {
    late bool wasPressed;

    setUp(() {
      wasPressed = false;
    });

    Widget createTestWidget({
      String label = '5',
      VoidCallback? onPressed,
      Color backgroundColor = Colors.grey,
      Color textColor = Colors.white,
      BoxDecoration? decoration,
      TextStyle? textStyle,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            child: CalculatorButton(
              label: label,
              onPressed: onPressed ?? () => wasPressed = true,
              backgroundColor: backgroundColor,
              textColor: textColor,
              decoration: decoration,
              textStyle: textStyle,
            ),
          ),
        ),
      );
    }

    group('Button Rendering', () {
      testWidgets('renders with correct label', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(label: '7'));

        expect(find.text('7'), findsOneWidget);
      });

      testWidgets('renders with operator label', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(label: '+'));

        expect(find.text('+'), findsOneWidget);
      });

      testWidgets('renders with function label', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(label: 'C'));

        expect(find.text('C'), findsOneWidget);
      });

      testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.byType(CalculatorButton));
        await tester.pump();

        expect(wasPressed, isTrue);
      });
    });

    group('Button Height Constraint', () {
      testWidgets('button has height of 70.0 (circularButtonHeight)',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Find the SizedBox that constrains the button height
        final sizedBoxFinder = find.descendant(
          of: find.byType(CalculatorButton),
          matching: find.byType(SizedBox),
        );
        expect(sizedBoxFinder, findsOneWidget);

        final sizedBox = tester.widget<SizedBox>(sizedBoxFinder);
        expect(sizedBox.height, equals(CalculatorDimensions.circularButtonHeight));
        expect(sizedBox.height, equals(70.0));
      });

      testWidgets('button height matches CalculatorDimensions constant',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final sizedBox = tester.widget<SizedBox>(
          find.descendant(
            of: find.byType(CalculatorButton),
            matching: find.byType(SizedBox),
          ),
        );

        expect(
          sizedBox.height,
          equals(CalculatorDimensions.circularButtonHeight),
        );
      });
    });

    group('Button Margin/Padding', () {
      testWidgets('button has Padding widget with 5.0 margin',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Find the Padding widget that provides margins (first descendant)
        final paddingFinder = find.descendant(
          of: find.byType(CalculatorButton),
          matching: find.byType(Padding),
        );
        // There might be multiple Padding widgets, use .first
        expect(paddingFinder, findsWidgets);

        final padding = tester.widget<Padding>(paddingFinder.first);
        expect(
          padding.padding,
          equals(const EdgeInsets.all(CalculatorDimensions.circularButtonMargin)),
        );
        expect(
          padding.padding,
          equals(const EdgeInsets.all(5.0)),
        );
      });

      testWidgets('margin matches CalculatorDimensions.circularButtonMargin',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final paddingFinder = find.descendant(
          of: find.byType(CalculatorButton),
          matching: find.byType(Padding),
        );
        final padding = tester.widget<Padding>(paddingFinder.first);

        final edgeInsets = padding.padding as EdgeInsets;
        expect(edgeInsets.left, equals(CalculatorDimensions.circularButtonMargin));
        expect(edgeInsets.right, equals(CalculatorDimensions.circularButtonMargin));
        expect(edgeInsets.top, equals(CalculatorDimensions.circularButtonMargin));
        expect(edgeInsets.bottom, equals(CalculatorDimensions.circularButtonMargin));
      });
    });

    group('Circular Shape Decoration', () {
      testWidgets('button has BoxDecoration with circular borderRadius',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Find the Container with decoration
        final containerFinder = find.descendant(
          of: find.byType(CalculatorButton),
          matching: find.byType(Container),
        );
        expect(containerFinder, findsOneWidget);

        final container = tester.widget<Container>(containerFinder);
        final decoration = container.decoration as BoxDecoration;

        expect(decoration.borderRadius, isNotNull);
        final borderRadius = decoration.borderRadius as BorderRadius;
        expect(
          borderRadius.topLeft.x,
          greaterThanOrEqualTo(1000.0),
        );
      });

      testWidgets('borderRadius matches CalculatorDimensions.circularButtonRadius',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(CalculatorButton),
            matching: find.byType(Container),
          ),
        );

        final decoration = container.decoration as BoxDecoration;
        final borderRadius = decoration.borderRadius as BorderRadius;

        expect(
          borderRadius.topLeft.x,
          equals(CalculatorDimensions.circularButtonRadius),
        );
        expect(borderRadius.topLeft.x, equals(1000.0));
      });

      testWidgets('high borderRadius creates pill/circular shape',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(CalculatorButton),
            matching: find.byType(Container),
          ),
        );

        final decoration = container.decoration as BoxDecoration;
        final borderRadius = decoration.borderRadius as BorderRadius;

        // All corners should have the same high radius for consistent circular shape
        expect(borderRadius.topLeft.x, equals(borderRadius.topRight.x));
        expect(borderRadius.topRight.x, equals(borderRadius.bottomRight.x));
        expect(borderRadius.bottomRight.x, equals(borderRadius.bottomLeft.x));
      });
    });

    group('Borderless Styling', () {
      testWidgets('button decoration has no border (borderless appearance)',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(CalculatorButton),
            matching: find.byType(Container),
          ),
        );

        final decoration = container.decoration as BoxDecoration;

        // Verify no border is present
        expect(decoration.border, isNull);
      });

      testWidgets('decoration has background color but no border',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(backgroundColor: Colors.blue));

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(CalculatorButton),
            matching: find.byType(Container),
          ),
        );

        final decoration = container.decoration as BoxDecoration;

        // Has background color
        expect(decoration.color, equals(Colors.blue));
        // No border
        expect(decoration.border, isNull);
      });
    });

    group('Text Size', () {
      testWidgets('button text has fontSize of 24.0',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(label: '5'));

        final textWidget = tester.widget<Text>(find.text('5'));
        final textStyle = textWidget.style!;

        expect(textStyle.fontSize, equals(24.0));
        expect(
          textStyle.fontSize,
          equals(CalculatorDimensions.circularButtonTextSize),
        );
      });

      testWidgets('text size matches CalculatorDimensions.circularButtonTextSize',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(label: '+'));

        final textWidget = tester.widget<Text>(find.text('+'));
        final textStyle = textWidget.style!;

        expect(
          textStyle.fontSize,
          equals(CalculatorDimensions.circularButtonTextSize),
        );
      });

      testWidgets('text has correct color from textColor parameter',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          label: '7',
          textColor: Colors.red,
        ));

        final textWidget = tester.widget<Text>(find.text('7'));
        final textStyle = textWidget.style!;

        expect(textStyle.color, equals(Colors.red));
      });
    });

    group('Custom Decoration Support', () {
      testWidgets('uses custom decoration when provided',
          (WidgetTester tester) async {
        final customDecoration = BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(20),
        );

        await tester.pumpWidget(createTestWidget(
          decoration: customDecoration,
        ));

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(CalculatorButton),
            matching: find.byType(Container),
          ),
        );

        expect(container.decoration, equals(customDecoration));
      });

      testWidgets('uses default decoration when custom is not provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          backgroundColor: Colors.green,
        ));

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(CalculatorButton),
            matching: find.byType(Container),
          ),
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, equals(Colors.green));
        expect(
          (decoration.borderRadius as BorderRadius).topLeft.x,
          equals(CalculatorDimensions.circularButtonRadius),
        );
      });
    });

    group('Custom TextStyle Support', () {
      testWidgets('merges custom textStyle with base style',
          (WidgetTester tester) async {
        const customTextStyle = TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        );

        await tester.pumpWidget(createTestWidget(
          label: '9',
          textColor: Colors.white,
          textStyle: customTextStyle,
        ));

        final textWidget = tester.widget<Text>(find.text('9'));
        final textStyle = textWidget.style!;

        // Should have base fontSize from dimensions
        expect(
          textStyle.fontSize,
          equals(CalculatorDimensions.circularButtonTextSize),
        );
        // Should have custom fontWeight
        expect(textStyle.fontWeight, equals(FontWeight.bold));
        // Should have custom letterSpacing
        expect(textStyle.letterSpacing, equals(2.0));
      });
    });

    group('Widget Structure', () {
      testWidgets('has Padding -> SizedBox -> Material -> InkWell -> Container structure',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Verify widget hierarchy exists within CalculatorButton
        expect(
          find.descendant(
            of: find.byType(CalculatorButton),
            matching: find.byType(Padding),
          ),
          findsWidgets, // May have multiple padding widgets
        );
        expect(
          find.descendant(
            of: find.byType(CalculatorButton),
            matching: find.byType(SizedBox),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(CalculatorButton),
            matching: find.byType(Material),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(CalculatorButton),
            matching: find.byType(InkWell),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(CalculatorButton),
            matching: find.byType(Container),
          ),
          findsOneWidget,
        );
      });

      testWidgets('uses transparent Material for ripple effect',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final material = tester.widget<Material>(
          find.descendant(
            of: find.byType(CalculatorButton),
            matching: find.byType(Material),
          ),
        );

        expect(material.type, equals(MaterialType.transparency));
      });

      testWidgets('InkWell has circular borderRadius for ripple clipping',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final inkWell = tester.widget<InkWell>(
          find.descendant(
            of: find.byType(CalculatorButton),
            matching: find.byType(InkWell),
          ),
        );

        expect(inkWell.borderRadius, isNotNull);
        expect(
          inkWell.borderRadius!.topLeft.x,
          equals(CalculatorDimensions.circularButtonRadius),
        );
      });

      testWidgets('text is centered within button',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(label: '0'));

        // Find Center widget within Container
        final centerFinder = find.descendant(
          of: find.byType(Container),
          matching: find.byType(Center),
        );
        expect(centerFinder, findsOneWidget);

        // Text should be within Center
        expect(
          find.descendant(of: centerFinder, matching: find.text('0')),
          findsOneWidget,
        );
      });
    });
  });
}
