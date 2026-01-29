import 'package:flutter/material.dart';

import 'calculator_colors.dart';
import 'calculator_dimensions.dart';

/// Typography configurations for calculator UI elements.
///
/// This class provides pre-configured TextStyle instances for
/// different text elements in the calculator UI, ensuring consistent
/// typography across all button types and display elements.
class CalculatorTypography {
  CalculatorTypography._();

  // ==================== Base Button Text Styles ====================

  /// Base text style for circular calculator buttons.
  ///
  /// Features:
  /// - Font size: 24.0 logical pixels (equivalent to 24sp in Android)
  /// - Font weight: w500 (medium) for optimal readability
  /// - No letter spacing adjustments
  ///
  /// This is the foundation style that other button text styles build upon.
  /// Use the specific variants (numeric, operator, function) for actual buttons.
  static const TextStyle circularButtonTextStyle = TextStyle(
    fontSize: CalculatorDimensions.circularButtonTextSize,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );

  // ==================== Numeric Button Text Styles ====================

  /// Text style for numeric buttons (0-9, decimal point).
  ///
  /// Uses white text color for optimal contrast against the dark gray
  /// (#333333) numeric button background.
  static const TextStyle numericButtonTextStyle = TextStyle(
    fontSize: CalculatorDimensions.circularButtonTextSize,
    fontWeight: FontWeight.w500,
    color: CalculatorColors.lightButtonText,
    height: 1.0,
  );

  // ==================== Operator Button Text Styles ====================

  /// Text style for operator buttons (+, -, ×, ÷, =).
  ///
  /// Uses white text color for optimal contrast against the orange
  /// (#FF9500) operator button background.
  static const TextStyle operatorButtonTextStyle = TextStyle(
    fontSize: CalculatorDimensions.circularButtonTextSize,
    fontWeight: FontWeight.w500,
    color: CalculatorColors.lightButtonText,
    height: 1.0,
  );

  // ==================== Function Button Text Styles ====================

  /// Text style for function buttons (parenthesis, power, clear, negate).
  ///
  /// Uses white text color for optimal contrast against the gray
  /// (#505050) function button background.
  ///
  /// Note: While the task mentions function buttons may use black/dark text,
  /// the current color scheme uses gray backgrounds (#505050) which requires
  /// white text for proper contrast. If lighter function button backgrounds
  /// are used in the future, switch to [functionButtonDarkTextStyle].
  static const TextStyle functionButtonTextStyle = TextStyle(
    fontSize: CalculatorDimensions.circularButtonTextSize,
    fontWeight: FontWeight.w500,
    color: CalculatorColors.lightButtonText,
    height: 1.0,
  );

  /// Alternative text style for function buttons with light backgrounds.
  ///
  /// Uses dark text color for optimal contrast against light-colored
  /// function button backgrounds. Use this when function buttons have
  /// backgrounds lighter than #808080 (medium gray).
  static const TextStyle functionButtonDarkTextStyle = TextStyle(
    fontSize: CalculatorDimensions.circularButtonTextSize,
    fontWeight: FontWeight.w500,
    color: CalculatorColors.darkButtonText,
    height: 1.0,
  );

  // ==================== Semantic Aliases ====================
  // These aliases provide more specific naming for common use cases.

  /// Text style for the equals button (=).
  ///
  /// Uses the same style as operator buttons for visual consistency.
  static const TextStyle equalsButtonTextStyle = operatorButtonTextStyle;

  /// Text style for the clear button (AC/C).
  ///
  /// Uses the same style as function buttons for visual consistency.
  static const TextStyle clearButtonTextStyle = functionButtonTextStyle;

  /// Text style for the negate button (+/-).
  ///
  /// Uses the same style as function buttons for visual consistency.
  static const TextStyle negateButtonTextStyle = functionButtonTextStyle;

  /// Text style for the parenthesis button ( ).
  ///
  /// Uses the same style as function buttons for visual consistency.
  static const TextStyle parenthesisButtonTextStyle = functionButtonTextStyle;

  /// Text style for the power button (^).
  ///
  /// Uses the same style as function buttons for visual consistency.
  static const TextStyle powerButtonTextStyle = functionButtonTextStyle;

  // ==================== Factory Methods ====================

  /// Creates a button text style with the specified color.
  ///
  /// This factory method creates a TextStyle with:
  /// - Font size: 24.0 logical pixels (24sp equivalent)
  /// - Font weight: w500 (medium)
  /// - Specified text color
  ///
  /// Use this when you need a custom button text color not covered
  /// by the pre-defined styles.
  static TextStyle buttonTextStyleWithColor(Color color) {
    return TextStyle(
      fontSize: CalculatorDimensions.circularButtonTextSize,
      fontWeight: FontWeight.w500,
      color: color,
      height: 1.0,
    );
  }

  /// Creates a button text style with custom font weight.
  ///
  /// This factory method creates a TextStyle with:
  /// - Font size: 24.0 logical pixels (24sp equivalent)
  /// - Specified font weight
  /// - Specified text color
  ///
  /// Use this when you need different font weights for specific buttons.
  static TextStyle buttonTextStyleCustom({
    required Color color,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return TextStyle(
      fontSize: CalculatorDimensions.circularButtonTextSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.0,
    );
  }
}
