/// Dimension constants for the calculator UI.
///
/// This class defines all the dimensions, sizes, and spacing values
/// used throughout the calculator, ensuring consistency and easy
/// maintenance of the UI layout.
class CalculatorDimensions {
  CalculatorDimensions._();

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
