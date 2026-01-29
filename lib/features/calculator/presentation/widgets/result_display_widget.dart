import 'package:flutter/material.dart';

import '../theme/calculator_dimensions.dart';

/// Widget that displays a calculation result with RTL-aware alignment.
///
/// This widget uses directional alignment values to ensure proper layout
/// in both LTR and RTL locales:
/// - Uses [AlignmentDirectional.centerEnd] instead of [Alignment.centerRight]
/// - Uses [TextAlign.end] instead of [TextAlign.right]
///
/// In LTR locales, the result aligns to the right.
/// In RTL locales, the result aligns to the left.
///
/// The widget also supports locale-aware number formatting when enabled.
class ResultDisplayWidget extends StatelessWidget {
  /// Creates a result display widget.
  ///
  /// The [result] parameter contains the calculation result to display.
  /// If [result] is null or empty, the widget displays nothing.
  const ResultDisplayWidget({
    super.key,
    required this.result,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.prefix = '= ',
  });

  /// The result string to display.
  final String? result;

  /// Optional custom text color. Defaults to grey.shade400.
  final Color? textColor;

  /// Optional custom font size. Defaults to [CalculatorDimensions.resultFontSize].
  final double? fontSize;

  /// Optional custom font weight. Defaults to FontWeight.w400.
  final FontWeight? fontWeight;

  /// Prefix to show before the result. Defaults to '= '.
  final String prefix;

  @override
  Widget build(BuildContext context) {
    // Don't render anything if there's no result
    if (result == null || result!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      // Use AlignmentDirectional.centerEnd for RTL support instead of Alignment.centerRight
      alignment: AlignmentDirectional.centerEnd,
      child: Text(
        '$prefix$result',
        style: TextStyle(
          fontSize: fontSize ?? CalculatorDimensions.resultFontSize,
          fontWeight: fontWeight ?? FontWeight.w400,
          color: textColor ?? Colors.grey.shade400,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        // Use TextAlign.end for RTL support instead of TextAlign.right
        textAlign: TextAlign.end,
      ),
    );
  }

  /// Formats the result string for locale-aware display.
  ///
  /// This method can be extended to support locale-specific number formatting
  /// such as decimal separators and digit grouping.
  ///
  /// Example usage:
  /// ```dart
  /// final formattedResult = ResultDisplayWidget.formatResultForLocale(
  ///   result: '1234.56',
  ///   locale: Localizations.localeOf(context),
  /// );
  /// ```
  static String formatResultForLocale({
    required String result,
    required Locale locale,
  }) {
    // Handle special values that should not be formatted
    if (_isSpecialValue(result)) {
      return result;
    }

    // Try to parse as number for locale-aware formatting
    final number = double.tryParse(result);
    if (number == null) {
      return result;
    }

    // For now, return the result as-is
    // Future enhancement: Use intl package for locale-specific formatting
    // Example: NumberFormat.decimalPattern(locale.toString()).format(number)
    return result;
  }

  /// Checks if the result is a special value that should not be formatted.
  static bool _isSpecialValue(String result) {
    return result == 'Infinity' ||
        result == '-Infinity' ||
        result == 'NaN' ||
        result == 'Error';
  }
}
