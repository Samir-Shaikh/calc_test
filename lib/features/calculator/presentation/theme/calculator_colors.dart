import 'package:flutter/material.dart';

/// Color constants for the calculator UI.
///
/// This class defines all the colors used throughout the calculator,
/// ensuring consistency and easy theming.
class CalculatorColors {
  CalculatorColors._();

  // ==================== Button Colors ====================

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
