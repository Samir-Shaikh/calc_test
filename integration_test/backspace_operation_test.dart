import 'package:android_calculator_flutter/features/calculator/presentation/widgets/backspace_button.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/widgets/backspace_button_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Backspace Operation Integration Tests', () {
    group('AC1: Delete last character from expression', () {
      testWidgets('deletes last character from "123" to show "12"',
          (WidgetTester tester) async {
        // Build the calculator app
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter expression '123'
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Verify expression is displayed
        expect(find.text('123'), findsOneWidget);

        // Tap backspace button (⌫ in the button grid)
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();

        // Verify expression now shows '12'
        expect(find.text('12'), findsOneWidget);
        expect(find.text('123'), findsNothing);
      });

      testWidgets('deletes last character from single digit expression',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter single digit '7'
        await tester.tap(find.text('7'));
        await tester.pumpAndSettle();

        // Verify expression is displayed
        expect(find.text('7'), findsWidgets);

        // Tap backspace button
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();

        // Verify expression is now empty (displays '0' as placeholder)
        expect(find.text('0'), findsOneWidget);
      });

      testWidgets('deletes last operator from expression',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter expression '5+'
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        // Verify expression is displayed
        expect(find.text('5+'), findsOneWidget);

        // Tap backspace button
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();

        // Verify only '5' remains
        expect(find.text('5'), findsWidgets);
        expect(find.text('5+'), findsNothing);
      });

      testWidgets('deletes last decimal point from expression',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter expression '3.'
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('.'));
        await tester.pumpAndSettle();

        // Verify expression is displayed
        expect(find.text('3.'), findsOneWidget);

        // Tap backspace button
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();

        // Verify only '3' remains
        expect(find.text('3'), findsWidgets);
        expect(find.text('3.'), findsNothing);
      });
    });

    group('AC2: Delete character at cursor position', () {
      testWidgets('deletes character from "1+2" resulting in deletion at cursor',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter expression '1+2'
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Verify expression is displayed
        expect(find.text('1+2'), findsOneWidget);

        // Tap backspace - deletes last character (cursor at end)
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();

        // Verify '2' was deleted, showing '1+'
        expect(find.text('1+'), findsOneWidget);
        expect(find.text('1+2'), findsNothing);
      });

      testWidgets('sequential backspaces delete from right to left',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter expression '1+2'
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // Tap backspace three times
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        expect(find.text('1+'), findsOneWidget);

        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        expect(find.text('1'), findsWidgets);

        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        // Should show '0' placeholder for empty expression
        expect(find.text('0'), findsOneWidget);
      });
    });

    group('AC3: Backspace on empty expression', () {
      testWidgets('backspace on empty expression does not cause error',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Verify expression is empty (shows '0' placeholder)
        expect(find.text('0'), findsOneWidget);

        // Tap backspace button - should not throw
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();

        // Verify no error and expression still shows placeholder
        expect(find.text('0'), findsOneWidget);
      });

      testWidgets('multiple backspaces on empty expression remain stable',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Tap backspace multiple times on empty expression
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();

        // Verify no error and can still enter new expression
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        expect(find.text('5'), findsWidgets);
      });

      testWidgets('backspace after clearing expression works correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter and clear expression
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Verify expression is cleared
        expect(find.text('123'), findsNothing);

        // Tap backspace on empty expression
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();

        // Should remain stable
        expect(find.text('0'), findsOneWidget);
      });
    });

    group('AC4: Backspace at cursor position 0', () {
      testWidgets('backspace at position 0 leaves expression unchanged',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter expression and delete all characters to reach position 0
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        // Delete character to get empty expression (cursor at 0)
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();

        // Now at position 0, another backspace should do nothing
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();

        // Expression should remain empty (placeholder '0')
        expect(find.text('0'), findsOneWidget);
      });

      testWidgets('can enter new expression after backspace at position 0',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Delete on empty (position 0)
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();

        // Enter new expression
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('8'));
        await tester.pumpAndSettle();

        // Verify new expression is correct
        expect(find.text('9×8'), findsOneWidget);
      });
    });

    group('AC5: Backspace button visual verification', () {
      testWidgets('backspace button displays delete icon (⌫) in button grid',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Verify backspace button with ⌫ symbol exists in button grid
        expect(find.text('⌫'), findsOneWidget);
      });

      testWidgets('BackspaceButton widget displays backspace_outlined icon',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Verify BackspaceButton widget exists
        expect(find.byType(BackspaceButton), findsOneWidget);

        // Verify it contains the backspace icon
        expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
      });

      testWidgets('BackspaceButton is positioned above the number pad',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Find the BackspaceButton and verify it exists
        final backspaceButton = find.byType(BackspaceButton);
        expect(backspaceButton, findsOneWidget);

        // Find a button in the grid (e.g., '7' which is in the first row)
        final digitButton = find.text('7');
        expect(digitButton, findsOneWidget);

        // Get positions
        final backspacePosition = tester.getCenter(backspaceButton);
        final digitPosition = tester.getCenter(digitButton);

        // BackspaceButton should be above (smaller y value) the digit buttons
        expect(backspacePosition.dy, lessThan(digitPosition.dy),
            reason: 'BackspaceButton should be positioned above the number pad');
      });

      testWidgets('BackspaceButton config has correct styling',
          (WidgetTester tester) async {
        // Verify BackspaceButtonConfig provides correct values
        expect(BackspaceButtonConfig.icon, equals(Icons.backspace_outlined));
        expect(BackspaceButtonConfig.semanticLabel, equals('Backspace'));
        expect(BackspaceButtonConfig.iconSize, equals(24));
        expect(BackspaceButtonConfig.backgroundColor, isNotNull);
        expect(BackspaceButtonConfig.iconColor, equals(Colors.white));
        expect(BackspaceButtonConfig.decoration, isNotNull);
      });

      testWidgets('BackspaceButton has correct background color (#505050)',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Verify BackspaceButtonConfig has the correct gray background
        expect(BackspaceButtonConfig.backgroundColor,
            equals(const Color(0xFF505050)));
      });
    });

    group('Backspace in complex expressions', () {
      testWidgets('backspace with decimal numbers',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '12.34'
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('.'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        expect(find.text('12.34'), findsOneWidget);

        // Delete '4'
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        expect(find.text('12.3'), findsOneWidget);

        // Delete '3'
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        expect(find.text('12.'), findsOneWidget);

        // Delete '.'
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        expect(find.text('12'), findsOneWidget);
      });

      testWidgets('backspace with multiple operators',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '5+3×2'
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        expect(find.text('5+3×2'), findsOneWidget);

        // Delete characters one by one
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        expect(find.text('5+3×'), findsOneWidget);

        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        expect(find.text('5+3'), findsOneWidget);

        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        expect(find.text('5+'), findsOneWidget);
      });

      testWidgets('backspace with parentheses',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '(2+3)'
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();

        expect(find.text('(2+3)'), findsOneWidget);

        // Delete closing parenthesis
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        expect(find.text('(2+3'), findsOneWidget);

        // Delete '3'
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        expect(find.text('(2+'), findsOneWidget);
      });

      testWidgets('backspace with power operator',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '2^3' using the power button
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('power_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        expect(find.text('2^3'), findsOneWidget);

        // Delete '3'
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        expect(find.text('2^'), findsOneWidget);

        // Delete '^'
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        expect(find.text('2'), findsWidgets);
      });

      testWidgets('backspace with division operator',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '10÷5'
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('÷'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        expect(find.text('10÷5'), findsOneWidget);

        // Delete and verify
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        expect(find.text('10÷'), findsOneWidget);
      });

      testWidgets('backspace with percentage operator',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '50%'
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('%'));
        await tester.pumpAndSettle();

        expect(find.text('50%'), findsOneWidget);

        // Delete '%'
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        expect(find.text('50'), findsOneWidget);
      });
    });

    group('Backspace followed by new input', () {
      testWidgets('delete and enter new characters continues properly',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '123'
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        expect(find.text('123'), findsOneWidget);

        // Delete '3' and enter '4'
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        expect(find.text('124'), findsOneWidget);
      });

      testWidgets('delete and enter different type of character',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '12+'
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        expect(find.text('12+'), findsOneWidget);

        // Delete '+' and enter '×' instead
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();

        expect(find.text('12×'), findsOneWidget);
      });

      testWidgets('delete all and enter new expression',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '5+3'
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        expect(find.text('5+3'), findsOneWidget);

        // Delete all characters
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();

        // Enter completely new expression
        await tester.tap(find.text('7'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('×'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('8'));
        await tester.pumpAndSettle();

        expect(find.text('7×8'), findsOneWidget);
      });

      testWidgets('backspace then evaluate expression',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '5+35'
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        expect(find.text('5+35'), findsOneWidget);

        // Delete '5' to make '5+3'
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        expect(find.text('5+3'), findsOneWidget);

        // Evaluate
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Should show result of 5+3=8
        expect(find.text('8'), findsOneWidget);
      });

      testWidgets('backspace after evaluation clears result',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter and evaluate '2+2'
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Verify result
        expect(find.text('4'), findsOneWidget);

        // Backspace should modify the expression (not the result)
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();

        // Expression should now be '2+'
        expect(find.text('2+'), findsOneWidget);
        // Result should be cleared
        expect(find.textContaining('= 4'), findsNothing);
      });

      testWidgets('multiple corrections using backspace',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '123'
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();
        expect(find.text('123'), findsOneWidget);

        // Correction 1: Change to '124'
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();
        expect(find.text('124'), findsOneWidget);

        // Correction 2: Change to '125+6'
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('6'));
        await tester.pumpAndSettle();
        expect(find.text('125+6'), findsOneWidget);

        // Evaluate
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();
        expect(find.text('131'), findsOneWidget);
      });
    });

    group('Backspace interaction with other operations', () {
      testWidgets('backspace then clear resets correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '123'
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Backspace once
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        expect(find.text('12'), findsOneWidget);

        // Then clear
        await tester.tap(find.text('C'));
        await tester.pumpAndSettle();

        // Should be fully cleared
        expect(find.text('12'), findsNothing);
        expect(find.text('0'), findsOneWidget);
      });

      testWidgets('backspace preserves bracket state',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Enter '(5' 
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        expect(find.text('(5'), findsOneWidget);

        // Backspace to remove '5'
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        expect(find.text('('), findsWidgets);

        // Enter new number and close parenthesis
        await tester.tap(find.text('7'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('parenthesis_button')));
        await tester.pumpAndSettle();

        // Should have (7)
        expect(find.text('(7)'), findsOneWidget);
      });
    });

    group('Test helpers with backspace', () {
      testWidgets('enterExpression and backspace work together',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CalculatorTestApp());
        await tester.pumpAndSettle();

        // Use helper to enter expression
        await tester.enterExpression('25+35');
        expect(find.text('25+35'), findsOneWidget);

        // Use backspace
        await tester.tap(find.text('⌫'));
        await tester.pumpAndSettle();
        expect(find.text('25+3'), findsOneWidget);

        // Continue with more input
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();
        expect(find.text('25+30'), findsOneWidget);

        // Evaluate
        await tester.tapEquals();
        tester.verifyResult('55');
      });
    });
  });
}
