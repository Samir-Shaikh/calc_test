import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/expression_display/expression_display_bloc.dart';
import '../blocs/expression_display/expression_display_event.dart';
import 'clear_button_config.dart';
import 'operator_button_config.dart';
import 'parenthesis_button_config.dart';
import 'power_button_config.dart';

/// A widget that displays the calculator button grid.
///
/// This widget arranges all calculator buttons in a grid layout,
/// including digits, operators, parentheses, and special function buttons.
/// Each button dispatches the appropriate event to the [ExpressionDisplayBloc]
/// when tapped.
class CalculatorButtonGrid extends StatelessWidget {
  const CalculatorButtonGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Row 1: C, (), %, ÷
          Expanded(
            child: Row(
              children: [
                _buildClearButton(context),
                const SizedBox(width: 12),
                _buildParenthesisButton(context),
                const SizedBox(width: 12),
                _buildFunctionButton(context, '%', () {
                  context.read<ExpressionDisplayBloc>().add(const OperatorPressed('%'));
                }),
                const SizedBox(width: 12),
                _buildOperatorButton(context, '÷', () {
                  context.read<ExpressionDisplayBloc>().add(const OperatorPressed('÷'));
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Row 2: 7, 8, 9, ×
          Expanded(
            child: Row(
              children: [
                _buildDigitButton(context, '7'),
                const SizedBox(width: 12),
                _buildDigitButton(context, '8'),
                const SizedBox(width: 12),
                _buildDigitButton(context, '9'),
                const SizedBox(width: 12),
                _buildOperatorButton(context, '×', () {
                  context.read<ExpressionDisplayBloc>().add(const OperatorPressed('×'));
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Row 3: 4, 5, 6, -
          Expanded(
            child: Row(
              children: [
                _buildDigitButton(context, '4'),
                const SizedBox(width: 12),
                _buildDigitButton(context, '5'),
                const SizedBox(width: 12),
                _buildDigitButton(context, '6'),
                const SizedBox(width: 12),
                _buildOperatorButton(context, '-', () {
                  context.read<ExpressionDisplayBloc>().add(const OperatorPressed('-'));
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Row 4: 1, 2, 3, +
          Expanded(
            child: Row(
              children: [
                _buildDigitButton(context, '1'),
                const SizedBox(width: 12),
                _buildDigitButton(context, '2'),
                const SizedBox(width: 12),
                _buildDigitButton(context, '3'),
                const SizedBox(width: 12),
                _buildOperatorButton(context, '+', () {
                  context.read<ExpressionDisplayBloc>().add(const OperatorPressed('+'));
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Row 5: ^, 0, ., ⌫, =
          Expanded(
            child: Row(
              children: [
                _buildPowerButton(context),
                const SizedBox(width: 12),
                _buildDigitButton(context, '0'),
                const SizedBox(width: 12),
                _buildDigitButton(context, '.', isDecimal: true),
                const SizedBox(width: 12),
                _buildFunctionButton(context, '⌫', () {
                  context.read<ExpressionDisplayBloc>().add(const BackspacePressed());
                }),
                const SizedBox(width: 12),
                _buildEqualsButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a digit button (0-9).
  Widget _buildDigitButton(BuildContext context, String digit, {bool isDecimal = false}) {
    return Expanded(
      child: _CalculatorButton(
        label: digit,
        onPressed: () {
          if (isDecimal) {
            context.read<ExpressionDisplayBloc>().add(const DecimalPressed());
          } else {
            context.read<ExpressionDisplayBloc>().add(NumericPressed(digit));
          }
        },
        backgroundColor: Colors.grey.shade800,
        textColor: Colors.white,
      ),
    );
  }

  /// Builds the clear button.
  ///
  /// Uses [ClearButtonConfig] for styling and dispatches
  /// [ClearPressed] event when tapped to reset the expression.
  Widget _buildClearButton(BuildContext context) {
    return Expanded(
      child: _CalculatorButton(
        key: const Key('clear_button'),
        label: ClearButtonConfig.label,
        onPressed: () {
          context.read<ExpressionDisplayBloc>().add(const ClearPressed());
        },
        backgroundColor: ClearButtonConfig.backgroundColor,
        textColor: ClearButtonConfig.textColor,
        decoration: ClearButtonConfig.decoration,
      ),
    );
  }

  /// Builds the parenthesis toggle button.
  ///
  /// Uses [ParenthesisButtonConfig] for styling and dispatches
  /// [ParenthesisPressed] event when tapped.
  Widget _buildParenthesisButton(BuildContext context) {
    return Expanded(
      child: _CalculatorButton(
        key: const Key('parenthesis_button'),
        label: ParenthesisButtonConfig.label,
        onPressed: () {
          context.read<ExpressionDisplayBloc>().add(const ParenthesisPressed());
        },
        backgroundColor: ParenthesisButtonConfig.backgroundColor,
        textColor: ParenthesisButtonConfig.textColor,
        decoration: ParenthesisButtonConfig.decoration,
      ),
    );
  }

  /// Builds the power operator button.
  ///
  /// Uses [PowerButtonConfig] for styling and dispatches
  /// [PowerOperatorPressed] event when tapped.
  Widget _buildPowerButton(BuildContext context) {
    return Expanded(
      child: _CalculatorButton(
        key: const Key('power_button'),
        label: PowerButtonConfig.label,
        onPressed: () {
          context.read<ExpressionDisplayBloc>().add(const PowerOperatorPressed());
        },
        backgroundColor: PowerButtonConfig.backgroundColor,
        textColor: PowerButtonConfig.textColor,
        decoration: PowerButtonConfig.decoration,
      ),
    );
  }

  /// Builds an operator button (+, -, ×, ÷).
  ///
  /// Uses [OperatorButtonConfig] for styling to ensure consistent
  /// orange (#FF9500) background across all operator buttons.
  Widget _buildOperatorButton(BuildContext context, String operator, VoidCallback onPressed) {
    return Expanded(
      child: _CalculatorButton(
        label: operator,
        onPressed: onPressed,
        backgroundColor: OperatorButtonConfig.backgroundColor,
        textColor: OperatorButtonConfig.textColor,
        decoration: OperatorButtonConfig.decoration,
      ),
    );
  }

  /// Builds a function button (%, ⌫).
  Widget _buildFunctionButton(BuildContext context, String label, VoidCallback onPressed) {
    return Expanded(
      child: _CalculatorButton(
        label: label,
        onPressed: onPressed,
        backgroundColor: Colors.grey.shade600,
        textColor: Colors.white,
      ),
    );
  }

  /// Builds the equals button.
  ///
  /// Uses [EqualsButtonConfig] for styling to ensure the button displays
  /// with the correct orange (#FF9500) background color and '=' symbol.
  Widget _buildEqualsButton(BuildContext context) {
    return Expanded(
      child: _CalculatorButton(
        key: const Key('equals_button'),
        label: EqualsButtonConfig.label,
        onPressed: () {
          context.read<ExpressionDisplayBloc>().add(const EqualsPressed());
        },
        backgroundColor: EqualsButtonConfig.backgroundColor,
        textColor: EqualsButtonConfig.textColor,
        decoration: EqualsButtonConfig.decoration,
      ),
    );
  }
}

/// A single calculator button with customizable styling.
class _CalculatorButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final BoxDecoration? decoration;

  const _CalculatorButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: decoration ??
            BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
