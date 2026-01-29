import 'dart:math' as math;

import 'validate_expression_use_case.dart';
import '../entities/validation_result.dart';

/// Represents the result of an expression evaluation.
/// 
/// This sealed class provides type-safe handling of evaluation outcomes,
/// allowing consumers to exhaustively handle success, invalid input,
/// and division by zero cases.
sealed class EvaluationResult {
  const EvaluationResult();
  
  /// Returns true if the evaluation was successful.
  bool get isSuccess;
  
  /// Returns the error message if evaluation failed, null otherwise.
  String? get errorMessage;
}

/// Represents a successful evaluation result.
/// 
/// Contains the computed value as a double, which can be formatted
/// for display purposes.
class EvaluationSuccess extends EvaluationResult {
  /// The computed result value.
  final double value;
  
  const EvaluationSuccess(this.value);
  
  @override
  bool get isSuccess => true;
  
  @override
  String? get errorMessage => null;
  
  /// Returns the result formatted as a display string.
  /// 
  /// - Whole numbers are displayed without decimal places
  /// - Infinity and NaN are displayed as strings
  String get formattedValue {
    if (value.isInfinite) {
      return value.isNegative ? '-Infinity' : 'Infinity';
    }
    if (value.isNaN) {
      return 'NaN';
    }
    
    // Remove trailing zeros for whole numbers
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EvaluationSuccess && other.value == value;
  }
  
  @override
  int get hashCode => value.hashCode;
  
  @override
  String toString() => 'EvaluationSuccess($value)';
}

/// Represents an invalid input evaluation result.
/// 
/// This indicates that the expression could not be evaluated due to
/// invalid syntax, malformed expressions, or other input errors.
class EvaluationInvalidInput extends EvaluationResult {
  /// The error message describing why the input is invalid.
  final String message;
  
  const EvaluationInvalidInput(this.message);
  
  @override
  bool get isSuccess => false;
  
  @override
  String? get errorMessage => message;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EvaluationInvalidInput && other.message == message;
  }
  
  @override
  int get hashCode => message.hashCode;
  
  @override
  String toString() => 'EvaluationInvalidInput($message)';
}

/// Represents a division by zero evaluation result.
/// 
/// This is a special case that may be handled differently from other
/// errors, such as showing a specific toast message or warning.
class EvaluationDivisionByZero extends EvaluationResult {
  /// Whether the result is positive infinity (true) or negative infinity (false).
  /// Null indicates the result is NaN (0/0 case).
  final bool? isPositive;
  
  const EvaluationDivisionByZero({this.isPositive});
  
  @override
  bool get isSuccess => false;
  
  @override
  String? get errorMessage => 'Division by zero';
  
  /// Returns the display string for the division by zero result.
  String get displayValue {
    if (isPositive == null) {
      return 'NaN';
    }
    return isPositive! ? 'Infinity' : '-Infinity';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EvaluationDivisionByZero && other.isPositive == isPositive;
  }
  
  @override
  int get hashCode => isPositive.hashCode;
  
  @override
  String toString() => 'EvaluationDivisionByZero(isPositive: $isPositive)';
}

/// Use case for evaluating mathematical expressions.
/// 
/// This use case takes a mathematical expression string and evaluates it,
/// returning an [EvaluationResult] that represents either success with the
/// computed value, invalid input with an error message, or division by zero.
/// 
/// The use case integrates with [ValidateExpressionUseCase] to validate
/// expressions before evaluation, ensuring proper error messages are returned.
class EvaluateExpressionUseCase {
  final ValidateExpressionUseCase _validateExpressionUseCase;
  
  /// Creates an instance with the required validation use case.
  EvaluateExpressionUseCase({
    ValidateExpressionUseCase? validateExpressionUseCase,
  }) : _validateExpressionUseCase = validateExpressionUseCase ?? ValidateExpressionUseCase();
  
  /// Executes the expression evaluation and returns an [EvaluationResult].
  /// 
  /// Takes an [expression] string containing a mathematical expression
  /// (e.g., "10/0", "5+3*2", "(2+3)*4", "2^3") and returns the evaluated result.
  /// 
  /// Returns:
  /// - [EvaluationSuccess] with the computed value on successful evaluation
  /// - [EvaluationInvalidInput] with error message for invalid expressions
  /// - [EvaluationDivisionByZero] for division by zero cases
  EvaluationResult execute(String expression) {
    // Handle edge case: empty or whitespace-only expression
    if (expression.trim().isEmpty) {
      return const EvaluationInvalidInput('Expression cannot be empty');
    }
    
    // Validate the expression before evaluation
    final validationResult = _validateExpressionUseCase.execute(expression);
    if (validationResult is ValidationFailure) {
      return EvaluationInvalidInput(validationResult.message);
    }
    
    try {
      // Replace display operators with calculation operators
      String normalizedExpression = expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/');
      
      // Additional edge case handling
      final edgeCaseResult = _handleEdgeCases(normalizedExpression);
      if (edgeCaseResult != null) {
        return edgeCaseResult;
      }
      
      // Parse and evaluate the expression
      final result = _evaluate(normalizedExpression);
      
      // Check for division by zero result
      if (result.isInfinite || result.isNaN) {
        return _createDivisionByZeroResult(result);
      }
      
      return EvaluationSuccess(result);
    } on FormatException catch (e) {
      return EvaluationInvalidInput('Invalid expression format: ${e.message}');
    } on RangeError catch (_) {
      return const EvaluationInvalidInput('Expression parsing error');
    } on ArgumentError catch (e) {
      return EvaluationInvalidInput('Invalid argument: ${e.message}');
    } catch (e) {
      // Catch any other unexpected errors
      return EvaluationInvalidInput('Evaluation error: ${e.toString()}');
    }
  }
  
  /// Legacy execute method that returns a string for backward compatibility.
  /// 
  /// @deprecated Use [execute] instead which returns [EvaluationResult].
  String executeString(String expression) {
    final result = execute(expression);
    
    return switch (result) {
      EvaluationSuccess() => result.formattedValue,
      EvaluationInvalidInput() => 'Error',
      EvaluationDivisionByZero() => result.displayValue,
    };
  }
  
  /// Handles edge cases that might slip past validation.
  EvaluationResult? _handleEdgeCases(String expression) {
    final trimmed = expression.replaceAll(' ', '');
    
    // Check for expression with only operators
    if (RegExp(r'^[+\-*/^]+$').hasMatch(trimmed)) {
      return const EvaluationInvalidInput('Expression contains only operators');
    }
    
    // Check for malformed power expressions like "^2" or "2^"
    if (trimmed.startsWith('^')) {
      return const EvaluationInvalidInput('Expression cannot start with power operator');
    }
    if (trimmed.endsWith('^')) {
      return const EvaluationInvalidInput('Expression cannot end with power operator');
    }
    
    // Check for consecutive power operators
    if (trimmed.contains('^^')) {
      return const EvaluationInvalidInput('Invalid consecutive power operators');
    }
    
    // Check for invalid decimal points
    if (RegExp(r'\d*\.\d*\.\d*').hasMatch(trimmed)) {
      return const EvaluationInvalidInput('Invalid number format: multiple decimal points');
    }
    
    // Check for adjacent numbers without operator (e.g., "12 34")
    // This handles cases like "5(3)" which should be "5*(3)"
    if (RegExp(r'\d\(').hasMatch(trimmed)) {
      return const EvaluationInvalidInput('Missing operator before parenthesis');
    }
    if (RegExp(r'\)\d').hasMatch(trimmed)) {
      return const EvaluationInvalidInput('Missing operator after parenthesis');
    }
    
    return null;
  }
  
  /// Creates the appropriate division by zero result based on the value.
  EvaluationDivisionByZero _createDivisionByZeroResult(double result) {
    if (result.isNaN) {
      return const EvaluationDivisionByZero(isPositive: null);
    }
    return EvaluationDivisionByZero(isPositive: !result.isNegative);
  }
  
  /// Checks if parentheses in the expression are balanced.
  bool _areParenthesesBalanced(String expression) {
    int count = 0;
    for (var char in expression.split('')) {
      if (char == '(') {
        count++;
      } else if (char == ')') {
        count--;
        if (count < 0) {
          return false; // More closing than opening
        }
      }
    }
    return count == 0;
  }
  
  /// Evaluates a mathematical expression string.
  /// 
  /// Supports: +, -, *, /, ^ operators with proper precedence and parentheses.
  double _evaluate(String expression) {
    expression = expression.replaceAll(' ', '');
    
    // Handle empty expression
    if (expression.isEmpty) {
      return 0;
    }
    
    // Validate parentheses balance (extra safety check)
    if (!_areParenthesesBalanced(expression)) {
      throw const FormatException('Unbalanced parentheses');
    }
    
    // Handle parentheses recursively
    expression = _evaluateParentheses(expression);
    
    // Tokenize the expression
    final tokens = _tokenize(expression);
    
    // Evaluate using shunting-yard algorithm principles
    return _evaluateTokens(tokens);
  }
  
  /// Recursively evaluates parenthesized sub-expressions.
  String _evaluateParentheses(String expression) {
    // Keep evaluating until no parentheses remain
    while (expression.contains('(')) {
      // Find the innermost parentheses
      int openIndex = -1;
      int closeIndex = -1;
      
      for (int i = 0; i < expression.length; i++) {
        if (expression[i] == '(') {
          openIndex = i;
        } else if (expression[i] == ')') {
          closeIndex = i;
          break;
        }
      }
      
      if (openIndex == -1 || closeIndex == -1 || closeIndex <= openIndex) {
        throw const FormatException('Invalid parentheses');
      }
      
      // Extract the sub-expression inside parentheses
      String subExpression = expression.substring(openIndex + 1, closeIndex);
      
      // Handle empty parentheses
      if (subExpression.isEmpty) {
        throw const FormatException('Empty parentheses');
      }
      
      // Evaluate the sub-expression
      final tokens = _tokenize(subExpression);
      final result = _evaluateTokens(tokens);
      
      // Replace the parenthesized expression with its result
      String resultStr = result.toString();
      
      // Handle negative results by wrapping in special marker to avoid parsing issues
      // e.g., 5*(-3) should work correctly
      if (result < 0) {
        // If there's an operator before the opening parenthesis, we need to handle the negative
        if (openIndex > 0 && _isOperator(expression[openIndex - 1])) {
          // The negative will be handled by the tokenizer
          resultStr = result.toString();
        }
      }
      
      expression = expression.substring(0, openIndex) + 
                   resultStr + 
                   expression.substring(closeIndex + 1);
    }
    
    return expression;
  }
  
  /// Tokenizes the expression into numbers and operators.
  List<String> _tokenize(String expression) {
    final tokens = <String>[];
    var currentNumber = '';
    
    for (var i = 0; i < expression.length; i++) {
      final char = expression[i];
      
      if (_isDigitOrDecimal(char)) {
        currentNumber += char;
      } else if (_isOperator(char)) {
        // Handle negative numbers at start or after operator
        if (char == '-' && (currentNumber.isEmpty && (tokens.isEmpty || _isOperator(tokens.last)))) {
          currentNumber += char;
        } else {
          if (currentNumber.isNotEmpty) {
            tokens.add(currentNumber);
            currentNumber = '';
          }
          tokens.add(char);
        }
      }
    }
    
    if (currentNumber.isNotEmpty) {
      tokens.add(currentNumber);
    }
    
    return tokens;
  }
  
  bool _isDigitOrDecimal(String char) {
    return RegExp(r'[0-9.]').hasMatch(char);
  }
  
  bool _isOperator(String char) {
    return ['+', '-', '*', '/', '^'].contains(char);
  }
  
  /// Evaluates tokens with proper operator precedence.
  /// 
  /// Precedence (highest to lowest):
  /// 1. ^ (power/exponentiation)
  /// 2. * and / (multiplication and division)
  /// 3. + and - (addition and subtraction)
  double _evaluateTokens(List<String> tokens) {
    if (tokens.isEmpty) {
      return 0;
    }
    
    // First pass: handle ^ (power) - right-to-left associativity
    tokens = _evaluatePowerOperators(tokens);
    
    // Second pass: handle * and /
    final addSubTokens = <String>[];
    var i = 0;
    
    while (i < tokens.length) {
      if (i + 2 < tokens.length && (tokens[i + 1] == '*' || tokens[i + 1] == '/')) {
        var result = double.parse(tokens[i]);
        while (i + 2 < tokens.length && (tokens[i + 1] == '*' || tokens[i + 1] == '/')) {
          final operator = tokens[i + 1];
          final operand = double.parse(tokens[i + 2]);
          if (operator == '*') {
            result *= operand;
          } else {
            result /= operand; // This handles division by zero automatically (returns Infinity or NaN)
          }
          i += 2;
        }
        addSubTokens.add(result.toString());
      } else {
        addSubTokens.add(tokens[i]);
      }
      i++;
    }
    
    // Third pass: handle + and -
    var result = double.parse(addSubTokens[0]);
    i = 1;
    while (i < addSubTokens.length) {
      final operator = addSubTokens[i];
      final operand = double.parse(addSubTokens[i + 1]);
      if (operator == '+') {
        result += operand;
      } else if (operator == '-') {
        result -= operand;
      }
      i += 2;
    }
    
    return result;
  }
  
  /// Evaluates power operators in the token list.
  /// 
  /// Power operator is right-associative, meaning 2^3^2 = 2^(3^2) = 2^9 = 512
  List<String> _evaluatePowerOperators(List<String> tokens) {
    // Process from right to left for right-associativity
    final result = List<String>.from(tokens);
    
    // Find and evaluate power operations from right to left
    for (var i = result.length - 2; i >= 1; i--) {
      if (result[i] == '^') {
        final base = double.parse(result[i - 1]);
        final exponent = double.parse(result[i + 1]);
        final powerResult = math.pow(base, exponent).toDouble();
        
        // Replace the three tokens (base, ^, exponent) with the result
        result.removeAt(i + 1);
        result.removeAt(i);
        result[i - 1] = powerResult.toString();
        
        // Continue from the current position since we modified the list
        i = result.length - 1;
      }
    }
    
    return result;
  }
}
