/// Formats calculation results for display on the calculator screen.
/// 
/// This class handles special values like Infinity, -Infinity, and NaN,
/// ensuring they are displayed correctly without truncation.
class ResultFormatter {
  /// Maximum number of digits to display before using scientific notation.
  static const int maxDisplayDigits = 12;
  
  /// Formats a result string for display.
  /// 
  /// Handles special cases:
  /// - 'Infinity' displays as 'Infinity' (no truncation)
  /// - '-Infinity' displays as '-Infinity' (no truncation)
  /// - 'NaN' displays as 'NaN' (no truncation)
  /// - 'Error' displays as 'Error' (no truncation)
  /// - Long numbers are truncated or converted to scientific notation
  String format(String result) {
    // Handle special values - these should never be truncated
    if (_isSpecialValue(result)) {
      return result;
    }
    
    // Handle error results
    if (result == 'Error') {
      return result;
    }
    
    // Handle numeric results
    return _formatNumericResult(result);
  }
  
  /// Checks if the result is a special value that should not be modified.
  bool _isSpecialValue(String result) {
    return result == 'Infinity' || 
           result == '-Infinity' || 
           result == 'NaN';
  }
  
  /// Formats a numeric result for display.
  String _formatNumericResult(String result) {
    // If the result fits within display limits, return as-is
    if (result.length <= maxDisplayDigits) {
      return result;
    }
    
    // Try to parse as a number for scientific notation
    final number = double.tryParse(result);
    if (number == null) {
      return result;
    }
    
    // Use scientific notation for very large or very small numbers
    if (number.abs() >= 1e10 || (number.abs() < 1e-6 && number != 0)) {
      return number.toStringAsExponential(6);
    }
    
    // Truncate decimal places if needed
    final parts = result.split('.');
    if (parts.length == 2) {
      final integerPart = parts[0];
      final remainingDigits = maxDisplayDigits - integerPart.length - 1;
      if (remainingDigits > 0) {
        final decimalPart = parts[1].substring(
          0, 
          remainingDigits < parts[1].length ? remainingDigits : parts[1].length
        );
        return '$integerPart.$decimalPart';
      }
    }
    
    return result.substring(0, maxDisplayDigits);
  }
  
  /// Checks if the result represents an error or special condition.
  bool isErrorOrSpecial(String result) {
    return result == 'Error' || 
           result == 'Infinity' || 
           result == '-Infinity' || 
           result == 'NaN';
  }
}
