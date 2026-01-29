import 'package:flutter/material.dart';

import '../theme/calculator_dimensions.dart';

/// A reusable calculator button widget with circular styling.
///
/// This widget enforces the circular design specifications:
/// - 70dp height for consistent button sizing
/// - 5dp margins around each button for proper spacing
/// - Borderless appearance for iOS-inspired styling
/// - 24sp text size for readable button labels
///
/// The button uses a [Material] widget with [InkWell] for touch feedback
/// (ripple effect) while maintaining the borderless appearance.
class CalculatorButton extends StatelessWidget {
  /// The text label displayed on the button.
  final String label;

  /// Callback invoked when the button is pressed.
  final VoidCallback onPressed;

  /// Background color of the button.
  final Color backgroundColor;

  /// Text color of the button label.
  final Color textColor;

  /// Optional custom decoration for the button.
  ///
  /// If provided, this decoration is used instead of the default
  /// circular decoration with [backgroundColor].
  final BoxDecoration? decoration;

  /// Optional custom text style for the button label.
  ///
  /// If provided, this overrides the default text style while
  /// still applying [textColor].
  final TextStyle? textStyle;

  /// Creates a calculator button with circular styling.
  ///
  /// The [label], [onPressed], [backgroundColor], and [textColor]
  /// parameters are required.
  const CalculatorButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    this.decoration,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Apply consistent margin spacing (5dp) around the button
    return Padding(
      padding: const EdgeInsets.all(CalculatorDimensions.circularButtonMargin),
      child: SizedBox(
        // Enforce consistent button height (70dp)
        height: CalculatorDimensions.circularButtonHeight,
        child: Material(
          // Use transparent material type for borderless ripple effect
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            // Apply circular border radius for ripple clipping
            borderRadius: BorderRadius.circular(
              CalculatorDimensions.circularButtonRadius,
            ),
            child: Container(
              // Apply circular shape using high border radius (1000dp)
              // with borderless styling
              decoration: decoration ?? _defaultDecoration,
              child: Center(
                child: Text(
                  label,
                  style: _buildTextStyle(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the default circular decoration with borderless styling.
  BoxDecoration get _defaultDecoration => BoxDecoration(
        color: backgroundColor,
        // High border radius (1000dp) creates circular/pill shape
        borderRadius: BorderRadius.circular(
          CalculatorDimensions.circularButtonRadius,
        ),
        // No border for borderless appearance
      );

  /// Builds the text style for the button label.
  ///
  /// Uses 24sp font size from [CalculatorDimensions] for consistent
  /// button labels across all button types.
  TextStyle _buildTextStyle() {
    final baseStyle = TextStyle(
      color: textColor,
      // Enforce 24sp text size for consistent button labels
      fontSize: CalculatorDimensions.circularButtonTextSize,
      fontWeight: FontWeight.w500,
    );

    // Merge with custom text style if provided
    if (textStyle != null) {
      return baseStyle.merge(textStyle);
    }

    return baseStyle;
  }
}
