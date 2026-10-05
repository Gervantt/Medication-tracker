extension DateOnly on DateTime {
  /// Local midnight of the same calendar day.
  DateTime get dateOnly => DateTime(year, month, day);
}

extension IsoDate on DateTime {
  /// `yyyy-MM-dd`, e.g. for route parameters.
  String get isoDate =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}
