import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/presentation/theme/calculator_dimensions.dart';

void main() {
  group('CalculatorDimensions - Circular Button Constants', () {
    group('circularButtonHeight', () {
      test('equals 70.0 logical pixels (maps to 70dp in Android)', () {
        expect(CalculatorDimensions.circularButtonHeight, equals(70.0));
      });

      test('buttonHeight alias equals circularButtonHeight', () {
        expect(
          CalculatorDimensions.buttonHeight,
          equals(CalculatorDimensions.circularButtonHeight),
        );
      });

      test('is a positive value', () {
        expect(CalculatorDimensions.circularButtonHeight, greaterThan(0));
      });
    });

    group('circularButtonMargin', () {
      test('equals 5.0 logical pixels (maps to 5dp in Android)', () {
        expect(CalculatorDimensions.circularButtonMargin, equals(5.0));
      });

      test('buttonMargin alias equals circularButtonMargin', () {
        expect(
          CalculatorDimensions.buttonMargin,
          equals(CalculatorDimensions.circularButtonMargin),
        );
      });

      test('is a positive value', () {
        expect(CalculatorDimensions.circularButtonMargin, greaterThan(0));
      });

      test('creates 10dp visual spacing between adjacent buttons', () {
        // When two buttons are adjacent, their combined margins create spacing
        final visualSpacing = CalculatorDimensions.circularButtonMargin * 2;
        expect(visualSpacing, equals(10.0));
      });
    });

    group('circularButtonTextSize', () {
      test('equals 24.0 logical pixels (maps to 24sp in Android)', () {
        expect(CalculatorDimensions.circularButtonTextSize, equals(24.0));
      });

      test('buttonTextSize alias equals circularButtonTextSize', () {
        expect(
          CalculatorDimensions.buttonTextSize,
          equals(CalculatorDimensions.circularButtonTextSize),
        );
      });

      test('is a positive value', () {
        expect(CalculatorDimensions.circularButtonTextSize, greaterThan(0));
      });

      test('is appropriate for button text (between 12 and 48)', () {
        expect(
          CalculatorDimensions.circularButtonTextSize,
          greaterThanOrEqualTo(12.0),
        );
        expect(
          CalculatorDimensions.circularButtonTextSize,
          lessThanOrEqualTo(48.0),
        );
      });
    });

    group('circularButtonRadius', () {
      test('is sufficiently large to create circular appearance (>= 1000)', () {
        expect(
          CalculatorDimensions.circularButtonRadius,
          greaterThanOrEqualTo(1000.0),
        );
      });

      test('equals 1000.0 logical pixels', () {
        expect(CalculatorDimensions.circularButtonRadius, equals(1000.0));
      });

      test('buttonBorderRadius alias equals circularButtonRadius', () {
        expect(
          CalculatorDimensions.buttonBorderRadius,
          equals(CalculatorDimensions.circularButtonRadius),
        );
      });

      test('is positive value', () {
        expect(CalculatorDimensions.circularButtonRadius, greaterThan(0));
      });

      test('is larger than button height for full circular effect', () {
        expect(
          CalculatorDimensions.circularButtonRadius,
          greaterThan(CalculatorDimensions.circularButtonHeight),
        );
      });
    });

    group('grid spacing consistency', () {
      test('buttonSpacing is 0.0 (buttons handle their own margins)', () {
        expect(CalculatorDimensions.buttonSpacing, equals(0.0));
      });

      test('rowSpacing is 0.0 (buttons handle their own margins)', () {
        expect(CalculatorDimensions.rowSpacing, equals(0.0));
      });

      test('gridPadding equals circularButtonMargin for consistency', () {
        expect(
          CalculatorDimensions.gridPadding,
          equals(CalculatorDimensions.circularButtonMargin),
        );
      });
    });

    group('dimension relationships', () {
      test('text size is smaller than button height', () {
        expect(
          CalculatorDimensions.circularButtonTextSize,
          lessThan(CalculatorDimensions.circularButtonHeight),
        );
      });

      test('margin is smaller than button height', () {
        expect(
          CalculatorDimensions.circularButtonMargin,
          lessThan(CalculatorDimensions.circularButtonHeight),
        );
      });

      test('button height provides adequate space for text and padding', () {
        // Button height should be at least 2x the text size
        expect(
          CalculatorDimensions.circularButtonHeight,
          greaterThanOrEqualTo(CalculatorDimensions.circularButtonTextSize * 2),
        );
      });
    });
  });
}
