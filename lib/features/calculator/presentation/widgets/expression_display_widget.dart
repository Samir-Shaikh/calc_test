import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/expression_display/expression_display_bloc.dart';
import '../blocs/expression_display/expression_display_state.dart';
import '../theme/calculator_dimensions.dart';

/// Widget that displays the current expression and result.
///
/// Uses [BlocBuilder] to rebuild only when the expression or result changes.
/// The display uses RTL-aware alignment (TextAlign.end and CrossAxisAlignment.end)
/// to ensure proper text positioning in both LTR and RTL locales.
///
/// In LTR locales, text aligns to the right.
/// In RTL locales, text aligns to the left.
class ExpressionDisplayWidget extends StatelessWidget {
  const ExpressionDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpressionDisplayBloc, ExpressionDisplayState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(CalculatorDimensions.displayPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Expression text - uses TextAlign.end for RTL support
              Text(
                state.displayExpression.isEmpty ? '0' : state.displayExpression,
                style: const TextStyle(
                  fontSize: CalculatorDimensions.expressionFontSize,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
              const SizedBox(height: CalculatorDimensions.expressionResultSpacing),
              // Result text (if available) - uses TextAlign.end for RTL support
              if (state.result != null)
                Text(
                  '= ${state.result}',
                  style: TextStyle(
                    fontSize: CalculatorDimensions.resultFontSize,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
            ],
          ),
        );
      },
    );
  }
}
