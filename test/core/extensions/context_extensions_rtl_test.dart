import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/core/extensions/context_extensions.dart';

void main() {
  group('DirectionalityExtension', () {
    group('isRtl', () {
      testWidgets('returns false in LTR context', (tester) async {
        late bool isRtlValue;

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                isRtlValue = context.isRtl;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(isRtlValue, isFalse);
      });

      testWidgets('returns true in RTL context', (tester) async {
        late bool isRtlValue;

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.rtl,
            child: Builder(
              builder: (context) {
                isRtlValue = context.isRtl;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(isRtlValue, isTrue);
      });
    });

    group('isLtr', () {
      testWidgets('returns true in LTR context', (tester) async {
        late bool isLtrValue;

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                isLtrValue = context.isLtr;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(isLtrValue, isTrue);
      });

      testWidgets('returns false in RTL context', (tester) async {
        late bool isLtrValue;

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.rtl,
            child: Builder(
              builder: (context) {
                isLtrValue = context.isLtr;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(isLtrValue, isFalse);
      });
    });

    group('textDirection', () {
      testWidgets('returns TextDirection.ltr in LTR context', (tester) async {
        late TextDirection textDirectionValue;

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                textDirectionValue = context.textDirection;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(textDirectionValue, equals(TextDirection.ltr));
      });

      testWidgets('returns TextDirection.rtl in RTL context', (tester) async {
        late TextDirection textDirectionValue;

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.rtl,
            child: Builder(
              builder: (context) {
                textDirectionValue = context.textDirection;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(textDirectionValue, equals(TextDirection.rtl));
      });
    });

    group('endAlign', () {
      testWidgets('returns TextAlign.end regardless of direction',
          (tester) async {
        late TextAlign endAlignLtr;
        late TextAlign endAlignRtl;

        // Test in LTR context
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                endAlignLtr = context.endAlign;
                return const SizedBox();
              },
            ),
          ),
        );

        // Test in RTL context
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.rtl,
            child: Builder(
              builder: (context) {
                endAlignRtl = context.endAlign;
                return const SizedBox();
              },
            ),
          ),
        );

        // endAlign should always return TextAlign.end
        // which Flutter resolves to the correct side based on directionality
        expect(endAlignLtr, equals(TextAlign.end));
        expect(endAlignRtl, equals(TextAlign.end));
      });

      testWidgets('renders text aligned to end in LTR (right side)',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: TextDirection.ltr,
              child: Builder(
                builder: (context) {
                  return Scaffold(
                    body: SizedBox(
                      width: 200,
                      child: Text(
                        'Test',
                        textAlign: context.endAlign,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.text('Test'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });

      testWidgets('renders text aligned to end in RTL (left side)',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Builder(
                builder: (context) {
                  return Scaffold(
                    body: SizedBox(
                      width: 200,
                      child: Text(
                        'Test',
                        textAlign: context.endAlign,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.text('Test'));
        expect(textWidget.textAlign, equals(TextAlign.end));
      });
    });

    group('startAlign', () {
      testWidgets('returns TextAlign.start regardless of direction',
          (tester) async {
        late TextAlign startAlignLtr;
        late TextAlign startAlignRtl;

        // Test in LTR context
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                startAlignLtr = context.startAlign;
                return const SizedBox();
              },
            ),
          ),
        );

        // Test in RTL context
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.rtl,
            child: Builder(
              builder: (context) {
                startAlignRtl = context.startAlign;
                return const SizedBox();
              },
            ),
          ),
        );

        // startAlign should always return TextAlign.start
        // which Flutter resolves to the correct side based on directionality
        expect(startAlignLtr, equals(TextAlign.start));
        expect(startAlignRtl, equals(TextAlign.start));
      });

      testWidgets('renders text aligned to start in LTR (left side)',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: TextDirection.ltr,
              child: Builder(
                builder: (context) {
                  return Scaffold(
                    body: SizedBox(
                      width: 200,
                      child: Text(
                        'Test',
                        textAlign: context.startAlign,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.text('Test'));
        expect(textWidget.textAlign, equals(TextAlign.start));
      });

      testWidgets('renders text aligned to start in RTL (right side)',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Builder(
                builder: (context) {
                  return Scaffold(
                    body: SizedBox(
                      width: 200,
                      child: Text(
                        'Test',
                        textAlign: context.startAlign,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.text('Test'));
        expect(textWidget.textAlign, equals(TextAlign.start));
      });
    });

    group('isRtl and isLtr are mutually exclusive', () {
      testWidgets('only one can be true at a time in LTR', (tester) async {
        late bool isRtlValue;
        late bool isLtrValue;

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                isRtlValue = context.isRtl;
                isLtrValue = context.isLtr;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(isRtlValue, isFalse);
        expect(isLtrValue, isTrue);
        expect(isRtlValue != isLtrValue, isTrue);
      });

      testWidgets('only one can be true at a time in RTL', (tester) async {
        late bool isRtlValue;
        late bool isLtrValue;

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.rtl,
            child: Builder(
              builder: (context) {
                isRtlValue = context.isRtl;
                isLtrValue = context.isLtr;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(isRtlValue, isTrue);
        expect(isLtrValue, isFalse);
        expect(isRtlValue != isLtrValue, isTrue);
      });
    });

    group('nested directionality', () {
      testWidgets('inner context overrides outer directionality',
          (tester) async {
        late bool outerIsRtl;
        late bool innerIsRtl;

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (outerContext) {
                outerIsRtl = outerContext.isRtl;
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: Builder(
                    builder: (innerContext) {
                      innerIsRtl = innerContext.isRtl;
                      return const SizedBox();
                    },
                  ),
                );
              },
            ),
          ),
        );

        expect(outerIsRtl, isFalse);
        expect(innerIsRtl, isTrue);
      });
    });
  });
}
