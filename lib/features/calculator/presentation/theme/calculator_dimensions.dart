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

  // ==================== Button Grid Dimensions ====================

  /// Horizontal spacing between buttons in the grid.
  static const double buttonSpacing = 12.0;

  /// Vertical spacing between rows in the button grid.
  static const double rowSpacing = 12.0;

  /// Padding around the entire button grid.
  static const double gridPadding = 16.0;

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
}
