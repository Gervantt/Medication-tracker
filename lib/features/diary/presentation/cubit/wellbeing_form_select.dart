import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/features/diary/presentation/cubit/wellbeing_form_cubit.dart';

extension WellbeingFormSelect on BuildContext {
  /// Rebuilds the calling widget only when the selected value changes.
  T selectEntry<T>(T Function(WellbeingFormState state) selector) =>
      select<WellbeingFormCubit, T>((cubit) => selector(cubit.state));
}
