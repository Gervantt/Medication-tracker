import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

/// Central place where errors reported via `addError` from any bloc end up.
/// A crash reporter (e.g. Crashlytics) would be plugged in here.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log(
      'Error in ${bloc.runtimeType}',
      name: 'bloc',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}
