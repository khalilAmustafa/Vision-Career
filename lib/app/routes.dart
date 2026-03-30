import 'package:flutter/material.dart';

import '../features/college_selection/college_selection_screen.dart';
import '../features/phase0/phase0_home_screen.dart';
import '../features/specialization_selection/specialization_selection_screen.dart';
import 'theme.dart';

class AppRoutes {
  static const String phase0Home = '/';
  static const String collegeSelection = '/college-selection';
  static const String specializationSelection = '/specializations';

  static Map<String, WidgetBuilder> routes(
    void Function(AppThemePreset) onThemeChanged,
    AppThemePreset currentTheme,
  ) {
    return {
      phase0Home: (_) => const Phase0HomeScreen(),
      collegeSelection: (_) => CollegeSelectionScreen(
            currentTheme: currentTheme,
            onThemeChanged: onThemeChanged,
          ),
      specializationSelection: (_) => const SpecializationSelectionScreen(),
    };
  }
}
