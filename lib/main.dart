import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medtrack/app/app.dart';
import 'package:medtrack/core/bloc/app_bloc_observer.dart';
import 'package:medtrack/core/di/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const AppBlocObserver();
  configureDependencies();
  runApp(MedTrackApp(router: getIt<GoRouter>()));
}
