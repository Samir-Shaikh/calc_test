import 'package:flutter/material.dart';

/// Color constants for the calculator UI.
///
/// This class defines all the colors used throughout the calculator,
/// ensuring consistency and easy theming.
class CalculatorColors {
  CalculatorColors._();

  /// Background color for the parenthesis button (#505050).
  ///
  /// A gray color that provides visual distinction for the parenthesis
  /// button while maintaining good contrast with white text.
  static const Color parenthesisButtonBackground = Color(0xFF505050);

  /// Text color for buttons with dark backgrounds.
  ///
  /// White color to ensure readability on dark button backgrounds
  /// like the parenthesis button.
  static const Color lightButtonText = Colors.white;

  /// Text color for buttons with light backgrounds.
  ///
  /// Dark color to ensure readability on light button backgrounds.
  static const Color darkButtonText = Colors.black;
}
