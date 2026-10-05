import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medtrack/core/di/injection.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/core/widgets/error_view.dart';
import 'package:medtrack/core/widgets/loading_view.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_cubit.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_select.dart';
import 'package:medtrack/features/medications/presentation/widgets/delete_medication_button.dart';
import 'package:medtrack/features/medications/presentation/widgets/form/course_dates_section.dart';
import 'package:medtrack/features/medications/presentation/widgets/form/dosage_fields.dart';
import 'package:medtrack/features/medications/presentation/widgets/form/intake_times_section.dart';
import 'package:medtrack/features/medications/presentation/widgets/form/label_color_selector.dart';
import 'package:medtrack/features/medications/presentation/widgets/form/medication_form_selector.dart';
import 'package:medtrack/features/medications/presentation/widgets/form/name_field.dart';
import 'package:medtrack/features/medications/presentation/widgets/form/note_field.dart';
import 'package:medtrack/features/medications/presentation/widgets/form/save_button.dart';
import 'package:medtrack/features/medications/presentation/widgets/form/weekdays_section.dart';

class MedicationFormPage extends StatelessWidget {
  /// Opens an empty form, or loads the medication when [medicationId] is set.
  /// [initialName] prefills a new medication, e.g. from the drug search.
  const MedicationFormPage({this.medicationId, this.initialName, super.key});

  final int? medicationId;
  final String? initialName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<MedicationFormCubit>();
        final id = medicationId;
        final name = initialName;
        if (id != null) {
          unawaited(cubit.load(id));
        } else if (name != null) {
          cubit.nameChanged(name);
        }
        return cubit;
      },
      child: const MedicationFormView(),
    );
  }
}

class MedicationFormView extends StatelessWidget {
  const MedicationFormView({super.key});

  void _onStatusChanged(BuildContext context, MedicationFormState state) {
    switch (state.status) {
      case MedicationFormStatus.saved || MedicationFormStatus.deleted:
        context.pop();
      case MedicationFormStatus.saveFailure:
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.saveFailed)));
      case _:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (status, isEditing) = context.selectForm(
      (state) => (state.status, state.isEditing),
    );
    final showForm =
        status != MedicationFormStatus.loading &&
        status != MedicationFormStatus.loadFailure;
    return BlocListener<MedicationFormCubit, MedicationFormState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onStatusChanged,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEditing ? l10n.editMedicationTitle : l10n.newMedicationTitle,
          ),
          actions: [if (isEditing && showForm) const DeleteMedicationButton()],
        ),
        body: switch (status) {
          MedicationFormStatus.loading => const LoadingView(),
          MedicationFormStatus.loadFailure => ErrorView(
            message: l10n.medicationNotFound,
          ),
          _ => const _MedicationFormBody(),
        },
        bottomNavigationBar: showForm ? const SaveButton() : null,
      ),
    );
  }
}

class _MedicationFormBody extends StatelessWidget {
  const _MedicationFormBody();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 24,
        children: [
          NameField(),
          DosageFields(),
          MedicationFormSelector(),
          IntakeTimesSection(),
          WeekdaysSection(),
          CourseDatesSection(),
          LabelColorSelector(),
          NoteField(),
        ],
      ),
    );
  }
}
