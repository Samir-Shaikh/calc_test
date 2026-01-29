import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:android_calculator_flutter/features/calculator/presentation/widgets/result_display_widget.dart';

void main() {
  group('ResultDisplayWidget RTL Tests', () {
    /// Helper function to build the widget with specified text direction.
    Widget buildTestWidget({
      required TextDirection textDirection,
      required String? result,
      String prefix = '= ',
    }) {
      return Directionality(
        textDirection: textDirection,
        child: MaterialApp(
          home: Scaffold(
            body: ResultDisplayWidget(
              result: result,
              prefix: prefix,
            ),
          ),
        ),
      );
    }

    group('Text Alignment in LTR Context', () {
      testWidgets('result text uses TextAlign.end in LTR context',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            result: '42',
          ),
        );

        // Find the result Text widget
        final textFinder = find.text('= 42');
        expect(textFinder, findsOneWidget);

        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.textAlign, equals(TextAlign.end));
      });

      testWidgets('result text aligns to right side visually in LTR context',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            result: '123.456',
          ),
        );

        // In LTR, TextAlign.end means right-aligned
        final textWidget = tester.widget<Text>(find.text('= 123.456'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });

      testWidgets('container uses AlignmentDirectional.centerEnd in LTR context',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            result: '100',
          ),
        );

        // Find the Container widget
        final containerFinder = find.byType(Container);
        expect(containerFinder, findsWidgets);

        // Get the Container that has AlignmentDirectional.centerEnd
        final containers = tester.widgetList<Container>(containerFinder).toList();
        final alignedContainer = containers.firstWhere(
          (container) {
            final alignment = container.alignment;
            return alignment == AlignmentDirectional.centerEnd;
          },
          orElse: () => throw TestFailure('No Container with AlignmentDirectional.centerEnd found'),
        );

        expect(alignedContainer.alignment, equals(AlignmentDirectional.centerEnd));
      });
    });

    group('Text Alignment in RTL Context', () {
      testWidgets('result text uses TextAlign.end in RTL context',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.rtl,
            result: '42',
          ),
        );

        // Find the result Text widget
        final textFinder = find.text('= 42');
        expect(textFinder, findsOneWidget);

        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.textAlign, equals(TextAlign.end));
      });

      testWidgets('result text aligns to left side visually in RTL context',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.rtl,
            result: '123.456',
          ),
        );

        // In RTL, TextAlign.end means left-aligned
        final textWidget = tester.widget<Text>(find.text('= 123.456'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });

      testWidgets('container uses AlignmentDirectional.centerEnd in RTL context',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.rtl,
            result: '100',
          ),
        );

        // Find the Container widget
        final containerFinder = find.byType(Container);
        expect(containerFinder, findsWidgets);

        // Get the Container that has AlignmentDirectional.centerEnd
        final containers = tester.widgetList<Container>(containerFinder).toList();
        final alignedContainer = containers.firstWhere(
          (container) {
            final alignment = container.alignment;
            return alignment == AlignmentDirectional.centerEnd;
          },
          orElse: () => throw TestFailure('No Container with AlignmentDirectional.centerEnd found'),
        );

        expect(alignedContainer.alignment, equals(AlignmentDirectional.centerEnd));
      });
    });

    group('Text Alignment Consistency', () {
      testWidgets(
          'TextAlign.end is used consistently regardless of text direction',
          (tester) async {
        // Test LTR
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            result: '999',
          ),
        );

        final ltrTextWidget = tester.widget<Text>(find.text('= 999'));
        final ltrTextAlign = ltrTextWidget.textAlign;

        // Test RTL
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.rtl,
            result: '999',
          ),
        );

        final rtlTextWidget = tester.widget<Text>(find.text('= 999'));
        final rtlTextAlign = rtlTextWidget.textAlign;

        // Both should use TextAlign.end
        expect(ltrTextAlign, equals(TextAlign.end));
        expect(rtlTextAlign, equals(TextAlign.end));
        expect(ltrTextAlign, equals(rtlTextAlign));
      });

      testWidgets(
          'AlignmentDirectional.centerEnd is used consistently regardless of text direction',
          (tester) async {
        // Test LTR
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            result: '888',
          ),
        );

        final ltrContainers = tester.widgetList<Container>(find.byType(Container)).toList();
        final ltrContainer = ltrContainers.firstWhere(
          (container) => container.alignment == AlignmentDirectional.centerEnd,
          orElse: () => throw TestFailure('No Container with AlignmentDirectional.centerEnd found in LTR'),
        );

        // Test RTL
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.rtl,
            result: '888',
          ),
        );

        final rtlContainers = tester.widgetList<Container>(find.byType(Container)).toList();
        final rtlContainer = rtlContainers.firstWhere(
          (container) => container.alignment == AlignmentDirectional.centerEnd,
          orElse: () => throw TestFailure('No Container with AlignmentDirectional.centerEnd found in RTL'),
        );

        // Both should use AlignmentDirectional.centerEnd
        expect(ltrContainer.alignment, equals(AlignmentDirectional.centerEnd));
        expect(rtlContainer.alignment, equals(AlignmentDirectional.centerEnd));
      });
    });

    group('Container Width in Both Directions', () {
      testWidgets('container uses full width in LTR context', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            result: '200',
          ),
        );

        // Find the Container widget
        final containerFinder = find.byType(Container);
        expect(containerFinder, findsWidgets);

        // Get the Container that has width: double.infinity
        final containers = tester.widgetList<Container>(containerFinder).toList();
        final fullWidthContainer = containers.firstWhere(
          (container) {
            final constraints = container.constraints;
            return constraints != null &&
                constraints.minWidth == double.infinity &&
                constraints.maxWidth == double.infinity;
          },
          orElse: () => throw TestFailure('No full-width Container found'),
        );

        expect(fullWidthContainer.constraints!.minWidth, equals(double.infinity));
      });

      testWidgets('container uses full width in RTL context', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.rtl,
            result: '200',
          ),
        );

        // Find the Container widget
        final containerFinder = find.byType(Container);
        expect(containerFinder, findsWidgets);

        // Get the Container that has width: double.infinity
        final containers = tester.widgetList<Container>(containerFinder).toList();
        final fullWidthContainer = containers.firstWhere(
          (container) {
            final constraints = container.constraints;
            return constraints != null &&
                constraints.minWidth == double.infinity &&
                constraints.maxWidth == double.infinity;
          },
          orElse: () => throw TestFailure('No full-width Container found'),
        );

        expect(fullWidthContainer.constraints!.minWidth, equals(double.infinity));
      });
    });

    group('Nested Directionality Override', () {
      testWidgets(
          'inner RTL context overrides outer LTR for result display',
          (tester) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: MaterialApp(
              home: Scaffold(
                body: Directionality(
                  textDirection: TextDirection.rtl,
                  child: const ResultDisplayWidget(result: '500'),
                ),
              ),
            ),
          ),
        );

        // The result text should still use TextAlign.end
        // which in the inner RTL context means left-aligned
        final textWidget = tester.widget<Text>(find.text('= 500'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });

      testWidgets(
          'inner LTR context overrides outer RTL for result display',
          (tester) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.rtl,
            child: MaterialApp(
              home: Scaffold(
                body: Directionality(
                  textDirection: TextDirection.ltr,
                  child: const ResultDisplayWidget(result: '500'),
                ),
              ),
            ),
          ),
        );

        // The result text should still use TextAlign.end
        // which in the inner LTR context means right-aligned
        final textWidget = tester.widget<Text>(find.text('= 500'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });
    });

    group('Result Display with Various Content', () {
      testWidgets('displays positive result with TextAlign.end in LTR',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            result: '12345',
          ),
        );

        final textWidget = tester.widget<Text>(find.text('= 12345'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });

      testWidgets('displays positive result with TextAlign.end in RTL',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.rtl,
            result: '12345',
          ),
        );

        final textWidget = tester.widget<Text>(find.text('= 12345'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });

      testWidgets('displays negative result with TextAlign.end in LTR',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            result: '-42.5',
          ),
        );

        final textWidget = tester.widget<Text>(find.text('= -42.5'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });

      testWidgets('displays negative result with TextAlign.end in RTL',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.rtl,
            result: '-42.5',
          ),
        );

        final textWidget = tester.widget<Text>(find.text('= -42.5'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });

      testWidgets('displays decimal result with TextAlign.end in LTR',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            result: '3.14159',
          ),
        );

        final textWidget = tester.widget<Text>(find.text('= 3.14159'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });

      testWidgets('displays decimal result with TextAlign.end in RTL',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.rtl,
            result: '3.14159',
          ),
        );

        final textWidget = tester.widget<Text>(find.text('= 3.14159'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });
    });

    group('Empty and Null Result Handling', () {
      testWidgets('renders nothing when result is null in LTR',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            result: null,
          ),
        );

        // Should render SizedBox.shrink() which has zero size
        final sizedBoxFinder = find.byType(SizedBox);
        expect(sizedBoxFinder, findsWidgets);
      });

      testWidgets('renders nothing when result is null in RTL',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.rtl,
            result: null,
          ),
        );

        // Should render SizedBox.shrink() which has zero size
        final sizedBoxFinder = find.byType(SizedBox);
        expect(sizedBoxFinder, findsWidgets);
      });

      testWidgets('renders nothing when result is empty in LTR',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            result: '',
          ),
        );

        // Should not find text with the prefix
        expect(find.text('= '), findsNothing);
      });

      testWidgets('renders nothing when result is empty in RTL',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.rtl,
            result: '',
          ),
        );

        // Should not find text with the prefix
        expect(find.text('= '), findsNothing);
      });
    });

    group('RTL-Aware Alignment Constants Usage', () {
      testWidgets('widget uses directional alignment not absolute alignment',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            result: '777',
          ),
        );

        final textWidget = tester.widget<Text>(find.text('= 777'));

        // Verify it uses TextAlign.end (directional) not TextAlign.right (absolute)
        expect(textWidget.textAlign, equals(TextAlign.end));
        expect(textWidget.textAlign, isNot(equals(TextAlign.right)));
        expect(textWidget.textAlign, isNot(equals(TextAlign.left)));
      });

      testWidgets('container uses directional alignment not absolute alignment',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            result: '777',
          ),
        );

        final containers = tester.widgetList<Container>(find.byType(Container)).toList();
        final alignedContainer = containers.firstWhere(
          (container) => container.alignment == AlignmentDirectional.centerEnd,
          orElse: () => throw TestFailure('No Container with AlignmentDirectional.centerEnd found'),
        );

        // Verify it uses AlignmentDirectional.centerEnd (directional) not Alignment.centerRight (absolute)
        expect(alignedContainer.alignment, equals(AlignmentDirectional.centerEnd));
        expect(alignedContainer.alignment, isNot(equals(Alignment.centerRight)));
        expect(alignedContainer.alignment, isNot(equals(Alignment.centerLeft)));
      });
    });

    group('Text Rendering Properties', () {
      testWidgets('result text has correct maxLines in LTR',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            result: '123',
          ),
        );

        final textWidget = tester.widget<Text>(find.text('= 123'));
        expect(textWidget.maxLines, equals(1));
        expect(textWidget.overflow, equals(TextOverflow.ellipsis));
      });

      testWidgets('result text has correct maxLines in RTL',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.rtl,
            result: '123',
          ),
        );

        final textWidget = tester.widget<Text>(find.text('= 123'));
        expect(textWidget.maxLines, equals(1));
        expect(textWidget.overflow, equals(TextOverflow.ellipsis));
      });
    });

    group('Custom Prefix Support', () {
      testWidgets('custom prefix works in LTR context',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            result: '42',
            prefix: 'Result: ',
          ),
        );

        expect(find.text('Result: 42'), findsOneWidget);

        final textWidget = tester.widget<Text>(find.text('Result: 42'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });

      testWidgets('custom prefix works in RTL context',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.rtl,
            result: '42',
            prefix: 'Result: ',
          ),
        );

        expect(find.text('Result: 42'), findsOneWidget);

        final textWidget = tester.widget<Text>(find.text('Result: 42'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });
    });

    group('Special Values Display', () {
      testWidgets('displays Infinity with TextAlign.end in LTR',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            result: 'Infinity',
          ),
        );

        final textWidget = tester.widget<Text>(find.text('= Infinity'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });

      testWidgets('displays Infinity with TextAlign.end in RTL',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.rtl,
            result: 'Infinity',
          ),
        );

        final textWidget = tester.widget<Text>(find.text('= Infinity'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });

      testWidgets('displays Error with TextAlign.end in LTR',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.ltr,
            result: 'Error',
          ),
        );

        final textWidget = tester.widget<Text>(find.text('= Error'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });

      testWidgets('displays Error with TextAlign.end in RTL',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            textDirection: TextDirection.rtl,
            result: 'Error',
          ),
        );

        final textWidget = tester.widget<Text>(find.text('= Error'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });
    });
  });
}
