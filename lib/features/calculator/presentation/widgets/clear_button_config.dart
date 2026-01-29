import 'package:flutter/material.dart';

import '../theme/calculator_button_decorations.dart';
import '../theme/calculator_colors.dart';

/// Configuration for the clear button in the calculator.
///
/// This class follows the ParenthesisButtonConfig pattern, providing
/// all the styling and configuration needed to render the clear
/// button with consistent appearance.
///
/// The clear button displays 'C' and uses a gray (#505050)
/// background with white text for good contrast.
class ClearButtonConfig {
  /// The label displayed on the button.
  static const String label = 'C';

  /// The background color of the button.
  ///
  /// Uses the gray (#505050) color defined in CalculatorColors.
  static Color get backgroundColor => CalculatorColors.clearButtonBackground;

  /// The text color of the button.
  ///
  /// Uses white for good contrast against the gray background.
  static Color get textColor => CalculatorColors.lightButtonText;

  /// The decoration for the button.
  ///
  /// Provides a circular shape with the gray background.
  static BoxDecoration get decoration =>
      CalculatorButtonDecorations.clearButton;

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
  ClearButtonConfig._();
}
