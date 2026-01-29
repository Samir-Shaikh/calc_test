import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/calculator_toast.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/theme/calculator_colors.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/theme/calculator_dimensions.dart';

void main() {
  Widget createTestWidget({required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => child,
        ),
      ),
    );
  }

  group('CalculatorToast', () {
    group('show() method', () {
      testWidgets('displays SnackBar with correct message', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Invalid Input',
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        // Tap button to show toast
        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        // Verify SnackBar is displayed
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Invalid Input'), findsOneWidget);
      });

      testWidgets('displays error icon for error type toast', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Invalid Input',
                  type: ToastType.error,
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        // Verify error icon is displayed
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('displays success icon for success type toast', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Success!',
                  type: ToastType.success,
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        // Verify success icon is displayed
        expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      });

      testWidgets('displays info icon for info type toast', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Information',
                  type: ToastType.info,
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        // Verify info icon is displayed
        expect(find.byIcon(Icons.info_outline), findsOneWidget);
      });

      testWidgets('uses correct background color for error type', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Test message',
                  type: ToastType.error,
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        // Find the SnackBar and verify its background color
        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, equals(CalculatorColors.toastErrorBackgroundColor));
      });

      testWidgets('uses floating behavior', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Test message',
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.behavior, equals(SnackBarBehavior.floating));
      });

      testWidgets('uses correct text style', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Test message',
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        // Find the message text and verify its style
        final textFinder = find.text('Test message');
        final textWidget = tester.widget<Text>(textFinder);
        
        expect(textWidget.style?.color, equals(CalculatorColors.toastTextColor));
        expect(textWidget.style?.fontSize, equals(CalculatorDimensions.toastFontSize));
        expect(textWidget.style?.fontWeight, equals(FontWeight.w500));
      });

      testWidgets('uses correct error icon color', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Error',
                  type: ToastType.error,
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
        expect(icon.color, equals(CalculatorColors.toastErrorColor));
        expect(icon.size, equals(CalculatorDimensions.toastIconSize));
      });

      testWidgets('uses correct success icon color', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Success',
                  type: ToastType.success,
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle_outline));
        expect(icon.color, equals(CalculatorColors.toastSuccessColor));
      });

      testWidgets('uses correct info icon color', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Info',
                  type: ToastType.info,
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        final icon = tester.widget<Icon>(find.byIcon(Icons.info_outline));
        expect(icon.color, equals(CalculatorColors.toastInfoColor));
      });

      testWidgets('uses default duration when not specified', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Test message',
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.duration, equals(CalculatorDimensions.toastDuration));
      });

      testWidgets('uses custom duration when specified', (WidgetTester tester) async {
        const customDuration = Duration(seconds: 5);
        
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Test message',
                  duration: customDuration,
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.duration, equals(customDuration));
      });

      testWidgets('defaults to error type when type not specified', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Test message',
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        // Error icon should be displayed by default
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('hides current snackbar before showing new one', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    CalculatorToast.show(
                      context,
                      message: 'First Message',
                    );
                  },
                  child: const Text('Show First'),
                ),
                ElevatedButton(
                  onPressed: () {
                    CalculatorToast.show(
                      context,
                      message: 'Second Message',
                    );
                  },
                  child: const Text('Show Second'),
                ),
              ],
            ),
          ),
        ));

        // Show first toast
        await tester.tap(find.text('Show First'));
        await tester.pump();
        expect(find.text('First Message'), findsOneWidget);

        // Show second toast - should replace the first
        await tester.tap(find.text('Show Second'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        
        expect(find.text('Second Message'), findsOneWidget);
      });
    });

    group('showInvalidInput() method', () {
      testWidgets('displays Invalid Input message', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.showInvalidInput(context);
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        // Verify 'Invalid Input' text is displayed
        expect(find.text('Invalid Input'), findsOneWidget);
        expect(find.text(CalculatorToast.invalidInputMessage), findsOneWidget);
      });

      testWidgets('uses error type with error icon', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.showInvalidInput(context);
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        // Verify error icon is displayed
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('uses short duration (2 seconds)', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.showInvalidInput(context);
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.duration, equals(CalculatorDimensions.toastDurationShort));
        expect(snackBar.duration, equals(const Duration(seconds: 2)));
      });

      testWidgets('uses error background color', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.showInvalidInput(context);
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, equals(CalculatorColors.toastErrorBackgroundColor));
      });
    });

    group('toast auto-dismiss configuration', () {
      testWidgets('snackbar has default duration of 3 seconds', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Default duration test',
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        // Verify the snackbar has the default 3-second duration
        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.duration, equals(const Duration(seconds: 3)));
        expect(snackBar.duration, equals(CalculatorDimensions.toastDuration));
      });

      testWidgets('snackbar accepts custom duration', (WidgetTester tester) async {
        const testDuration = Duration(milliseconds: 500);
        
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Custom duration test',
                  duration: testDuration,
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        // Verify the snackbar has the custom duration set
        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.duration, equals(testDuration));
      });

      testWidgets('toast remains visible before duration expires', (WidgetTester tester) async {
        const testDuration = Duration(seconds: 2);
        
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Still visible',
                  duration: testDuration,
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        // Advance time but not past duration
        await tester.pump(const Duration(seconds: 1));

        // Toast should still be visible
        expect(find.text('Still visible'), findsOneWidget);
      });

      testWidgets('snackbar has horizontal dismiss direction', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Dismiss test',
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        // Verify the snackbar can be dismissed horizontally
        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.dismissDirection, equals(DismissDirection.horizontal));
      });
    });

    group('toast styling matches specification', () {
      testWidgets('toast has correct border radius', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Test message',
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        final shape = snackBar.shape as RoundedRectangleBorder;
        final borderRadius = shape.borderRadius as BorderRadius;
        
        expect(borderRadius, equals(BorderRadius.circular(CalculatorDimensions.toastBorderRadius)));
      });

      testWidgets('toast has correct margin', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Test message',
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.margin, equals(const EdgeInsets.all(CalculatorDimensions.toastMargin)));
      });

      testWidgets('toast icon has correct size', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Test',
                  type: ToastType.error,
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
        expect(icon.size, equals(CalculatorDimensions.toastIconSize));
      });

      testWidgets('toast text has correct font size', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Test message',
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        final textWidget = tester.widget<Text>(find.text('Test message'));
        expect(textWidget.style?.fontSize, equals(CalculatorDimensions.toastFontSize));
      });

      testWidgets('toast text has white color', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Test message',
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        final textWidget = tester.widget<Text>(find.text('Test message'));
        expect(textWidget.style?.color, equals(CalculatorColors.toastTextColor));
        expect(textWidget.style?.color, equals(Colors.white));
      });

      testWidgets('error toast uses error background color', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Error',
                  type: ToastType.error,
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, equals(CalculatorColors.toastErrorBackgroundColor));
      });

      testWidgets('success toast uses standard background color', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Success',
                  type: ToastType.success,
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, equals(CalculatorColors.toastBackgroundColor));
      });

      testWidgets('info toast uses standard background color', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CalculatorToast.show(
                  context,
                  message: 'Info',
                  type: ToastType.info,
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ));

        await tester.tap(find.text('Show Toast'));
        await tester.pump();

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, equals(CalculatorColors.toastBackgroundColor));
      });
    });

    group('ToastType enum', () {
      test('has error type', () {
        expect(ToastType.values, contains(ToastType.error));
      });

      test('has success type', () {
        expect(ToastType.values, contains(ToastType.success));
      });

      test('has info type', () {
        expect(ToastType.values, contains(ToastType.info));
      });

      test('has exactly three types', () {
        expect(ToastType.values.length, equals(3));
      });
    });

    group('invalidInputMessage constant', () {
      test('equals Invalid Input', () {
        expect(CalculatorToast.invalidInputMessage, equals('Invalid Input'));
      });
    });
  });
}
