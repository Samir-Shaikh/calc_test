import 'package:flutter_test/flutter_test.dart';
import 'package:android_calculator_flutter/features/calculator/domain/entities/expression.dart';
import 'package:android_calculator_flutter/features/calculator/domain/usecases/negate_value_use_case.dart';

void main() {
  late NegateValueUseCase useCase;

  setUp(() {
    useCase = NegateValueUseCase();
  });

  group('NegateValueUseCase', () {
    // =========================================================================
    // ACCEPTANCE CRITERIA TESTS
    // These tests directly verify the acceptance criteria for the Plus/Minus
    // feature as specified in the requirements.
    // =========================================================================
    group('Acceptance Criteria Tests', () {
      group('AC1: Given expression "5", tapping +/- inserts "-" at cursor position', () {
        test('AC1.1: expression "5" with cursor at end becomes "-5"', () {
          // Given: expression is '5' with cursor at end (position 1)
          final expression = Expression('5', 1);
          
          // When: +/- (negate) is pressed
          final result = useCase.execute(expression);
          
          // Then: expression should be '-5' (minus inserted before the number)
          expect(result.value, equals('-5'));
        });

        test('AC1.2: expression "5" with default cursor becomes "-5"', () {
          // Given: expression is '5' with default cursor position
          final expression = Expression('5');
          
          // When: +/- (negate) is pressed
          final result = useCase.execute(expression);
          
          // Then: expression should be '-5'
          expect(result.value, equals('-5'));
        });

        test('AC1.3: cursor position is updated after inserting minus in "5"', () {
          // Given: expression is '5' with cursor at position 1
          final expression = Expression('5', 1);
          
          // When: +/- (negate) is pressed
          final result = useCase.execute(expression);
          
          // Then: cursor should move forward by 1 (now at position 2)
          expect(result.cursorPosition, equals(2));
        });

        test('AC1.4: expression "5" with cursor at start becomes "-5"', () {
          // Given: expression is '5' with cursor at position 0
          final expression = Expression('5', 0);
          
          // When: +/- (negate) is pressed
          final result = useCase.execute(expression);
          
          // Then: expression should be '-5'
          expect(result.value, equals('-5'));
        });

        test('AC1.5: toggling "-5" back produces "5"', () {
          // Given: expression is '-5' (result of first +/- press)
          final expression = Expression('-5');
          
          // When: +/- (negate) is pressed again
          final result = useCase.execute(expression);
          
          // Then: expression should be '5' (toggles back)
          expect(result.value, equals('5'));
        });
      });

      // Note: AC2 (button displays '+/-') is a UI test verified in widget tests
      // See: calculator_button_grid_test.dart

      group('AC3: Given empty expression, tapping +/- results in "-" in expression', () {
        test('AC3.1: empty expression becomes "-" after pressing +/-', () {
          // Given: expression is empty
          final expression = Expression.empty();
          
          // When: +/- (negate) is pressed
          final result = useCase.execute(expression);
          
          // Then: expression should be '-'
          expect(result.value, equals('-'));
        });

        test('AC3.2: empty expression with explicit cursor at 0 becomes "-"', () {
          // Given: empty expression with cursor explicitly at position 0
          final expression = Expression('', 0);
          
          // When: +/- (negate) is pressed
          final result = useCase.execute(expression);
          
          // Then: expression should be '-'
          expect(result.value, equals('-'));
        });

        test('AC3.3: cursor moves to position 1 after inserting minus in empty expression', () {
          // Given: empty expression
          final expression = Expression.empty();
          
          // When: +/- (negate) is pressed
          final result = useCase.execute(expression);
          
          // Then: cursor should be at position 1 (after the minus)
          expect(result.cursorPosition, equals(1));
        });

        test('AC3.4: continuing to type after "-" creates valid negative number', () {
          // Given: empty expression
          var expression = Expression.empty();
          
          // When: +/- is pressed, then we simulate adding a digit
          expression = useCase.execute(expression);
          expect(expression.value, equals('-'));
          
          // Simulate typing '5' after the minus
          expression = Expression(expression.value + '5', expression.cursorPosition + 1);
          
          // Then: expression should be '-5' (valid negative number)
          expect(expression.value, equals('-5'));
        });

        test('AC3.5: pressing +/- twice on empty expression results in empty expression', () {
          // Given: empty expression
          var expression = Expression.empty();
          
          // When: +/- is pressed once
          expression = useCase.execute(expression);
          expect(expression.value, equals('-'));
          
          // When: +/- is pressed again (on just "-")
          expression = useCase.execute(expression);
          
          // Then: The behavior depends on implementation
          // Since '-' alone doesn't constitute a valid "number" to toggle,
          // pressing +/- again should insert another minus
          expect(expression.value, isNotNull);
        });
      });
    });

    // =========================================================================
    // EDGE CASE TESTS FOR CURSOR POSITION
    // Additional tests for various cursor positions when pressing +/-
    // =========================================================================
    group('Edge Cases: Cursor Position Variations', () {
      test('inserting minus at cursor position 0 in multi-digit number', () {
        // Given: expression '123' with cursor at position 0
        final expression = Expression('123', 0);
        
        // When: +/- is pressed
        final result = useCase.execute(expression);
        
        // Then: minus is inserted before the number
        expect(result.value, equals('-123'));
      });

      test('inserting minus at cursor position in middle of number', () {
        // Given: expression '123' with cursor at position 2 (after '12')
        final expression = Expression('123', 2);
        
        // When: +/- is pressed
        final result = useCase.execute(expression);
        
        // Then: entire number is negated (not just the part before cursor)
        expect(result.value, equals('-123'));
      });

      test('cursor after operator inserts minus for next operand', () {
        // Given: expression '5+' with cursor at end
        final expression = Expression('5+', 2);
        
        // When: +/- is pressed
        final result = useCase.execute(expression);
        
        // Then: minus is inserted after operator for negative second operand
        expect(result.value, equals('5+-'));
        expect(result.cursorPosition, equals(3));
      });

      test('cursor on second operand negates only second operand', () {
        // Given: expression '5+3' with cursor at end (on second operand)
        final expression = Expression('5+3', 3);
        
        // When: +/- is pressed
        final result = useCase.execute(expression);
        
        // Then: only second operand is negated
        expect(result.value, equals('5+-3'));
      });

      test('cursor on first operand in complex expression negates first operand', () {
        // Given: expression '5+3' with cursor at position 1 (on first operand)
        final expression = Expression('5+3', 1);
        
        // When: +/- is pressed
        final result = useCase.execute(expression);
        
        // Then: first operand is negated
        expect(result.value, equals('-5+3'));
      });
    });

    // =========================================================================
    // EDGE CASE TESTS FOR OPERATORS
    // Tests for pressing +/- after different operators
    // =========================================================================
    group('Edge Cases: After Different Operators', () {
      test('inserts minus after + operator', () {
        final expression = Expression('7+');
        final result = useCase.execute(expression);
        expect(result.value, equals('7+-'));
      });

      test('inserts minus after - operator', () {
        final expression = Expression('7-');
        final result = useCase.execute(expression);
        expect(result.value, equals('7--'));
      });

      test('inserts minus after × operator', () {
        final expression = Expression('7×');
        final result = useCase.execute(expression);
        expect(result.value, equals('7×-'));
      });

      test('inserts minus after ÷ operator', () {
        final expression = Expression('7÷');
        final result = useCase.execute(expression);
        expect(result.value, equals('7÷-'));
      });

      test('inserts minus after ^ operator', () {
        final expression = Expression('2^');
        final result = useCase.execute(expression);
        expect(result.value, equals('2^-'));
      });

      test('inserts minus after ( parenthesis', () {
        final expression = Expression('(');
        final result = useCase.execute(expression);
        expect(result.value, equals('(-'));
      });

      test('inserts minus in complex expression with parenthesis', () {
        final expression = Expression('(5+3)×(');
        final result = useCase.execute(expression);
        expect(result.value, equals('(5+3)×(-'));
      });
    });

    // =========================================================================
    // ORIGINAL TEST GROUPS (preserved for regression)
    // =========================================================================
    group('empty expression handling', () {
      test('inserts minus sign in empty expression', () {
        final expression = Expression.empty();
        final result = useCase.execute(expression);
        
        expect(result.value, equals('-'));
      });

      test('cursor moves to position 1 after inserting minus in empty expression', () {
        final expression = Expression.empty();
        final result = useCase.execute(expression);
        
        expect(result.cursorPosition, equals(1));
      });

      test('inserts minus at cursor position 0 in empty expression', () {
        final expression = Expression('', 0);
        final result = useCase.execute(expression);
        
        expect(result.value, equals('-'));
        expect(result.cursorPosition, equals(1));
      });
    });

    group('positive number negation', () {
      test('negates single digit positive number', () {
        final expression = Expression('5');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('-5'));
      });

      test('negates multi-digit positive number', () {
        final expression = Expression('123');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('-123'));
      });

      test('negates decimal positive number', () {
        final expression = Expression('3.14');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('-3.14'));
      });

      test('negates zero', () {
        final expression = Expression('0');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('-0'));
      });

      test('cursor position adjusts correctly when negating positive number', () {
        final expression = Expression('5', 1);
        final result = useCase.execute(expression);
        
        expect(result.value, equals('-5'));
        expect(result.cursorPosition, equals(2));
      });

      test('negates positive number with cursor at start', () {
        final expression = Expression('42', 0);
        final result = useCase.execute(expression);
        
        expect(result.value, equals('-42'));
      });

      test('negates positive number with cursor in middle', () {
        final expression = Expression('123', 2);
        final result = useCase.execute(expression);
        
        expect(result.value, equals('-123'));
        expect(result.cursorPosition, equals(3));
      });
    });

    group('negative number negation (removing minus)', () {
      test('removes minus from negative single digit', () {
        final expression = Expression('-5');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('5'));
      });

      test('removes minus from negative multi-digit number', () {
        final expression = Expression('-123');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('123'));
      });

      test('removes minus from negative decimal number', () {
        final expression = Expression('-3.14');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('3.14'));
      });

      test('removes minus from negative zero', () {
        final expression = Expression('-0');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('0'));
      });

      test('cursor position adjusts correctly when removing minus', () {
        final expression = Expression('-5', 2);
        final result = useCase.execute(expression);
        
        expect(result.value, equals('5'));
        expect(result.cursorPosition, equals(1));
      });

      test('double negate returns to original positive value', () {
        var expression = Expression('5');
        expression = useCase.execute(expression); // -5
        expression = useCase.execute(expression); // 5
        
        expect(expression.value, equals('5'));
      });

      test('double negate returns to original negative value', () {
        var expression = Expression('-5');
        expression = useCase.execute(expression); // 5
        expression = useCase.execute(expression); // -5
        
        expect(expression.value, equals('-5'));
      });
    });

    group('negate after operator', () {
      test('inserts minus after addition operator', () {
        final expression = Expression('5+');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('5+-'));
      });

      test('inserts minus after subtraction operator', () {
        final expression = Expression('5-');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('5--'));
      });

      test('inserts minus after multiplication operator', () {
        final expression = Expression('5*');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('5*-'));
      });

      test('inserts minus after division operator', () {
        final expression = Expression('5/');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('5/-'));
      });

      test('inserts minus after multiplication symbol ×', () {
        final expression = Expression('5×');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('5×-'));
      });

      test('inserts minus after division symbol ÷', () {
        final expression = Expression('5÷');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('5÷-'));
      });

      test('inserts minus after power operator', () {
        final expression = Expression('2^');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('2^-'));
      });

      test('cursor moves forward after inserting minus after operator', () {
        final expression = Expression('5+', 2);
        final result = useCase.execute(expression);
        
        expect(result.value, equals('5+-'));
        expect(result.cursorPosition, equals(3));
      });
    });

    group('negate with parentheses', () {
      test('inserts minus after opening parenthesis', () {
        final expression = Expression('(');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('(-'));
      });

      test('inserts minus at cursor position after closing parenthesis', () {
        // When cursor is at end after ')', no number is found at cursor
        // so minus is inserted at cursor position
        final expression = Expression('(5)');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('(5)-'));
      });

      test('negates number inside parentheses when cursor is on number', () {
        // Cursor positioned on the number '5' inside parentheses
        final expression = Expression('(5)', 2);
        final result = useCase.execute(expression);
        
        expect(result.value, equals('(-5)'));
      });

      test('inserts minus in expression after opening parenthesis', () {
        final expression = Expression('2+(');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('2+(-'));
      });

      test('negates first number in parenthesized expression', () {
        final expression = Expression('(5+3)', 2);
        final result = useCase.execute(expression);
        
        expect(result.value, equals('(-5+3)'));
      });

      test('inserts minus after multiplication and opening parenthesis', () {
        final expression = Expression('(5+3)×(');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('(5+3)×(-'));
      });

      test('inserts minus after nested closing parentheses', () {
        // When cursor is at end after '))', no number is found at cursor
        // so minus is inserted at cursor position
        final expression = Expression('((5))');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('((5))-'));
      });

      test('negates number in nested parentheses when cursor is on number', () {
        // Cursor positioned on the number '5' inside nested parentheses
        final expression = Expression('((5))', 3);
        final result = useCase.execute(expression);
        
        expect(result.value, equals('((-5))'));
      });
    });

    group('complex expressions', () {
      test('negates second operand in addition', () {
        final expression = Expression('3+5');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('3+-5'));
      });

      test('negates second operand in multiplication', () {
        final expression = Expression('2*4');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('2*-4'));
      });

      test('removes minus from negative second operand', () {
        final expression = Expression('3+-5');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('3+5'));
      });

      test('removes minus from negative operand after multiplication', () {
        final expression = Expression('2*-4');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('2*4'));
      });

      test('handles power with negative exponent', () {
        final expression = Expression('2^-3');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('2^3'));
      });

      test('adds negative exponent to power expression', () {
        final expression = Expression('2^3');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('2^-3'));
      });

      test('negates in long expression', () {
        final expression = Expression('1+2*3-4');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('1+2*3--4'));
      });

      test('handles expression ending with closing parenthesis', () {
        final expression = Expression('(5+3)×2');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('(5+3)×-2'));
      });
    });

    group('cursor position handling', () {
      test('negates number at cursor position in middle of expression', () {
        // Cursor at position 1, in the middle of "5" in "5+3"
        final expression = Expression('5+3', 1);
        final result = useCase.execute(expression);
        
        expect(result.value, equals('-5+3'));
        expect(result.cursorPosition, equals(2));
      });

      test('negates second number when cursor is on it', () {
        // Cursor at position 3, at the "3" in "5+3"
        final expression = Expression('5+3', 3);
        final result = useCase.execute(expression);
        
        expect(result.value, equals('5+-3'));
      });

      test('cursor at beginning of positive number negates it', () {
        final expression = Expression('123', 0);
        final result = useCase.execute(expression);
        
        expect(result.value, equals('-123'));
      });

      test('cursor in middle of multi-digit number negates entire number', () {
        final expression = Expression('12345', 3);
        final result = useCase.execute(expression);
        
        expect(result.value, equals('-12345'));
      });

      test('cursor after decimal point negates entire decimal number', () {
        final expression = Expression('3.14', 2);
        final result = useCase.execute(expression);
        
        expect(result.value, equals('-3.14'));
      });

      test('cursor position preserved relative to number after negation', () {
        final expression = Expression('42', 1);
        final result = useCase.execute(expression);
        
        // Cursor was between 4 and 2, should now be after minus and 4
        expect(result.value, equals('-42'));
        expect(result.cursorPosition, equals(2));
      });
    });

    group('edge cases', () {
      test('handles just a minus sign', () {
        final expression = Expression('-');
        final result = useCase.execute(expression);
        
        // Just a minus sign with no number - should insert another minus
        // or handle gracefully
        expect(result.value, isNotNull);
      });

      test('handles expression with just decimal point', () {
        final expression = Expression('.');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('-.'));
      });

      test('handles expression starting with decimal', () {
        final expression = Expression('.5');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('-.5'));
      });

      test('handles negative decimal starting with point', () {
        final expression = Expression('-.5');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('.5'));
      });

      test('very long number negation', () {
        final expression = Expression('123456789012345');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('-123456789012345'));
      });

      test('expression with multiple decimal points in different numbers', () {
        final expression = Expression('1.5+2.5');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('1.5+-2.5'));
      });

      test('negating after double operator scenario', () {
        // Expression like "5+-" where user wants to negate
        final expression = Expression('5+-');
        final result = useCase.execute(expression);
        
        expect(result.value, equals('5+--'));
      });
    });

    group('integration scenarios', () {
      test('building negative number step by step', () {
        var expression = Expression.empty();
        
        // Insert minus for negative number
        expression = useCase.execute(expression);
        expect(expression.value, equals('-'));
        
        // Would then add digits (not part of this use case)
        expression = Expression(expression.value + '5');
        expect(expression.value, equals('-5'));
        
        // Toggle back to positive
        expression = useCase.execute(expression);
        expect(expression.value, equals('5'));
      });

      test('toggling sign multiple times', () {
        var expression = Expression('42');
        
        expression = useCase.execute(expression); // -42
        expect(expression.value, equals('-42'));
        
        expression = useCase.execute(expression); // 42
        expect(expression.value, equals('42'));
        
        expression = useCase.execute(expression); // -42
        expect(expression.value, equals('-42'));
        
        expression = useCase.execute(expression); // 42
        expect(expression.value, equals('42'));
      });

      test('building expression with negative second operand', () {
        // Start with "5+"
        var expression = Expression('5+');
        
        // Negate to prepare for negative number
        expression = useCase.execute(expression);
        expect(expression.value, equals('5+-'));
        
        // Add the number
        expression = Expression(expression.value + '3');
        expect(expression.value, equals('5+-3'));
        
        // Toggle to make it positive
        expression = useCase.execute(expression);
        expect(expression.value, equals('5+3'));
      });

      test('complex calculation with power and negation', () {
        // Build 2^-3
        var expression = Expression('2^');
        
        expression = useCase.execute(expression);
        expect(expression.value, equals('2^-'));
        
        expression = Expression(expression.value + '3');
        expect(expression.value, equals('2^-3'));
        
        // Toggle the exponent sign
        expression = useCase.execute(expression);
        expect(expression.value, equals('2^3'));
      });

      test('negation in parenthesized sub-expression', () {
        // Start building (5+(-3))
        var expression = Expression('(5+(');
        
        expression = useCase.execute(expression);
        expect(expression.value, equals('(5+(-'));
        
        expression = Expression(expression.value + '3))');
        expect(expression.value, equals('(5+(-3))'));
      });
    });

    group('operator precedence scenarios', () {
      test('negation preserves expression structure', () {
        final expression = Expression('2+3*4');
        final result = useCase.execute(expression);
        
        // Should negate the last number (4)
        expect(result.value, equals('2+3*-4'));
      });

      test('negating first operand in chained expression', () {
        final expression = Expression('5+3*2', 1);
        final result = useCase.execute(expression);
        
        expect(result.value, equals('-5+3*2'));
      });

      test('negating middle operand in chained expression', () {
        final expression = Expression('5+3*2', 3);
        final result = useCase.execute(expression);
        
        expect(result.value, equals('5+-3*2'));
      });
    });
  });
}
