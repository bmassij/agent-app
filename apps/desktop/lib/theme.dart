import 'package:flutter/material.dart';

abstract final class DesktopTheme {
  static const _bg = Color(0xFF0D0D0D);
  static const _card = Color(0xFF1A1A1A);
  static const _accent = Color(0xFF00B4D8);
  static const _text = Color(0xFFE8E8E8);
  static const _muted = Color(0xFF9E9E9E);

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _bg,
      colorScheme: const ColorScheme.dark(
        surface: _bg,
        primary: _accent,
        onPrimary: _bg,
        onSurface: _text,
        error: Color(0xFFFF6B6B),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _bg,
        foregroundColor: _text,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: _card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: _bg,
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: _text, fontSize: 15),
        bodySmall: TextStyle(color: _muted, fontSize: 13),
      ),
      dividerColor: const Color(0xFF2A2A2A),
    );
  }
}
