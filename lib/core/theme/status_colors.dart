import 'package:flutter/material.dart';

/// Semantic colors that Material's ColorScheme does not provide,
/// with separate values for light and dark themes.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.success,
    required this.warning,
    required this.danger,
  });

  static const light = StatusColors(
    success: Color(0xFF2E7D32),
    warning: Color(0xFFF9A825),
    danger: Color(0xFFC62828),
  );

  static const dark = StatusColors(
    success: Color(0xFF81C784),
    warning: Color(0xFFFFD54F),
    danger: Color(0xFFE57373),
  );

  final Color success;
  final Color warning;
  final Color danger;

  static StatusColors of(BuildContext context) =>
      Theme.of(context).extension<StatusColors>()!;

  @override
  StatusColors copyWith({Color? success, Color? warning, Color? danger}) {
    return StatusColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  StatusColors lerp(StatusColors? other, double t) {
    if (other == null) return this;
    return StatusColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}
