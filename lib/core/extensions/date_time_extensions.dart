extension DateOnly on DateTime {
  /// Local midnight of the same calendar day.
  DateTime get dateOnly => DateTime(year, month, day);
}
