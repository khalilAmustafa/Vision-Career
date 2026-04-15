import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_theme.dart';

class LightTheme {
  static final ThemeData theme = ThemeData(
    brightness: Brightness.light,

    scaffoldBackgroundColor: AppColors.lightBackground,

    fontFamily: 'Cairo',

    // 🔥 Color scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
    ),

    // 🔤 Text
    textTheme: AppTextTheme.light,

    // 🧱 Cards / surfaces
    cardColor: AppColors.lightSurface,

    // 📝 Input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(
        color: AppColors.lightTextSecondary,
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
    dividerColor: AppColors.dividerLight,

    // 🧭 AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.lightTextPrimary,
    ),
  );
}