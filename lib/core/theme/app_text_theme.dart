import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AppTextTheme {
  // ================= DARK =================
  static const dark = TextTheme(
    // Titles
    titleLarge: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: AppColors.darkTextPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
    ),

    // Body
    bodyLarge: TextStyle(
      fontSize: 16,
      color: AppColors.darkTextPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: AppColors.darkTextSecondary,
    ),

    // Small / labels
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      color: AppColors.darkTextSecondary,
    ),
  );

  // ================= LIGHT =================
  static const light = TextTheme(
    titleLarge: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: AppColors.lightTextPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextPrimary,
    ),

    bodyLarge: TextStyle(
      fontSize: 16,
      color: AppColors.lightTextPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: AppColors.lightTextSecondary,
    ),

    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextPrimary,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      color: AppColors.lightTextSecondary,
    ),
  );
}