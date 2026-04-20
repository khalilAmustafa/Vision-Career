import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_theme.dart';

class DarkTheme {
  static final ThemeData theme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColors.darkBackground,

    fontFamily: 'Cairo',

    // 🔥 Color scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
    ),

    // 🔤 Text
    textTheme: AppTextTheme.dark,

    // 🧱 Cards / surfaces
    cardColor: AppColors.darkSurface,

    // 📝 Input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurfaceSoft,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(
        color: AppColors.darkTextSecondary,
      ),
    ),

    // 🔘 Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),

    // 📏 Divider
    dividerColor: AppColors.dividerDark,

    // 🧭 AppBar (optional but good)
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.darkTextPrimary,
    ),
  );
}