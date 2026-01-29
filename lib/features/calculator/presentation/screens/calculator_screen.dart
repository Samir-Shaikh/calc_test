import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/expression_display/expression_display_bloc.dart';
import '../blocs/expression_display/expression_display_event.dart';
import '../blocs/expression_display/expression_display_state.dart';
import '../theme/calculator_dimensions.dart';
import '../widgets/backspace_button.dart';
import '../widgets/calculator_button_grid.dart';
import '../widgets/calculator_toast.dart';
import '../widgets/expression_display_widget.dart';

/// The main calculator screen widget.
///
/// This screen displays the calculator interface with an expression display
/// area, a backspace button, and a button grid. It uses [BlocListener] to
/// react to evaluation errors and display toast notifications without
/// rebuilding the widget tree.
///
/// The layout is composed of three main sections:
/// - Display area (approximately 30% of screen): Shows expression and result
/// - Backspace button row: End-aligned, positioned between display and grid
/// - Button grid (approximately 60% of screen): Contains all calculator buttons
///
/// ## RTL Support
///
/// This screen fully supports RTL (right-to-left) languages:
/// - Uses [EdgeInsetsDirectional] for directional-aware padding
/// - Uses [MainAxisAlignment.end] for backspace button positioning
/// - In LTR locales: backspace appears on the right
/// - In RTL locales: backspace automatically mirrors to the left
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
            // Only listen when showError transitions from false to true
            return !previous.showError && current.showError;
          },
          listener: (context, state) {
            // Show 'Invalid Input' toast when showError is true
            if (state.showError) {
              CalculatorToast.showInvalidInput(context);
              // Immediately dispatch ErrorAcknowledged to reset showError flag
              // and prevent repeated toast displays
              context.read<ExpressionDisplayBloc>().add(const ErrorAcknowledged());
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: CalculatorDimensions.screenHorizontalPadding,
              vertical: CalculatorDimensions.screenVerticalPadding,
            ),
            child: Column(
              children: [
                // Expression display area (approximately 30% of screen)
                const Expanded(
                  flex: CalculatorDimensions.displayAreaFlex,
                  child: ExpressionDisplayWidget(),
                ),
                // Backspace button row - positioned at the end (right in LTR, left in RTL)
                const _BackspaceButtonRow(),
                // Button grid area (approximately 60% of screen)
                Expanded(
                  flex: CalculatorDimensions.buttonGridFlex,
                  child: const CalculatorButtonGrid(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget that displays the backspace button row above the button grid.
///
/// The backspace button uses RTL-aware alignment (MainAxisAlignment.end)
/// to position at the end of the row. In LTR locales, this is the right side.
/// In RTL locales, this is the left side.
///
/// ## RTL Support
///
/// This widget uses [EdgeInsetsDirectional] instead of [EdgeInsets] to ensure
/// proper padding in both LTR and RTL layouts:
/// - [EdgeInsetsDirectional.start] maps to left in LTR, right in RTL
/// - [EdgeInsetsDirectional.end] maps to right in LTR, left in RTL
///
/// The [MainAxisAlignment.end] ensures the backspace button is positioned
/// at the logical end of the row, which automatically mirrors in RTL mode.
class _BackspaceButtonRow extends StatelessWidget {
  const _BackspaceButtonRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Use EdgeInsetsDirectional for RTL-aware horizontal padding
      padding: const EdgeInsetsDirectional.only(
        start: CalculatorDimensions.backspaceRowHorizontalPadding,
        end: CalculatorDimensions.backspaceRowHorizontalPadding,
        top: CalculatorDimensions.backspaceButtonTopSpacing,
        bottom: CalculatorDimensions.backspaceButtonBottomSpacing,
      ),
      child: const Row(
        // MainAxisAlignment.end positions the button at the logical end
        // (right in LTR, left in RTL)
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          BackspaceButton(),
        ],
      ),
    );
  }
}
