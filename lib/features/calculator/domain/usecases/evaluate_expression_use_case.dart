import 'dart:math' as math;

import 'validate_expression_use_case.dart';
import '../entities/validation_result.dart';
import '../entities/evaluation_result.dart';

// Re-export evaluation result types for backward compatibility
// This allows existing code that imports from this file to continue working
export '../entities/evaluation_result.dart';

/// Use case for evaluating mathematical expressions.
/// 
/// This use case takes a mathematical expression string and evaluates it,
/// returning an [EvaluationResult] that represents either success with the
/// computed value, invalid input with an error message, or division by zero.
/// 
/// ## Order of Operations (PEMDAS/BODMAS)
/// 
/// This evaluator respects the standard mathematical order of operations:
/// 
/// 1. **P**arentheses / **B**rackets - Evaluated first, innermost to outermost
/// 2. **E**xponents / **O**rders (^) - Evaluated second, right-to-left associativity
/// 3. **M**ultiplication (*) and **D**ivision (/) - Left-to-right evaluation
/// 4. **A**ddition (+) and **S**ubtraction (-) - Left-to-right evaluation
/// 
/// ### Examples:
/// - `'2+3*4'` = 14.0 (multiplication before addition: 2 + 12 = 14)
/// - `'10-4/2'` = 8.0 (division before subtraction: 10 - 2 = 8)
/// - `'(2+3)*4'` = 20.0 (parentheses first: 5 * 4 = 20)
/// - `'2^3+1'` = 9.0 (exponent before addition: 8 + 1 = 9)
/// - `'2^3^2'` = 512.0 (right-to-left: 2^(3^2) = 2^9 = 512)
/// - `'2+3*4^2'` = 50.0 (exponent, then multiply, then add: 2 + 3*16 = 2 + 48 = 50)
/// 
/// ### Power Operator (^)
/// 
/// The `^` operator is converted to [math.pow] for evaluation. Power operations
/// are right-associative, meaning `2^3^2` is evaluated as `2^(3^2)` = 512,
/// not `(2^3)^2` = 64.
/// 
/// The use case integrates with [ValidateExpressionUseCase] to validate
/// expressions before evaluation, ensuring proper error messages are returned.
/// 
/// ## Error Handling Strategy
/// 
/// 1. Pre-evaluation validation catches syntax errors early
/// 2. Try-catch blocks wrap all evaluation logic to catch runtime exceptions
/// 3. Exceptions are mapped to user-friendly messages via [EvaluationErrorMapper]
/// 4. Original error details are preserved for debugging/logging
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
  /// The evaluation respects PEMDAS/BODMAS order of operations:
  /// - Parentheses are evaluated first (innermost to outermost)
  /// - Exponents (^) are evaluated next (right-to-left associativity)
  /// - Multiplication (*) and Division (/) are evaluated left-to-right
  /// - Addition (+) and Subtraction (-) are evaluated left-to-right
  /// 
  /// Returns:
  /// - [EvaluationSuccess] with the computed value on successful evaluation
  /// - [EvaluationInvalidInput] with error message for invalid expressions
  /// - [EvaluationDivisionByZero] for division by zero cases
  EvaluationResult execute(String expression) {
    // Handle edge case: empty or whitespace-only expression
    if (expression.trim().isEmpty) {
      return const EvaluationInvalidInput(
        'Invalid Input',
        type: EvaluationErrorType.validationFailure,
        originalError: 'Expression cannot be empty',
      );
    }
    
    // Pre-evaluation validation: validate the expression before attempting evaluation
    final validationResult = _validateExpressionUseCase.execute(expression);
    if (validationResult is ValidationFailure) {
      return EvaluationInvalidInput(
        'Invalid Input',
        type: EvaluationErrorType.validationFailure,
        originalError: validationResult.message,
      );
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
      
      // Parse and evaluate the expression with try-catch for math_expressions errors
      final result = _evaluateWithErrorHandling(normalizedExpression);
      
      // Check for division by zero result
      if (result.isInfinite || result.isNaN) {
        return _createDivisionByZeroResult(result);
      }
      
      return EvaluationSuccess(result);
    } on FormatException catch (e) {
      // Handle format exceptions from parsing
      return EvaluationErrorMapper.mapException(e);
    } on RangeError catch (e) {
      // Handle range errors from token access
      return EvaluationErrorMapper.mapException(e);
    } on ArgumentError catch (e) {
      // Handle argument errors from invalid operations
      return EvaluationErrorMapper.mapException(e);
    } on StateError catch (e) {
      // Handle state errors from math_expressions library
      return EvaluationErrorMapper.mapException(e);
    } catch (e) {
      // Catch any other unexpected errors and map to user-friendly message
      return EvaluationErrorMapper.mapException(e);
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
  
  /// Evaluates the expression with comprehensive error handling.
  /// 
  /// Wraps the evaluation logic in try-catch to handle any exceptions
  /// from the parsing and evaluation process.
  double _evaluateWithErrorHandling(String expression) {
    try {
      return _evaluate(expression);
    } on FormatException {
      rethrow;
    } on RangeError {
      rethrow;
    } on ArgumentError {
      rethrow;
    } on StateError {
      rethrow;
    } catch (e) {
      // Convert unknown exceptions to FormatException for consistent handling
      throw FormatException('Evaluation failed: ${e.toString()}');
    }
  }
  
  /// Handles edge cases that might slip past validation.
  EvaluationResult? _handleEdgeCases(String expression) {
    final trimmed = expression.replaceAll(' ', '');
    
    // Check for expression with only operators
    if (RegExp(r'^[+\-*/^]+$').hasMatch(trimmed)) {
      return const EvaluationInvalidInput(
        'Invalid Input',
        type: EvaluationErrorType.invalidFormat,
        originalError: 'Expression contains only operators',
      );
    }
    
    // Check for malformed power expressions like "^2" or "2^"
    if (trimmed.startsWith('^')) {
      return const EvaluationInvalidInput(
        'Invalid Input',
        type: EvaluationErrorType.invalidFormat,
        originalError: 'Expression cannot start with power operator',
      );
    }
    if (trimmed.endsWith('^')) {
      return const EvaluationInvalidInput(
        'Invalid Input',
        type: EvaluationErrorType.invalidFormat,
        originalError: 'Expression cannot end with power operator',
      );
    }
    
    // Check for consecutive power operators
    if (trimmed.contains('^^')) {
      return const EvaluationInvalidInput(
        'Invalid Input',
        type: EvaluationErrorType.invalidFormat,
        originalError: 'Invalid consecutive power operators',
      );
    }
    
    // Check for invalid decimal points
    if (RegExp(r'\d*\.\d*\.\d*').hasMatch(trimmed)) {
      return const EvaluationInvalidInput(
        'Invalid Input',
        type: EvaluationErrorType.invalidFormat,
        originalError: 'Invalid number format: multiple decimal points',
      );
    }
    
    // Check for adjacent numbers without operator (e.g., "12 34")
    // This handles cases like "5(3)" which should be "5*(3)"
    if (RegExp(r'\d\(').hasMatch(trimmed)) {
      return const EvaluationInvalidInput(
        'Invalid Input',
        type: EvaluationErrorType.invalidFormat,
        originalError: 'Missing operator before parenthesis',
      );
    }
    if (RegExp(r'\)\d').hasMatch(trimmed)) {
      return const EvaluationInvalidInput(
        'Invalid Input',
        type: EvaluationErrorType.invalidFormat,
        originalError: 'Missing operator after parenthesis',
      );
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
  /// Supports: +, -, *, /, ^ operators with proper PEMDAS/BODMAS precedence
  /// and parentheses for grouping.
  /// 
  /// ## Operator Precedence (highest to lowest):
  /// 
  /// 1. Parentheses `()` - Evaluated first, innermost to outermost
  /// 2. Exponentiation `^` - Right-to-left associativity (e.g., 2^3^2 = 2^9 = 512)
  /// 3. Multiplication `*` and Division `/` - Left-to-right
  /// 4. Addition `+` and Subtraction `-` - Left-to-right
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
    
    // Step 1: Handle parentheses recursively (highest precedence)
    // Evaluates innermost parentheses first
    expression = _evaluateParentheses(expression);
    
    // Tokenize the expression
    final tokens = _tokenize(expression);
    
    // Evaluate using multi-pass approach respecting operator precedence
    return _evaluateTokens(tokens);
  }
  
  /// Recursively evaluates parenthesized sub-expressions.
  /// 
  /// Finds the innermost parentheses first and evaluates them, replacing
  /// the parenthesized expression with its result. This continues until
  /// no parentheses remain, ensuring parentheses have the highest precedence.
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
  
  /// Evaluates tokens with proper PEMDAS/BODMAS operator precedence.
  /// 
  /// Uses a multi-pass approach to respect operator precedence:
  /// 
  /// **Pass 1**: Evaluate `^` (exponentiation) - right-to-left associativity
  /// - Example: `2^3^2` becomes `2^9` becomes `512`
  /// - Uses [math.pow] for the actual computation
  /// 
  /// **Pass 2**: Evaluate `*` and `/` (multiplication and division) - left-to-right
  /// - Example: `12/3*2` becomes `4*2` becomes `8`
  /// 
  /// **Pass 3**: Evaluate `+` and `-` (addition and subtraction) - left-to-right
  /// - Example: `10-5+2` becomes `5+2` becomes `7`
  /// 
  /// This approach ensures mathematical correctness for expressions like:
  /// - `2+3*4^2` = 2 + 3*16 = 2 + 48 = 50
  /// - `8/2^2` = 8/4 = 2
  double _evaluateTokens(List<String> tokens) {
    if (tokens.isEmpty) {
      return 0;
    }
    
    // First pass: handle ^ (power) - right-to-left associativity
    // This is the highest precedence after parentheses
    tokens = _evaluatePowerOperators(tokens);
    
    // Second pass: handle * and / (left-to-right)
    // These have higher precedence than + and -
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
    
    // Third pass: handle + and - (left-to-right)
    // These have the lowest precedence
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
  /// Power operator `^` is right-associative, meaning:
  /// - `2^3^2` = `2^(3^2)` = `2^9` = 512
  /// - NOT `(2^3)^2` = `8^2` = 64
  /// 
  /// This is achieved by processing from right to left.
  /// Uses [math.pow] for the actual exponentiation computation.
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
