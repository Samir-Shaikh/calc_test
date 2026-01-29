import 'package:flutter/material.dart';

import '../theme/calculator_button_decorations.dart';
import '../theme/calculator_colors.dart';

/// Configuration for the backspace button in the calculator.
///
/// This class follows the ClearButtonConfig pattern, providing
/// all the styling and configuration needed to render the backspace
/// button with consistent appearance.
///
/// The backspace button displays a delete icon and uses a gray (#505050)
/// background with white icon for good contrast.
class BackspaceButtonConfig {
  /// The icon displayed on the button.
  ///
  /// Uses the system backspace icon which represents delete/backspace action.
  static const IconData icon = Icons.backspace_outlined;

  /// The semantic label for accessibility.
  ///
  /// Provides a description for screen readers and accessibility tools.
  static const String semanticLabel = 'Backspace';

  /// The background color of the button.
  ///
  /// Uses the gray (#505050) color defined in CalculatorColors.
  static Color get backgroundColor =>
      CalculatorColors.backspaceButtonBackground;

  /// The icon color of the button.
  ///
  /// Uses white for good contrast against the gray background.
  static Color get iconColor => CalculatorColors.lightButtonText;

  /// The decoration for the button.
  ///
  /// Provides a circular shape with the gray background.
  static BoxDecoration get decoration =>
      CalculatorButtonDecorations.backspaceButton;

  /// The size of the icon.
  ///
  /// Configured to be appropriately sized for calculator button display.
  static const double iconSize = 24;

  /// Creates the icon widget for the backspace button.
  ///
  /// Returns a configured [Icon] widget with appropriate size,
  /// color, and semantic label for accessibility.
  static Icon get iconWidget => Icon(
        icon,
        size: iconSize,
        color: iconColor,
        semanticLabel: semanticLabel,
      );

  /// Prevents instantiation of this configuration class.
  BackspaceButtonConfig._();
}
