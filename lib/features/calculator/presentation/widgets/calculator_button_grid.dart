import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/expression_display/expression_display_bloc.dart';
import '../blocs/expression_display/expression_display_event.dart';
import '../theme/calculator_dimensions.dart';
import 'clear_button_config.dart';
import 'negate_button_config.dart';
import 'operator_button_config.dart';
import 'parenthesis_button_config.dart';
import 'power_button_config.dart';

/// A widget that displays the calculator button grid.
///
/// This widget arranges all calculator buttons in a standard 5-row grid layout
/// using a Table widget with equal-width buttons:
/// - Row 1: C, (), ^, ÷
/// - Row 2: 7, 8, 9, ×
/// - Row 3: 4, 5, 6, +
/// - Row 4: 1, 2, 3, -
/// - Row 5: +/-, 0, ., =
///
/// Each button dispatches the appropriate event to the [ExpressionDisplayBloc]
/// when tapped.
class CalculatorButtonGrid extends StatelessWidget {
  const CalculatorButtonGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CalculatorDimensions.gridPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate row height based on available height
          // 5 rows + 4 gaps between them
          final availableHeight = constraints.maxHeight;
          final buttonHeight = (availableHeight - (CalculatorDimensions.rowSpacing * 4)) / 5;

          return Table(
            defaultColumnWidth: const FlexColumnWidth(1),
            children: [
              // Row 1: C, (), ^, ÷
              _buildTableRow(
                context,
                buttonHeight,
                [
                  _buildClearButton(context),
                  _buildParenthesisButton(context),
                  _buildPowerButton(context),
                  _buildOperatorButton(context, '÷', () {
                    context.read<ExpressionDisplayBloc>().add(const OperatorPressed('÷'));
                  }),
                ],
              ),
              // Spacing row
              _buildSpacingRow(CalculatorDimensions.rowSpacing),
              // Row 2: 7, 8, 9, ×
              _buildTableRow(
                context,
                buttonHeight,
                [
                  _buildDigitButton(context, '7'),
                  _buildDigitButton(context, '8'),
                  _buildDigitButton(context, '9'),
                  _buildOperatorButton(context, '×', () {
                    context.read<ExpressionDisplayBloc>().add(const OperatorPressed('×'));
                  }),
                ],
              ),
              // Spacing row
              _buildSpacingRow(CalculatorDimensions.rowSpacing),
              // Row 3: 4, 5, 6, +
              _buildTableRow(
                context,
                buttonHeight,
                [
                  _buildDigitButton(context, '4'),
                  _buildDigitButton(context, '5'),
                  _buildDigitButton(context, '6'),
                  _buildOperatorButton(context, '+', () {
                    context.read<ExpressionDisplayBloc>().add(const OperatorPressed('+'));
                  }),
                ],
              ),
              // Spacing row
              _buildSpacingRow(CalculatorDimensions.rowSpacing),
              // Row 4: 1, 2, 3, -
              _buildTableRow(
                context,
                buttonHeight,
                [
                  _buildDigitButton(context, '1'),
                  _buildDigitButton(context, '2'),
                  _buildDigitButton(context, '3'),
                  _buildOperatorButton(context, '-', () {
                    context.read<ExpressionDisplayBloc>().add(const OperatorPressed('-'));
                  }),
                ],
              ),
              // Spacing row
              _buildSpacingRow(CalculatorDimensions.rowSpacing),
              // Row 5: +/-, 0, ., =
              _buildTableRow(
                context,
                buttonHeight,
                [
                  _buildNegateButton(context),
                  _buildDigitButton(context, '0'),
                  _buildDigitButton(context, '.', isDecimal: true),
                  _buildEqualsButton(context),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds a table row with the given buttons.
  TableRow _buildTableRow(
    BuildContext context,
    double height,
    List<Widget> buttons,
  ) {
    final cells = <Widget>[];
    for (var i = 0; i < buttons.length; i++) {
      cells.add(
        TableCell(
          child: SizedBox(
            height: height,
            child: buttons[i],
          ),
        ),
      );
      // Add spacing between buttons (except after the last one)
      if (i < buttons.length - 1) {
        cells.add(
          TableCell(
            child: SizedBox(
              width: CalculatorDimensions.buttonSpacing,
              height: height,
            ),
          ),
        );
      }
    }

    return TableRow(children: cells);
  }

  /// Builds a spacing row between button rows.
  TableRow _buildSpacingRow(double height) {
    return TableRow(
      children: List.generate(
        7, // 4 buttons + 3 spacers
        (_) => TableCell(
          child: SizedBox(height: height),
        ),
      ),
    );
  }

  /// Builds a digit button (0-9).
  Widget _buildDigitButton(BuildContext context, String digit, {bool isDecimal = false}) {
    return _CalculatorButton(
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
    );
  }

  /// Builds the clear button.
  ///
  /// Uses [ClearButtonConfig] for styling and dispatches
  /// [ClearPressed] event when tapped to reset the expression.
  Widget _buildClearButton(BuildContext context) {
    return _CalculatorButton(
      key: const Key('clear_button'),
      label: ClearButtonConfig.label,
      onPressed: () {
        context.read<ExpressionDisplayBloc>().add(const ClearPressed());
      },
      backgroundColor: ClearButtonConfig.backgroundColor,
      textColor: ClearButtonConfig.textColor,
      decoration: ClearButtonConfig.decoration,
    );
  }

  /// Builds the parenthesis toggle button.
  ///
  /// Uses [ParenthesisButtonConfig] for styling and dispatches
  /// [ParenthesisPressed] event when tapped.
  Widget _buildParenthesisButton(BuildContext context) {
    return _CalculatorButton(
      key: const Key('parenthesis_button'),
      label: ParenthesisButtonConfig.label,
      onPressed: () {
        context.read<ExpressionDisplayBloc>().add(const ParenthesisPressed());
      },
      backgroundColor: ParenthesisButtonConfig.backgroundColor,
      textColor: ParenthesisButtonConfig.textColor,
      decoration: ParenthesisButtonConfig.decoration,
    );
  }

  /// Builds the power operator button.
  ///
  /// Uses [PowerButtonConfig] for styling and dispatches
  /// [PowerOperatorPressed] event when tapped.
  Widget _buildPowerButton(BuildContext context) {
    return _CalculatorButton(
      key: const Key('power_button'),
      label: PowerButtonConfig.label,
      onPressed: () {
        context.read<ExpressionDisplayBloc>().add(const PowerOperatorPressed());
      },
      backgroundColor: PowerButtonConfig.backgroundColor,
      textColor: PowerButtonConfig.textColor,
      decoration: PowerButtonConfig.decoration,
    );
  }

  /// Builds the negate button (+/-).
  ///
  /// Uses [NegateButtonConfig] for styling and dispatches
  /// [NegatePressed] event when tapped to toggle the sign of the current number.
  Widget _buildNegateButton(BuildContext context) {
    return _CalculatorButton(
      key: const Key('negate_button'),
      label: NegateButtonConfig.label,
      onPressed: () {
        context.read<ExpressionDisplayBloc>().add(const NegatePressed());
      },
      backgroundColor: NegateButtonConfig.backgroundColor,
      textColor: NegateButtonConfig.textColor,
      decoration: NegateButtonConfig.decoration,
    );
  }

  /// Builds an operator button (+, -, ×, ÷).
  ///
  /// Uses [OperatorButtonConfig] for styling to ensure consistent
  /// orange (#FF9500) background across all operator buttons.
  Widget _buildOperatorButton(BuildContext context, String operator, VoidCallback onPressed) {
    return _CalculatorButton(
      label: operator,
      onPressed: onPressed,
      backgroundColor: OperatorButtonConfig.backgroundColor,
      textColor: OperatorButtonConfig.textColor,
      decoration: OperatorButtonConfig.decoration,
    );
  }

  /// Builds the equals button.
  ///
  /// Uses [EqualsButtonConfig] for styling to ensure the button displays
  /// with the correct orange (#FF9500) background color and '=' symbol.
  Widget _buildEqualsButton(BuildContext context) {
    return _CalculatorButton(
      key: const Key('equals_button'),
      label: EqualsButtonConfig.label,
      onPressed: () {
        context.read<ExpressionDisplayBloc>().add(const EqualsPressed());
      },
      backgroundColor: EqualsButtonConfig.backgroundColor,
      textColor: EqualsButtonConfig.textColor,
      decoration: EqualsButtonConfig.decoration,
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
