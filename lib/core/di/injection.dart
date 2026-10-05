import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:medtrack/core/router/app_router.dart';

final GetIt getIt = GetIt.instance;

/// Registers app-wide dependencies. Each feature adds its own
/// registrations here as it is implemented.
void configureDependencies() {
  getIt.registerLazySingleton<GoRouter>(createAppRouter);
}
