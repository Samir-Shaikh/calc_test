import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Division Operation Integration Tests', () {
    testWidgets('division by zero shows Infinity on display - AC4', (WidgetTester tester) async {
      // Build the calculator app
      await tester.pumpWidget(const CalculatorTestApp());
      await tester.pumpAndSettle();

      // Tap '1'
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      // Tap '0'
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();

      // Tap '÷' (division operator)
      await tester.tap(find.text('÷'));
      await tester.pumpAndSettle();

      // Tap '0'
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();

      // Tap '=' to evaluate
      await tester.tap(find.text('='));
      await tester.pumpAndSettle();

      // Verify 'Infinity' is displayed
      expect(find.text('Infinity'), findsOneWidget);
    });

    testWidgets('simple 1/0 division by zero shows Infinity', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorTestApp());
      await tester.pumpAndSettle();

      // Tap '1'
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      // Tap '÷'
      await tester.tap(find.text('÷'));
      await tester.pumpAndSettle();

      // Tap '0'
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();

      // Tap '='
      await tester.tap(find.text('='));
      await tester.pumpAndSettle();

      // Verify 'Infinity' is displayed
      expect(find.text('Infinity'), findsOneWidget);
    });

    testWidgets('normal division operation works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorTestApp());
      await tester.pumpAndSettle();

      // Tap '8'
      await tester.tap(find.text('8'));
      await tester.pumpAndSettle();

      // Tap '÷'
      await tester.tap(find.text('÷'));
      await tester.pumpAndSettle();

      // Tap '2'
      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      // Tap '='
      await tester.tap(find.text('='));
      await tester.pumpAndSettle();

      // Verify '4' is displayed
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('0/0 division shows NaN', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorTestApp());
      await tester.pumpAndSettle();

      // Find and tap the first '0' button (there are two 0 buttons)
      final zeroButtons = find.text('0');
      
      // Tap '0'
      await tester.tap(zeroButtons.first);
      await tester.pumpAndSettle();

      // Tap '÷'
      await tester.tap(find.text('÷'));
      await tester.pumpAndSettle();

      // Tap '0' again
      await tester.tap(zeroButtons.first);
      await tester.pumpAndSettle();

      // Tap '='
      await tester.tap(find.text('='));
      await tester.pumpAndSettle();

      // Verify 'NaN' is displayed
      expect(find.text('NaN'), findsOneWidget);
    });
  });
}
