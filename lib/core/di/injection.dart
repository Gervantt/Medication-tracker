import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:medtrack/core/database/app_database.dart';
import 'package:medtrack/core/router/app_router.dart';
import 'package:medtrack/features/diary/data/repositories/wellbeing_repository_impl.dart';
import 'package:medtrack/features/diary/domain/repositories/wellbeing_repository.dart';
import 'package:medtrack/features/intakes/data/repositories/intake_repository_impl.dart';
import 'package:medtrack/features/intakes/domain/repositories/intake_repository.dart';
import 'package:medtrack/features/medications/data/repositories/medication_repository_impl.dart';
import 'package:medtrack/features/medications/domain/repositories/medication_repository.dart';
import 'package:medtrack/features/medications/domain/usecases/add_medication.dart';
import 'package:medtrack/features/medications/domain/usecases/delete_medication.dart';
import 'package:medtrack/features/medications/domain/usecases/get_medication.dart';
import 'package:medtrack/features/medications/domain/usecases/update_medication.dart';
import 'package:medtrack/features/medications/domain/usecases/watch_medications.dart';

final GetIt getIt = GetIt.instance;

/// Registers app-wide dependencies. Each feature adds its own
/// registrations here as it is implemented.
void configureDependencies() {
  _registerCore();
  _registerMedications();
  _registerIntakes();
  _registerDiary();
}

void _registerCore() {
  getIt
    ..registerLazySingleton<GoRouter>(createAppRouter)
    ..registerLazySingleton<AppDatabase>(
      AppDatabase.new,
      dispose: (database) => database.close(),
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
    ..registerLazySingleton(() => DeleteMedication(getIt()));
}

void _registerIntakes() {
  getIt.registerLazySingleton<IntakeRepository>(
    () => IntakeRepositoryImpl(getIt<AppDatabase>().intakesDao),
  );
}

void _registerDiary() {
  getIt.registerLazySingleton<WellbeingRepository>(
    () => WellbeingRepositoryImpl(getIt<AppDatabase>().wellbeingDao),
  );
}
