import 'package:flutter/material.dart';

import '../features/college_selection/college_selection_screen.dart';
import '../features/specialization_selection/specialization_selection_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import 'theme.dart';

class AppRoutes {
  static const String phase0Home = '/';
  static const String collegeSelection = '/college-selection';
  static const String specializationSelection = '/specializations';
  static const String login = '/login';
  static const String register = '/register';

  static Map<String, WidgetBuilder> routes(
    void Function(AppThemePreset) onThemeChanged,
    AppThemePreset currentTheme,
  ) {
    return {

      collegeSelection: (_) => CollegeSelectionScreen(
            currentTheme: currentTheme,
            onThemeChanged: onThemeChanged,
          ),
      specializationSelection: (_) => const SpecializationSelectionScreen(),

      login: (_) => LoginScreen(),
      register: (_) => RegisterScreen(),
    };
  }
}
