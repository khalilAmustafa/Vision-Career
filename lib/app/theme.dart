import 'package:flutter/material.dart';

enum AppThemePreset { light, dark, neon, fantasy }

class AppThemes {
  static ThemeData getTheme(AppThemePreset preset) {
    switch (preset) {
      case AppThemePreset.light:
        return ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF5F7FB),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF3B82F6),
            secondary: Color(0xFF8B5CF6),
          ),
          cardColor: Colors.white,
          useMaterial3: true,
        );

      case AppThemePreset.dark:
        return ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0B1020),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF7C3AED),
            secondary: Color(0xFF22D3EE),
          ),
          cardColor: const Color(0xFF151B2E),
          useMaterial3: true,
        );

      case AppThemePreset.neon:
        return ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF050816),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00F5D4),
            secondary: Color(0xFFFF00E5),
          ),
          cardColor: const Color(0xFF10162B),
          useMaterial3: true,
        );

      case AppThemePreset.fantasy:
        return ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF120B1F),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFE9C46A),
            secondary: Color(0xFF9D4EDD),
          ),
          cardColor: const Color(0xFF211233),
          useMaterial3: true,
        );
    }
  }

  static LinearGradient backgroundGradient(AppThemePreset theme) {
    switch (theme) {
      case AppThemePreset.light:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFE0EAFF),
            Color(0xFFF5F3FF),
          ],
        );
      case AppThemePreset.dark:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B1020),
            Color(0xFF121A30),
            Color(0xFF191335),
          ],
        );
      case AppThemePreset.neon:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF050816),
            Color(0xFF0A1030),
            Color(0xFF160029),
          ],
        );
      case AppThemePreset.fantasy:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF120B1F),
            Color(0xFF1B1231),
            Color(0xFF2E1A47),
          ],
        );
    }
  }
}