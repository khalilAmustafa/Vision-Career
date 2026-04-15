import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/auth_gate.dart';
import 'routes.dart';

import '../l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class VisionCareerApp extends StatelessWidget {
  const VisionCareerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vision Career',

      // 🔹 CHANGE THIS LATER (for switching language)
      locale: const Locale('ar'),

      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,

      // 🔹 THIS is enough for RTL/LTR
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const AuthGate(),
      routes: AppRoutes.routes(),
    );
  }
}