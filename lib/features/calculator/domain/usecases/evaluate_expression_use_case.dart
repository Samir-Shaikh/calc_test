/// Use case for evaluating mathematical expressions.
/// 
/// This use case takes a mathematical expression string and evaluates it,
/// returning the result as a formatted string. It handles division by zero
/// by returning 'Infinity' or '-Infinity' as per JavaScript/Rhino behavior.
class EvaluateExpressionUseCase {
  /// Executes the expression evaluation.
  /// 
  /// Takes an [expression] string containing a mathematical expression
  /// (e.g., "10/0", "5+3*2") and returns the evaluated result as a string.
  /// 
  /// Division by zero behavior (matches JavaScript/Rhino):
  /// - Positive number / 0 = 'Infinity'
  /// - Negative number / 0 = '-Infinity'
  /// - 0 / 0 = 'NaN'
  String execute(String expression) {
    try {
      // Replace display operators with calculation operators
      String normalizedExpression = expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/');
      
      // Parse and evaluate the expression
      final result = _evaluate(normalizedExpression);
      
      // Format the result
      if (result.isInfinite) {
        return result.isNegative ? '-Infinity' : 'Infinity';
      }
      if (result.isNaN) {
        return 'NaN';
      }
      
      // Format the result - remove trailing zeros for whole numbers
      if (result == result.truncateToDouble()) {
        return result.toInt().toString();
      }
      return result.toString();
    } catch (e) {
      return 'Error';
    }
  }
  
  /// Evaluates a mathematical expression string.
  /// 
  /// Supports: +, -, *, / operators with proper precedence.
  double _evaluate(String expression) {
    expression = expression.replaceAll(' ', '');
    
    // Handle empty expression
    if (expression.isEmpty) {
      return 0;
    }
    
    // Tokenize the expression
    final tokens = _tokenize(expression);
    
    // Evaluate using shunting-yard algorithm principles
    return _evaluateTokens(tokens);
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
    return ['+', '-', '*', '/'].contains(char);
  }
  
  /// Evaluates tokens with proper operator precedence.
  double _evaluateTokens(List<String> tokens) {
    if (tokens.isEmpty) {
      return 0;
    }
    
    // First pass: handle * and /
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
    
    // Second pass: handle + and -
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
}
