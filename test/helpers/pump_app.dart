import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/l10n/gen/app_localizations.dart';

extension PumpApp on WidgetTester {
  /// Pumps [home] inside a localized MaterialApp.
  Future<void> pumpApp(Widget home) {
    return pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );
  }
}
