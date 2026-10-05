import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medtrack/app/app.dart';
import 'package:medtrack/core/di/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(MedTrackApp(router: getIt<GoRouter>()));
}
