import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/expression_display/expression_display_bloc.dart';
import '../blocs/expression_display/expression_display_event.dart';
import '../theme/calculator_dimensions.dart';
import 'backspace_button_config.dart';

/// A standalone backspace button widget for the calculator.
///
/// This widget displays a delete icon button that removes the last character
/// from the current expression when tapped. It dispatches [BackspacePressed]
/// event to the [ExpressionDisplayBloc].
///
/// The button uses styling from [BackspaceButtonConfig] for consistent
/// appearance with other calculator buttons.
///
/// ## RTL Support
///
/// This button is designed to work correctly in both LTR and RTL layouts:
/// - The button itself is centered within its container (no directional bias)
/// - Parent widgets handle the positional alignment using [MainAxisAlignment.end]
/// - The backspace icon ([Icons.backspace_outlined]) is orientation-neutral
///   and works well in both LTR and RTL contexts
///
/// The positioning of this button in RTL mode is handled by the parent
/// [_BackspaceButtonRow] widget in [CalculatorScreen], which uses
/// [MainAxisAlignment.end] to place it at the logical end of the row.
///
/// Example usage:
/// ```dart
/// BackspaceButton()
/// ```
class BackspaceButton extends StatelessWidget {
  /// Creates a backspace button widget.
  const BackspaceButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onPressed(context),
      child: Container(
        width: CalculatorDimensions.backspaceButtonSize,
        height: CalculatorDimensions.backspaceButtonSize,
        decoration: BackspaceButtonConfig.decoration,
        // Center alignment is direction-neutral and works for both LTR and RTL
        child: Center(
          child: BackspaceButtonConfig.iconWidget,
        ),
      ),
    );
  }

  /// Handles the button press by dispatching [BackspacePressed] event.
  void _onPressed(BuildContext context) {
    context.read<ExpressionDisplayBloc>().add(const BackspacePressed());
  }
}
