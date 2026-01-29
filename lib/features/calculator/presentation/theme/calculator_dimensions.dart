import 'package:flutter/material.dart';

/// Dimension constants for the calculator UI.
///
/// This class defines all the dimensions, sizes, and spacing values
/// used throughout the calculator, ensuring consistency and easy
/// maintenance of the UI layout.
class CalculatorDimensions {
  CalculatorDimensions._();

  // ==================== Screen Layout Dimensions ====================

  /// Flex value for the display area (expression + result).
  ///
  /// This represents approximately 30% of the available screen height.
  static const int displayAreaFlex = 3;

  /// Flex value for the button grid area.
  ///
  /// This represents approximately 60% of the available screen height.
  static const int buttonGridFlex = 6;

  /// Horizontal padding for the entire calculator screen.
  ///
  /// Applied to the left and right edges of the screen content.
  static const double screenHorizontalPadding = 0.0;

  /// Vertical padding for the calculator screen.
  ///
  /// Applied to top and bottom of the screen content.
  static const double screenVerticalPadding = 0.0;

  // ==================== Display Area Dimensions ====================

  /// Padding around the expression display area.
  ///
  /// Provides spacing between the display text and screen edges.
  static const double displayPadding = 24.0;

  /// Font size for the main expression text.
  static const double expressionFontSize = 48.0;

  /// Font size for the result preview text.
  static const double resultFontSize = 32.0;

  /// Spacing between expression text and result text.
  static const double expressionResultSpacing = 8.0;

  // ==================== Backspace Button Dimensions ====================

  /// Size (width and height) of the backspace button.
  ///
  /// The backspace button is circular, so width and height are equal.
  static const double backspaceButtonSize = 48.0;

  /// Padding around the backspace button row.
  ///
  /// Controls the horizontal padding to align with the button grid.
  static const double backspaceRowHorizontalPadding = 16.0;

  /// Vertical spacing between the backspace button and the button grid.
  ///
  /// Provides visual separation between the backspace button row
  /// and the main calculator button grid.
  static const double backspaceButtonBottomSpacing = 8.0;

  /// Top padding for the backspace button row.
  ///
  /// Provides visual separation between the display area
  /// and the backspace button row.
  static const double backspaceButtonTopSpacing = 4.0;

  // ==================== Circular Button Dimensions ====================
  //
  // These constants define the circular button design used throughout
  // the calculator. Values are mapped 1:1 from Android dp (density-independent
  // pixels) to Flutter logical pixels, as both units scale identically
  // across different screen densities.
  //
  // Android dp to Flutter logical pixel mapping:
  // - 70dp in Android XML → 70.0 logical pixels in Flutter
  // - 5dp in Android XML → 5.0 logical pixels in Flutter
  // - 24sp in Android XML → 24.0 logical pixels in Flutter
  // - 1000dp border radius → 1000.0 logical pixels (creates circular shape)

  /// Height of circular calculator buttons.
  ///
  /// Maps to Android: 70dp button height.
  /// In Flutter, this is 70.0 logical pixels.
  static const double circularButtonHeight = 70.0;

  /// Margin around circular calculator buttons.
  ///
  /// Maps to Android: 5dp margin on each side.
  /// In Flutter, this is 5.0 logical pixels.
  /// This provides consistent spacing between buttons when each button
  /// applies this margin, resulting in 10dp visual spacing between adjacent buttons.
  static const double circularButtonMargin = 5.0;

  /// Text size for circular calculator buttons.
  ///
  /// Maps to Android: 24sp text size.
  /// In Flutter, this is 24.0 logical pixels (sp and dp are equivalent
  /// for standard text scaling).
  static const double circularButtonTextSize = 24.0;

  /// Border radius for circular calculator buttons.
  ///
  /// A large value (1000.0) ensures the button appears fully circular
  /// when the width and height are constrained to similar values.
  /// This creates the pill/circular shape regardless of actual dimensions.
  static const double circularButtonRadius = 1000.0;

  // Semantic aliases for button dimensions (for clarity in usage)

  /// Alias for [circularButtonHeight] - the standard button height.
  static const double buttonHeight = circularButtonHeight;

  /// Alias for [circularButtonMargin] - the standard button margin.
  static const double buttonMargin = circularButtonMargin;

  /// Alias for [circularButtonTextSize] - the standard button text size.
  static const double buttonTextSize = circularButtonTextSize;

  /// Alias for [circularButtonRadius] - the standard button border radius.
  static const double buttonBorderRadius = circularButtonRadius;

  // ==================== Button Grid Dimensions ====================

  /// Horizontal spacing between button cells in the grid.
  ///
  /// Set to 0.0 because individual buttons already have [circularButtonMargin]
  /// applied internally. When two buttons are adjacent, their combined margins
  /// (5dp + 5dp = 10dp) create the visual spacing between them.
  /// This provides consistent 5dp margins around each button as per the
  /// circular design specification.
  static const double buttonSpacing = 0.0;

  /// Vertical spacing between rows in the button grid.
  ///
  /// Set to 0.0 because individual buttons already have [circularButtonMargin]
  /// applied internally. When two rows are adjacent, the combined margins
  /// (5dp + 5dp = 10dp) create the visual spacing between them.
  /// This ensures consistent 5dp margins around each button.
  static const double rowSpacing = 0.0;

  /// Padding around the entire button grid.
  ///
  /// Uses the same value as [circularButtonMargin] to ensure the grid edge
  /// spacing matches the button's internal margins. Combined with the button's
  /// 5dp internal margin, this creates consistent visual spacing on all edges.
  static const double gridPadding = circularButtonMargin;

  // ==================== Toast Dimensions ====================

  /// Border radius for toast notifications.
  ///
  /// Provides rounded corners that match the calculator's design language.
  static const double toastBorderRadius = 8.0;

  /// Font size for toast message text.
  static const double toastFontSize = 14.0;

  /// Size of the icon displayed in toast notifications.
  static const double toastIconSize = 20.0;

  /// Spacing between the icon and text in toast notifications.
  static const double toastIconSpacing = 12.0;

  /// Margin around the toast notification.
  ///
  /// Controls the distance from the edges of the screen.
  static const double toastMargin = 16.0;

  /// Default duration for toast notifications.
  ///
  /// The toast will automatically dismiss after this duration.
  static const Duration toastDuration = Duration(seconds: 3);

  /// Short duration for toast notifications.
  ///
  /// Matches Android's Toast.LENGTH_SHORT behavior (approximately 2 seconds).
  /// Use this for brief notifications like 'Invalid Input' that don't
  /// require extended reading time.
  static const Duration toastDurationShort = Duration(seconds: 2);

  /// Long duration for toast notifications.
  ///
  /// Matches Android's Toast.LENGTH_LONG behavior (approximately 3.5 seconds).
  /// Use this for messages that require more reading time.
  static const Duration toastDurationLong = Duration(milliseconds: 3500);

  // ==================== RTL-Aware Alignment Constants ====================
  //
  // These constants provide directional text alignment that automatically
  // adapts to the current text direction (LTR or RTL). Use these instead
  // of absolute alignment values (left/right) to ensure proper UI layout
  // in both directions.

  /// RTL-aware alignment for the end of text.
  ///
  /// Use this instead of [TextAlign.right] for text that should align to:
  /// - Right edge in LTR languages (English, etc.)
  /// - Left edge in RTL languages (Arabic, Hebrew, etc.)
  ///
  /// This is the preferred alignment for calculator display text (expression
  /// and result) as it respects the user's language direction.
  static const TextAlign displayTextAlign = TextAlign.end;

  /// RTL-aware alignment for the start of text.
  ///
  /// Use this instead of [TextAlign.left] for text that should align to:
  /// - Left edge in LTR languages (English, etc.)
  /// - Right edge in RTL languages (Arabic, Hebrew, etc.)
  static const TextAlign displayTextAlignStart = TextAlign.start;

  /// Center alignment for text.
  ///
  /// This alignment is direction-independent and centers text horizontally.
  /// Use this for button labels and centered content.
  static const TextAlign buttonTextAlign = TextAlign.center;
}
