import 'package:flutter/material.dart';
import '../features/auth/auth_gate.dart';
import 'routes.dart';
import 'theme.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      locale: const Locale('ar'),
      builder: (context, child) {
        final locale = Localizations.localeOf(context);

        return Directionality(
          textDirection: locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        );
      },
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],      theme: AppThemes.getTheme(currentTheme),
      home: const AuthGate(),
      routes: AppRoutes.routes(changeTheme, currentTheme),
    );
  }
}