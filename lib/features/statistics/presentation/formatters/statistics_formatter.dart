import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medtrack/core/theme/status_colors.dart';
import 'package:medtrack/features/statistics/domain/entities/adherence_rate.dart';
import 'package:medtrack/features/statistics/domain/entities/day_adherence.dart';
import 'package:medtrack/l10n/gen/app_localizations.dart';

/// Turns statistics values into localized text and status colors.
class StatisticsFormatter {
  StatisticsFormatter(this._l10n);

  final AppLocalizations _l10n;

  String get _locale => _l10n.localeName;

  String rate(AdherenceRate rate) {
    final value = rate.value;
    return value == null
        ? _l10n.statsNoData
        : NumberFormat.percentPattern(_locale).format(value);
  }

  String month(DateTime month) =>
      toBeginningOfSentenceCase(DateFormat.yMMMM(_locale).format(month));

  /// Short axis label, e.g. "6.10".
  String shortDate(DateTime date) => DateFormat.Md(_locale).format(date);

  String fullDate(DateTime date) => DateFormat.MMMMd(_locale).format(date);

  String dayStatus(DayStatus status) => switch (status) {
    DayStatus.allTaken => _l10n.dayStatusAllTaken,
    DayStatus.partial => _l10n.dayStatusPartial,
    DayStatus.missed => _l10n.dayStatusMissed,
    DayStatus.inProgress => _l10n.dayStatusInProgress,
    DayStatus.upcoming => _l10n.dayStatusUpcoming,
    DayStatus.noIntakes => _l10n.dayStatusNoIntakes,
  };

  /// Fill color of a calendar day, `null` for days without a result.
  static Color? dayColor(DayStatus status, StatusColors colors) =>
      switch (status) {
        DayStatus.allTaken => colors.success,
        DayStatus.partial => colors.warning,
        DayStatus.missed => colors.danger,
        DayStatus.inProgress ||
        DayStatus.upcoming ||
        DayStatus.noIntakes => null,
      };
}
