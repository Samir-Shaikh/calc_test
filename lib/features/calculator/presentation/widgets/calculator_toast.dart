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
///
/// For displaying 'Invalid Input' errors specifically, use the convenience
/// method:
/// ```dart
/// CalculatorToast.showInvalidInput(context);
/// ```
class CalculatorToast {
  CalculatorToast._();

  /// The standard 'Invalid Input' message displayed to users.
  ///
  /// This message is shown when an expression cannot be evaluated
  /// due to invalid syntax or mathematical errors.
  static const String invalidInputMessage = 'Invalid Input';

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
  /// - [onDismissed]: Optional callback invoked when the toast is dismissed.
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.error,
    Duration? duration,
    VoidCallback? onDismissed,
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
      backgroundColor: _getBackgroundColor(type),
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
      ..showSnackBar(snackBar).closed.then((_) {
        onDismissed?.call();
      });
  }

  /// Shows the standardized 'Invalid Input' toast notification.
  ///
  /// This is a convenience method that displays the 'Invalid Input' message
  /// with appropriate error styling and a short duration matching Android's
  /// Toast.LENGTH_SHORT (approximately 2 seconds).
  ///
  /// Parameters:
  /// - [context]: The BuildContext used to show the SnackBar.
  /// - [onDismissed]: Optional callback invoked when the toast is dismissed.
  ///
  /// Example usage:
  /// ```dart
  /// CalculatorToast.showInvalidInput(context);
  /// ```
  ///
  /// Or with a callback:
  /// ```dart
  /// CalculatorToast.showInvalidInput(
  ///   context,
  ///   onDismissed: () {
  ///     // Handle toast dismissal
  ///   },
  /// );
  /// ```
  static void showInvalidInput(
    BuildContext context, {
    VoidCallback? onDismissed,
  }) {
    show(
      context,
      message: invalidInputMessage,
      type: ToastType.error,
      duration: CalculatorDimensions.toastDurationShort,
      onDismissed: onDismissed,
    );
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

  /// Returns the appropriate background color for the given [type].
  static Color _getBackgroundColor(ToastType type) {
    switch (type) {
      case ToastType.error:
        return CalculatorColors.toastErrorBackgroundColor;
      case ToastType.success:
      case ToastType.info:
        return CalculatorColors.toastBackgroundColor;
    }
  }
}
