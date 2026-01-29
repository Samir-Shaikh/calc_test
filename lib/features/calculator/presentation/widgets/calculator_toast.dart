import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Enum representing different types of toast notifications.
///
/// Each type has its own icon and color scheme to provide visual
/// feedback to the user about the nature of the message.
enum ToastType {
  /// Error toast for displaying error messages like 'Invalid Input'.
  error,

  /// Success toast for displaying success messages.
  success,

  /// Info toast for displaying informational messages.
  info,
}

/// A reusable toast notification widget for the calculator.
///
/// This widget provides a static [show] method to display snackbar-style
/// notifications that match the calculator's dark theme. It supports
/// different message types (error, success, info) with appropriate
/// icons and colors.
///
/// Example usage:
/// ```dart
/// CalculatorToast.show(
///   context,
///   message: 'Invalid Input',
///   type: ToastType.error,
/// );
/// ```
class CalculatorToast {
  CalculatorToast._();

  /// Shows a toast notification with the specified [message] and [type].
  ///
  /// The toast will automatically dismiss after [duration] (defaults to
  /// [CalculatorDimensions.toastDuration]).
  ///
  /// Parameters:
  /// - [context]: The BuildContext used to show the SnackBar.
  /// - [message]: The text message to display in the toast.
  /// - [type]: The type of toast (error, success, info). Defaults to error.
  /// - [duration]: How long the toast should be visible. Defaults to 3 seconds.
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.error,
    Duration? duration,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            _getIcon(type),
            color: _getIconColor(type),
            size: CalculatorDimensions.toastIconSize,
          ),
          const SizedBox(width: CalculatorDimensions.toastIconSpacing),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: CalculatorColors.toastTextColor,
                fontSize: CalculatorDimensions.toastFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: CalculatorColors.toastBackgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          CalculatorDimensions.toastBorderRadius,
        ),
      ),
      margin: const EdgeInsets.all(CalculatorDimensions.toastMargin),
      duration: duration ?? CalculatorDimensions.toastDuration,
      dismissDirection: DismissDirection.horizontal,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /// Returns the appropriate icon for the given [type].
  static IconData _getIcon(ToastType type) {
    switch (type) {
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.info:
        return Icons.info_outline;
    }
  }

  /// Returns the appropriate icon color for the given [type].
  static Color _getIconColor(ToastType type) {
    switch (type) {
      case ToastType.error:
        return CalculatorColors.toastErrorColor;
      case ToastType.success:
        return CalculatorColors.toastSuccessColor;
      case ToastType.info:
        return CalculatorColors.toastInfoColor;
    }
  }
}
