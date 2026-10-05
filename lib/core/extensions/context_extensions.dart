import 'package:flutter/widgets.dart';
import 'package:medtrack/l10n/gen/app_localizations.dart';

extension LocalizationContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
