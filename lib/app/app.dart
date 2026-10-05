import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medtrack/core/theme/app_theme.dart';
import 'package:medtrack/l10n/gen/app_localizations.dart';

class MedTrackApp extends StatelessWidget {
  const MedTrackApp({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
