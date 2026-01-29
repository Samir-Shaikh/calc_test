import 'package:flutter/material.dart';

import '../theme/calculator_button_decorations.dart';
import '../theme/calculator_colors.dart';

/// Configuration for the parenthesis button in the calculator.
///
/// This class follows the OperatorButtonConfig pattern, providing
/// all the styling and configuration needed to render the parenthesis
/// button with consistent appearance.
///
/// The parenthesis button displays '()' and uses a gray (#505050)
/// background with white text for good contrast.
class ParenthesisButtonConfig {
  /// The label displayed on the button.
  static const String label = '()';

  /// The background color of the button.
  ///
  /// Uses the gray (#505050) color defined in CalculatorColors.
  static Color get backgroundColor =>
      CalculatorColors.parenthesisButtonBackground;

  /// The text color of the button.
  ///
  /// Uses white for good contrast against the gray background.
  static Color get textColor => CalculatorColors.lightButtonText;

  /// The decoration for the button.
  ///
  /// Provides a circular shape with the gray background.
  static BoxDecoration get decoration =>
      CalculatorButtonDecorations.parenthesisButton;

  /// The text style for the button label.
  ///
  /// Configures white text with appropriate size and weight
  /// for calculator button display.
  static TextStyle get textStyle => TextStyle(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.w500,
      );

  /// Prevents instantiation of this configuration class.
  ParenthesisButtonConfig._();
}
