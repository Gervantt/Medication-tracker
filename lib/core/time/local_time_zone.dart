import 'dart:developer';

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Loads the time zone database and sets `tz.local` to the device zone,
/// so scheduled notifications follow local wall-clock time across DST.
Future<void> configureLocalTimeZone() async {
  tz.initializeTimeZones();
  try {
    final timeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZone.identifier));
  } on Object catch (error, stackTrace) {
    // Falls back to UTC; reminders would be shifted, but the app still works.
    log(
      'Could not resolve local time zone',
      name: 'time',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
