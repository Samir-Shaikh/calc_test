import 'package:flutter/material.dart';

import '../theme/calculator_button_decorations.dart';
import '../theme/calculator_colors.dart';

/// Configuration for the negate button (+/-) in the calculator.
///
/// This class follows the established button config pattern, providing
/// all the styling and configuration needed to render the negate
/// button with consistent appearance.
///
/// The negate button displays '+/-' and uses a gray (#505050)
/// background with white text for good contrast, consistent with
/// other utility/function buttons.
class NegateButtonConfig {
  /// The label displayed on the button.
  static const String label = '+/-';

  /// The background color of the button.
  ///
  /// Uses the gray (#505050) color defined in CalculatorColors,
  /// consistent with other function buttons.
  static Color get backgroundColor => CalculatorColors.negateButtonBackground;

  /// The text color of the button.
  ///
  /// Uses white for good contrast against the gray background.
  static Color get textColor => CalculatorColors.lightButtonText;

  /// The decoration for the button.
  ///
  /// Provides a circular shape with the gray background.
  static BoxDecoration get decoration =>
      CalculatorButtonDecorations.negateButton;

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
  NegateButtonConfig._();
}
