import 'package:flutter/material.dart';
import 'package:medtrack/core/theme/status_colors.dart';

abstract final class AppTheme {
  static const _seedColor = Color(0xFF00897B);

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(centerTitle: true),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      extensions: [
        if (brightness == Brightness.dark)
          StatusColors.dark
        else
          StatusColors.light,
      ],
    );
  }
}
