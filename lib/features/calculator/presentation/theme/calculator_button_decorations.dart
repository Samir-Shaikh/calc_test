import 'package:flutter/material.dart';

import 'calculator_colors.dart';
import 'calculator_dimensions.dart';

/// Decoration configurations for calculator buttons.
///
/// This class provides pre-configured BoxDecoration instances for
/// different button types in the calculator UI. All decorations use
/// a circular/pill shape achieved through a high border radius (1000dp)
/// and borderless styling for the iOS-inspired appearance.
class CalculatorButtonDecorations {
  CalculatorButtonDecorations._();

  // ==================== Border Radius ====================

  /// The border radius used for all circular buttons.
  ///
  /// A high value (1000.0) ensures buttons appear fully circular/pill-shaped
  /// regardless of their actual dimensions.
  static final BorderRadius _circularBorderRadius = BorderRadius.circular(
    CalculatorDimensions.circularButtonRadius,
  );

  // ==================== Factory Methods ====================

  /// Creates a circular button decoration with the specified background color.
  ///
  /// This factory method creates a BoxDecoration with:
  /// - High border radius (1000dp) for circular/pill shape
  /// - No border (borderless styling)
  /// - Specified background color
  ///
  /// Use this when you need a custom circular button decoration.
  static BoxDecoration circularButtonDecoration({
    required Color backgroundColor,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: _circularBorderRadius,
      border: Border.all(color: Colors.transparent, width: 0),
    );
  }

  /// Creates a pressed state circular button decoration.
  ///
  /// This factory method creates a BoxDecoration for pressed/highlighted states
  /// with:
  /// - High border radius (1000dp) for circular/pill shape
  /// - No border (borderless styling)
  /// - Slightly lighter/adjusted background color for visual feedback
  ///
  /// The [pressedColor] should typically be a lighter or darker variant
  /// of the button's normal background color.
  static BoxDecoration circularButtonPressedDecoration({
    required Color pressedColor,
  }) {
    return BoxDecoration(
      color: pressedColor,
      borderRadius: _circularBorderRadius,
      border: Border.all(color: Colors.transparent, width: 0),
    );
  }

  // ==================== Numeric Button Decorations ====================

  /// Decoration for numeric buttons (0-9).
  ///
  /// Features a circular shape with dark gray (#333333) background color
  /// achieved through high border radius (1000dp) and borderless styling.
  static BoxDecoration numericButton = circularButtonDecoration(
    backgroundColor: CalculatorColors.numericButtonBackground,
  );

  /// Pressed state decoration for numeric buttons.
  ///
  /// Features a lighter gray background for visual feedback while
  /// maintaining the circular shape and borderless styling.
  static BoxDecoration numericButtonPressed = circularButtonPressedDecoration(
    pressedColor: CalculatorColors.numericButtonBackgroundPressed,
  );

  // ==================== Operator Button Decorations ====================

  /// Decoration for operator buttons (+, -, ×, ÷).
  ///
  /// Features a circular shape with orange (#FF9500) background color
  /// achieved through high border radius (1000dp) and borderless styling.
  static BoxDecoration operatorButton = circularButtonDecoration(
    backgroundColor: CalculatorColors.operatorButtonBackground,
  );

  /// Pressed state decoration for operator buttons.
  ///
  /// Features a lighter orange background for visual feedback while
  /// maintaining the circular shape and borderless styling.
  static BoxDecoration operatorButtonPressed = circularButtonPressedDecoration(
    pressedColor: CalculatorColors.operatorButtonBackgroundPressed,
  );

  // ==================== Function Button Decorations ====================

  /// Decoration for function buttons (parenthesis, power, clear, negate).
  ///
  /// Features a circular shape with gray (#505050) background color
  /// achieved through high border radius (1000dp) and borderless styling.
  static BoxDecoration functionButton = circularButtonDecoration(
    backgroundColor: CalculatorColors.functionButtonBackground,
  );

  /// Pressed state decoration for function buttons.
  ///
  /// Features a lighter gray background for visual feedback while
  /// maintaining the circular shape and borderless styling.
  static BoxDecoration functionButtonPressed = circularButtonPressedDecoration(
    pressedColor: CalculatorColors.functionButtonBackgroundPressed,
  );

  // ==================== Specific Button Decorations ====================
  // These use the common function/operator decorations but are kept for
  // semantic clarity and potential future customization.

  /// Decoration for the parenthesis button.
  ///
  /// Features a circular shape with gray (#505050) background color
  /// achieved through high border radius (1000dp) and borderless styling.
  static BoxDecoration parenthesisButton = circularButtonDecoration(
    backgroundColor: CalculatorColors.parenthesisButtonBackground,
  );

  /// Pressed state decoration for the parenthesis button.
  static BoxDecoration parenthesisButtonPressed = circularButtonPressedDecoration(
    pressedColor: CalculatorColors.functionButtonBackgroundPressed,
  );

  /// Decoration for the power button.
  ///
  /// Features a circular shape with gray (#505050) background color
  /// achieved through high border radius (1000dp) and borderless styling.
  static BoxDecoration powerButton = circularButtonDecoration(
    backgroundColor: CalculatorColors.powerButtonBackground,
  );

  /// Pressed state decoration for the power button.
  static BoxDecoration powerButtonPressed = circularButtonPressedDecoration(
    pressedColor: CalculatorColors.functionButtonBackgroundPressed,
  );

  /// Decoration for the clear button.
  ///
  /// Features a circular shape with gray (#505050) background color
  /// achieved through high border radius (1000dp) and borderless styling.
  static BoxDecoration clearButton = circularButtonDecoration(
    backgroundColor: CalculatorColors.clearButtonBackground,
  );

  /// Pressed state decoration for the clear button.
  static BoxDecoration clearButtonPressed = circularButtonPressedDecoration(
    pressedColor: CalculatorColors.functionButtonBackgroundPressed,
  );

  /// Decoration for the backspace button.
  ///
  /// Features a circular shape with gray (#505050) background color
  /// achieved through high border radius (1000dp) and borderless styling.
  static BoxDecoration backspaceButton = circularButtonDecoration(
    backgroundColor: CalculatorColors.backspaceButtonBackground,
  );

  /// Pressed state decoration for the backspace button.
  static BoxDecoration backspaceButtonPressed = circularButtonPressedDecoration(
    pressedColor: CalculatorColors.functionButtonBackgroundPressed,
  );

  /// Decoration for the negate button.
  ///
  /// Features a circular shape with gray (#505050) background color
  /// achieved through high border radius (1000dp) and borderless styling.
  static BoxDecoration negateButton = circularButtonDecoration(
    backgroundColor: CalculatorColors.negateButtonBackground,
  );

  /// Pressed state decoration for the negate button.
  static BoxDecoration negateButtonPressed = circularButtonPressedDecoration(
    pressedColor: CalculatorColors.functionButtonBackgroundPressed,
  );

  /// Decoration for the equals button.
  ///
  /// Features a circular shape with orange (#FF9500) background color
  /// achieved through high border radius (1000dp) and borderless styling.
  static BoxDecoration equalsButton = circularButtonDecoration(
    backgroundColor: CalculatorColors.equalsButtonBackground,
  );

  /// Pressed state decoration for the equals button.
  static BoxDecoration equalsButtonPressed = circularButtonPressedDecoration(
    pressedColor: CalculatorColors.operatorButtonBackgroundPressed,
  );
}
