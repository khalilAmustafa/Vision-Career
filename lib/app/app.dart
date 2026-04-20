import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/auth_gate.dart';
import '../core/services/settings_service.dart';
import 'routes.dart';

import '../l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class VisionCareerApp extends StatelessWidget {
  final SettingsService settingsService;

  const VisionCareerApp({super.key, required this.settingsService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsService,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Vision Career',
          locale: settingsService.locale,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settingsService.themeMode,
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
      },
    );
  }
}
