import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:medtrack/app/app.dart';
import 'package:medtrack/core/bloc/app_bloc_observer.dart';
import 'package:medtrack/core/di/injection.dart';
import 'package:medtrack/core/time/local_time_zone.dart';
import 'package:medtrack/features/reminders/data/local_notification_scheduler.dart';
import 'package:medtrack/features/reminders/data/notification_response_handler.dart';
import 'package:medtrack/features/reminders/domain/usecases/reminder_sync_trigger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const AppBlocObserver();
  await configureLocalTimeZone();
  // Reminder texts are formatted before MaterialApp loads its localizations.
  await initializeDateFormatting();
  await configureDependencies();
  await _startReminders();
  runApp(MedTrackApp(router: getIt<GoRouter>()));
}

Future<void> _startReminders() async {
  final scheduler = getIt<LocalNotificationScheduler>();
  await scheduler.initialize(
    onResponse: getIt<NotificationResponseHandler>().handle,
    onBackgroundResponse: handleBackgroundNotificationResponse,
  );
  final syncTrigger = getIt<ReminderSyncTrigger>()..start();
  // Lives as long as the app; the binding keeps a reference to it.
  AppLifecycleListener(onResume: syncTrigger.start);
}
