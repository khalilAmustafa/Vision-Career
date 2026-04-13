import 'package:flutter/material.dart';
import '../features/auth/auth_gate.dart';
import 'routes.dart';
import 'theme.dart';

class VisionCareerApp extends StatefulWidget {
  const VisionCareerApp({super.key});

  @override
  State<VisionCareerApp> createState() => _VisionCareerAppState();
}

class _VisionCareerAppState extends State<VisionCareerApp> {
  AppThemePreset currentTheme = AppThemePreset.dark;

  void changeTheme(AppThemePreset theme) {
    setState(() {
      currentTheme = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vision Career',
      theme: AppThemes.getTheme(currentTheme),
      home: const AuthGate(),
      routes: AppRoutes.routes(changeTheme, currentTheme),
    );
  }
}