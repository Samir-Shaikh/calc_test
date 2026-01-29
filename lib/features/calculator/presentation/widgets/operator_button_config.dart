import 'package:flutter/material.dart';

import '../theme/calculator_button_decorations.dart';
import '../theme/calculator_colors.dart';

/// Configuration for operator buttons in the calculator.
///
/// This class provides styling and configuration for operator buttons
/// (+, -, ×, ÷) and the equals button with consistent appearance.
///
/// The operator buttons use an orange (#FF9500) background with white
/// text for good contrast.
class OperatorButtonConfig {
  /// The background color of operator buttons.
  ///
  /// Uses the orange (#FF9500) color defined in CalculatorColors.
  static Color get backgroundColor => CalculatorColors.operatorButtonBackground;

  /// The text color of operator buttons.
  ///
  /// Uses white for good contrast against the orange background.
  static Color get textColor => CalculatorColors.lightButtonText;

  /// The decoration for operator buttons.
  ///
  /// Provides a circular shape with the orange background.
  static BoxDecoration get decoration =>
      CalculatorButtonDecorations.operatorButton;

  /// The text style for operator button labels.
  ///
  /// Configures white text with appropriate size and weight
  /// for calculator button display.
  static TextStyle get textStyle => TextStyle(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.w500,
      );

  /// Prevents instantiation of this configuration class.
  OperatorButtonConfig._();
}

/// Configuration for the equals button in the calculator.
///
/// This class follows the OperatorButtonConfig pattern, providing
/// all the styling and configuration needed to render the equals
/// button with consistent appearance.
///
/// The equals button displays '=' and uses an orange (#FF9500)
/// background with white text for good contrast.
class EqualsButtonConfig {
  /// The label displayed on the button.
  static const String label = '=';

  /// The background color of the button.
  ///
  /// Uses the orange (#FF9500) color defined in CalculatorColors.
  static Color get backgroundColor => CalculatorColors.equalsButtonBackground;

  /// The text color of the button.
  ///
  /// Uses white for good contrast against the orange background.
  static Color get textColor => CalculatorColors.lightButtonText;

  /// The decoration for the button.
  ///
  /// Provides a circular shape with the orange background.
  static BoxDecoration get decoration =>
      CalculatorButtonDecorations.equalsButton;

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
  EqualsButtonConfig._();
}
