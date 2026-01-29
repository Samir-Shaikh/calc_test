import 'package:flutter/material.dart';

/// Extension on [BuildContext] for directionality utilities.
///
/// Provides convenient methods to check and work with text directionality
/// (LTR/RTL) in the current context.
extension DirectionalityExtension on BuildContext {
  /// Returns `true` if the current text direction is right-to-left (RTL).
  ///
  /// This is useful for conditionally applying different layouts or styles
  /// based on the text direction. For example:
  /// ```dart
  /// if (context.isRtl) {
  ///   // Apply RTL-specific layout
  /// }
  /// ```
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  /// Returns `true` if the current text direction is left-to-right (LTR).
  ///
  /// This is the inverse of [isRtl] and is useful when you need to explicitly
  /// check for LTR direction.
  bool get isLtr => Directionality.of(this) == TextDirection.ltr;

  /// Returns the current text direction.
  ///
  /// Convenience accessor for [Directionality.of(this)].
  TextDirection get textDirection => Directionality.of(this);

  /// Returns [TextAlign.end] for directional alignment.
  ///
  /// Use this instead of [TextAlign.right] to ensure proper alignment
  /// in both LTR and RTL contexts:
  /// - In LTR: aligns to the right
  /// - In RTL: aligns to the left
  TextAlign get endAlign => TextAlign.end;

  /// Returns [TextAlign.start] for directional alignment.
  ///
  /// Use this instead of [TextAlign.left] to ensure proper alignment
  /// in both LTR and RTL contexts:
  /// - In LTR: aligns to the left
  /// - In RTL: aligns to the right
  TextAlign get startAlign => TextAlign.start;
}
