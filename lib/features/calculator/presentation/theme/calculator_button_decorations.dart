import 'package:flutter/material.dart';

import 'calculator_colors.dart';

/// Decoration configurations for calculator buttons.
///
/// This class provides pre-configured BoxDecoration instances for
/// different button types in the calculator UI.
class CalculatorButtonDecorations {
  CalculatorButtonDecorations._();

  /// Decoration for the parenthesis button.
  ///
  /// Features a circular shape with gray (#505050) background color
  /// that provides visual distinction from other button types.
  static BoxDecoration parenthesisButton = BoxDecoration(
    color: CalculatorColors.parenthesisButtonBackground,
    shape: BoxShape.circle,
  );

  /// Decoration for the power button.
  ///
  /// Features a circular shape with gray (#505050) background color
  /// that provides visual distinction from other button types.
  static BoxDecoration powerButton = BoxDecoration(
    color: CalculatorColors.powerButtonBackground,
    shape: BoxShape.circle,
  );

  /// Decoration for the clear button.
  ///
  /// Features a circular shape with gray (#505050) background color
  /// that provides visual distinction from other button types.
  static BoxDecoration clearButton = BoxDecoration(
    color: CalculatorColors.clearButtonBackground,
    shape: BoxShape.circle,
  );

  /// Decoration for the backspace button.
  ///
  /// Features a circular shape with gray (#505050) background color
  /// that provides visual distinction from other button types.
  static BoxDecoration backspaceButton = BoxDecoration(
    color: CalculatorColors.backspaceButtonBackground,
    shape: BoxShape.circle,
  );

  /// Decoration for the negate button.
  ///
  /// Features a circular shape with gray (#505050) background color
  /// that provides visual distinction from other button types.
  static BoxDecoration negateButton = BoxDecoration(
    color: CalculatorColors.negateButtonBackground,
    shape: BoxShape.circle,
  );

  /// Decoration for operator buttons (+, -, ×, ÷).
  ///
  /// Features a circular shape with orange (#FF9500) background color
  /// that provides visual distinction for operator buttons.
  static BoxDecoration operatorButton = BoxDecoration(
    color: CalculatorColors.operatorButtonBackground,
    shape: BoxShape.circle,
  );

  /// Decoration for the equals button.
  ///
  /// Features a circular shape with orange (#FF9500) background color
  /// consistent with other operator buttons.
  static BoxDecoration equalsButton = BoxDecoration(
    color: CalculatorColors.equalsButtonBackground,
    shape: BoxShape.circle,
  );

  /// Creates a custom circular button decoration with the specified color.
  ///
  /// Use this factory method when you need a circular button with
  /// a custom background color.
  static BoxDecoration circularButton({required Color backgroundColor}) {
    return BoxDecoration(
      color: backgroundColor,
      shape: BoxShape.circle,
    );
  }
}
