/// Use case for evaluating mathematical expressions.
/// 
/// This use case takes a mathematical expression string and evaluates it,
/// returning the result as a formatted string. It handles division by zero
/// by returning 'Infinity' or '-Infinity' as per JavaScript/Rhino behavior.
/// It also supports parentheses for grouping operations.
class EvaluateExpressionUseCase {
  /// Executes the expression evaluation.
  /// 
  /// Takes an [expression] string containing a mathematical expression
  /// (e.g., "10/0", "5+3*2", "(2+3)*4") and returns the evaluated result as a string.
  /// 
  /// Division by zero behavior (matches JavaScript/Rhino):
  /// - Positive number / 0 = 'Infinity'
  /// - Negative number / 0 = '-Infinity'
  /// - 0 / 0 = 'NaN'
  /// 
  /// Parentheses:
  /// - Supports nested parentheses for grouping operations
  /// - Unmatched parentheses return 'Error'
  String execute(String expression) {
    try {
      // Replace display operators with calculation operators
      String normalizedExpression = expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/');
      
      // Validate parentheses balance
      if (!_areParenthesesBalanced(normalizedExpression)) {
        return 'Error';
      }
      
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
  /// Supports: +, -, *, / operators with proper precedence and parentheses.
  double _evaluate(String expression) {
    expression = expression.replaceAll(' ', '');
    
    // Handle empty expression
    if (expression.isEmpty) {
      return 0;
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
        throw FormatException('Invalid parentheses');
      }
      
      // Extract the sub-expression inside parentheses
      String subExpression = expression.substring(openIndex + 1, closeIndex);
      
      // Handle empty parentheses
      if (subExpression.isEmpty) {
        throw FormatException('Empty parentheses');
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
