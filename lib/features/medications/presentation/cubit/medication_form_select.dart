import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_cubit.dart';

extension MedicationFormSelect on BuildContext {
  /// Rebuilds the calling widget only when the selected value changes.
  T selectForm<T>(T Function(MedicationFormState state) selector) =>
      select<MedicationFormCubit, T>((cubit) => selector(cubit.state));
}
