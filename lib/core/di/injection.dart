import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:medtrack/core/database/app_database.dart';
import 'package:medtrack/core/router/app_router.dart';
import 'package:medtrack/features/diary/data/repositories/wellbeing_repository_impl.dart';
import 'package:medtrack/features/diary/domain/repositories/wellbeing_repository.dart';
import 'package:medtrack/features/diary/domain/usecases/delete_wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/usecases/get_wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/usecases/save_wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/usecases/watch_diary_entries.dart';
import 'package:medtrack/features/diary/presentation/cubit/diary_cubit.dart';
import 'package:medtrack/features/diary/presentation/cubit/wellbeing_form_cubit.dart';
import 'package:medtrack/features/intakes/data/repositories/intake_repository_impl.dart';
import 'package:medtrack/features/intakes/domain/repositories/intake_repository.dart';
import 'package:medtrack/features/intakes/domain/usecases/clear_intake_mark.dart';
import 'package:medtrack/features/intakes/domain/usecases/mark_intake.dart';
import 'package:medtrack/features/medications/data/repositories/medication_repository_impl.dart';
import 'package:medtrack/features/medications/domain/repositories/medication_repository.dart';
import 'package:medtrack/features/medications/domain/usecases/add_medication.dart';
import 'package:medtrack/features/medications/domain/usecases/delete_medication.dart';
import 'package:medtrack/features/medications/domain/usecases/get_medication.dart';
import 'package:medtrack/features/medications/domain/usecases/update_medication.dart';
import 'package:medtrack/features/medications/domain/usecases/watch_medications.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_cubit.dart';
import 'package:medtrack/features/medications/presentation/cubit/medications_list_cubit.dart';
import 'package:medtrack/features/reminders/data/local_notification_scheduler.dart';
import 'package:medtrack/features/reminders/data/notification_response_handler.dart';
import 'package:medtrack/features/reminders/domain/repositories/reminder_scheduler.dart';
import 'package:medtrack/features/reminders/domain/usecases/reminder_sync_trigger.dart';
import 'package:medtrack/features/reminders/domain/usecases/sync_reminders.dart';
import 'package:medtrack/features/statistics/domain/usecases/watch_statistics.dart';
import 'package:medtrack/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:medtrack/features/today/domain/usecases/watch_day_intakes.dart';
import 'package:medtrack/features/today/presentation/cubit/today_cubit.dart';
import 'package:medtrack/l10n/gen/app_localizations.dart';

final GetIt getIt = GetIt.instance;

/// Registers app-wide dependencies. Each feature adds its own
/// registrations here as it is implemented.
void configureDependencies() {
  _registerCore();
  _registerMedications();
  _registerIntakes();
  _registerDiary();
  _registerToday();
  _registerReminders();
  _registerStatistics();
}

void _registerCore() {
  getIt
    ..registerLazySingleton<GoRouter>(createAppRouter)
    ..registerLazySingleton<AppDatabase>(
      AppDatabase.new,
      dispose: (database) => database.close(),
    )
    // Localized strings for code outside the widget tree (notifications).
    ..registerLazySingleton<AppLocalizations>(
      () => lookupAppLocalizations(
        basicLocaleListResolution(
          WidgetsBinding.instance.platformDispatcher.locales,
          AppLocalizations.supportedLocales,
        ),
      ),
    );
}

void _registerMedications() {
  getIt
    ..registerLazySingleton<MedicationRepository>(
      () => MedicationRepositoryImpl(getIt<AppDatabase>().medicationsDao),
    )
    ..registerLazySingleton(() => WatchMedications(getIt()))
    ..registerLazySingleton(() => GetMedication(getIt()))
    ..registerLazySingleton(() => AddMedication(getIt()))
    ..registerLazySingleton(() => UpdateMedication(getIt()))
    ..registerLazySingleton(() => DeleteMedication(getIt()))
    ..registerFactory(() => MedicationsListCubit(getIt()))
    ..registerFactory(
      () => MedicationFormCubit(
        getMedication: getIt(),
        addMedication: getIt(),
        updateMedication: getIt(),
        deleteMedication: getIt(),
      ),
    );
}

void _registerIntakes() {
  getIt
    ..registerLazySingleton<IntakeRepository>(
      () => IntakeRepositoryImpl(getIt<AppDatabase>().intakesDao),
    )
    ..registerLazySingleton(() => MarkIntake(getIt()))
    ..registerLazySingleton(() => ClearIntakeMark(getIt()));
}

void _registerDiary() {
  getIt
    ..registerLazySingleton<WellbeingRepository>(
      () => WellbeingRepositoryImpl(getIt<AppDatabase>().wellbeingDao),
    )
    ..registerLazySingleton(() => WatchDiaryEntries(getIt()))
    ..registerLazySingleton(() => GetWellbeingEntry(getIt()))
    ..registerLazySingleton(() => SaveWellbeingEntry(getIt()))
    ..registerLazySingleton(() => DeleteWellbeingEntry(getIt()))
    ..registerFactory(() => DiaryCubit(getIt()))
    // The edited day is a runtime argument, hence a factory with a param.
    ..registerFactoryParam<WellbeingFormCubit, DateTime, void>(
      (date, _) => WellbeingFormCubit(
        date: date,
        getEntry: getIt(),
        saveEntry: getIt(),
        deleteEntry: getIt(),
      ),
    );
}

void _registerToday() {
  getIt
    ..registerLazySingleton(() => WatchDayIntakes(getIt(), getIt()))
    ..registerFactory(
      () => TodayCubit(
        watchDayIntakes: getIt(),
        markIntake: getIt(),
        clearIntakeMark: getIt(),
      ),
    );
}

void _registerReminders() {
  getIt
    ..registerLazySingleton(FlutterLocalNotificationsPlugin.new)
    ..registerLazySingleton(() => LocalNotificationScheduler(getIt(), getIt()))
    // Same instance behind the domain interface.
    ..registerLazySingleton<ReminderScheduler>(
      getIt.get<LocalNotificationScheduler>,
    )
    ..registerLazySingleton(() => SyncReminders(getIt(), getIt(), getIt()))
    ..registerLazySingleton(
      () => ReminderSyncTrigger(getIt(), getIt(), getIt()),
    )
    ..registerLazySingleton(
      () => NotificationResponseHandler(getIt(), getIt()),
    );
}

void _registerStatistics() {
  getIt
    ..registerLazySingleton(() => WatchStatistics(getIt(), getIt(), getIt()))
    ..registerFactory(() => StatisticsCubit(getIt()));
}
