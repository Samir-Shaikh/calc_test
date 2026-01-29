import 'package:flutter/material.dart';

/// Color constants for the calculator UI.
///
/// This class defines all the colors used throughout the calculator,
/// ensuring consistency and easy theming.
class CalculatorColors {
  CalculatorColors._();

  // ==================== Numeric Button Colors ====================

  /// Background color for numeric buttons (#333333).
  ///
  /// A dark gray color used for number buttons (0-9) and decimal point,
  /// providing good contrast with white text.
  static const Color numericButtonBackground = Color(0xFF333333);

  /// Pressed state background color for numeric buttons (#4D4D4D).
  ///
  /// A lighter gray color that provides visual feedback when
  /// numeric buttons are pressed.
  static const Color numericButtonBackgroundPressed = Color(0xFF4D4D4D);

  // ==================== Function Button Colors ====================

  /// Background color for function buttons (#505050).
  ///
  /// A gray color used for function buttons (parenthesis, power, clear,
  /// negate, backspace) that provides visual distinction while maintaining
  /// good contrast with white text.
  static const Color functionButtonBackground = Color(0xFF505050);

  /// Pressed state background color for function buttons (#6A6A6A).
  ///
  /// A lighter gray color that provides visual feedback when
  /// function buttons are pressed.
  static const Color functionButtonBackgroundPressed = Color(0xFF6A6A6A);

  /// Background color for the parenthesis button (#505050).
  ///
  /// A gray color that provides visual distinction for the parenthesis
  /// button while maintaining good contrast with white text.
  static const Color parenthesisButtonBackground = Color(0xFF505050);

  /// Background color for the power button (#505050).
  ///
  /// A gray color that provides visual distinction for the power
  /// button while maintaining good contrast with white text.
  static const Color powerButtonBackground = Color(0xFF505050);

  /// Background color for the clear button (#505050).
  ///
  /// A gray color that provides visual distinction for the clear
  /// button while maintaining good contrast with white text.
  static const Color clearButtonBackground = Color(0xFF505050);

  /// Background color for the backspace button (#505050).
  ///
  /// A gray color that provides visual distinction for the backspace
  /// button while maintaining good contrast with white icon.
  static const Color backspaceButtonBackground = Color(0xFF505050);

  /// Background color for the negate button (#505050).
  ///
  /// A gray color that provides visual distinction for the negate
  /// button while maintaining good contrast with white text.
  static const Color negateButtonBackground = Color(0xFF505050);

  // ==================== Operator Button Colors ====================

  /// Background color for operator buttons (#FF9500).
  ///
  /// An orange color used for operator buttons (+, -, ×, ÷) and the
  /// equals button, providing visual distinction and good contrast
  /// with white text.
  static const Color operatorButtonBackground = Color(0xFFFF9500);

  /// Pressed state background color for operator buttons (#FFB340).
  ///
  /// A lighter orange color that provides visual feedback when
  /// operator buttons are pressed.
  static const Color operatorButtonBackgroundPressed = Color(0xFFFFB340);

  /// Background color for the equals button (#FF9500).
  ///
  /// Uses the same orange color as other operator buttons for
  /// visual consistency across the calculator UI.
  static const Color equalsButtonBackground = Color(0xFFFF9500);

  // ==================== Button Text Colors ====================

  /// Text color for buttons with dark backgrounds.
  ///
  /// White color to ensure readability on dark button backgrounds
  /// like the parenthesis button.
  static const Color lightButtonText = Colors.white;

  /// Text color for buttons with light backgrounds.
  ///
  /// Dark color to ensure readability on light button backgrounds.
  static const Color darkButtonText = Colors.black;

  // ==================== Toast Colors ====================

  /// Background color for toast notifications.
  ///
  /// A dark gray color that matches the calculator's dark theme
  /// and provides good contrast for text readability.
  static const Color toastBackgroundColor = Color(0xFF323232);

  /// Text color for toast notification messages.
  ///
  /// White color to ensure readability on the dark toast background.
  static const Color toastTextColor = Colors.white;

  /// Icon color for error toast notifications.
  ///
  /// A red color to clearly indicate error states like 'Invalid Input'.
  static const Color toastErrorColor = Color(0xFFEF5350);

  /// Icon color for success toast notifications.
  ///
  /// A green color to indicate successful operations.
  static const Color toastSuccessColor = Color(0xFF66BB6A);

  /// Icon color for informational toast notifications.
  ///
  /// A blue color for neutral informational messages.
  static const Color toastInfoColor = Color(0xFF42A5F5);
}
