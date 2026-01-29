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
