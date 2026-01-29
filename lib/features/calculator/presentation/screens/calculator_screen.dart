import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/expression_display/expression_display_bloc.dart';
import '../blocs/expression_display/expression_display_state.dart';
import '../theme/calculator_dimensions.dart';
import '../widgets/backspace_button.dart';
import '../widgets/calculator_button_grid.dart';
import '../widgets/calculator_toast.dart';

/// The main calculator screen widget.
///
/// This screen displays the calculator interface with an expression display
/// area, a backspace button, and a button grid. It uses [BlocListener] to
/// react to evaluation errors and display toast notifications without
/// rebuilding the widget tree.
///
/// The screen requires an [ExpressionDisplayBloc] to be provided in the
/// widget tree (typically via [CalculatorModule]).
class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: BlocListener<ExpressionDisplayBloc, ExpressionDisplayState>(
          listenWhen: (previous, current) {
            // Only listen when transitioning to an evaluation error state
            return !previous.isEvaluationError && current.isEvaluationError;
          },
          listener: (context, state) {
            // Show toast when evaluation error occurs
            if (state.isEvaluationError && state.evaluationError != null) {
              CalculatorToast.show(
                context,
                message: state.evaluationError!,
                type: ToastType.error,
              );
            }
          },
          child: Column(
            children: [
              // Expression display area
              Expanded(
                flex: 2,
                child: _ExpressionDisplay(),
              ),
              // Backspace button row - right-aligned above button grid
              const _BackspaceButtonRow(),
              // Button grid area
              Expanded(
                flex: 3,
                child: const CalculatorButtonGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget that displays the current expression and result.
///
/// Uses [BlocBuilder] to rebuild only when the expression or result changes.
class _ExpressionDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpressionDisplayBloc, ExpressionDisplayState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Expression text
              Text(
                state.displayExpression.isEmpty ? '0' : state.displayExpression,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              // Result text (if available)
              if (state.result != null)
                Text(
                  '= ${state.result}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget that displays the backspace button row above the button grid.
///
/// The backspace button is right-aligned to provide easy access for
/// deleting the last character in the expression.
class _BackspaceButtonRow extends StatelessWidget {
  const _BackspaceButtonRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CalculatorDimensions.backspaceRowHorizontalPadding,
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: CalculatorDimensions.backspaceButtonBottomSpacing,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            BackspaceButton(),
          ],
        ),
      ),
    );
  }
}
