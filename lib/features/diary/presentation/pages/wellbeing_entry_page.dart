import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medtrack/core/di/injection.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/core/widgets/bottom_action_button.dart';
import 'package:medtrack/core/widgets/error_view.dart';
import 'package:medtrack/core/widgets/loading_view.dart';
import 'package:medtrack/features/diary/presentation/cubit/wellbeing_form_cubit.dart';
import 'package:medtrack/features/diary/presentation/cubit/wellbeing_form_select.dart';
import 'package:medtrack/features/diary/presentation/formatters/diary_formatter.dart';
import 'package:medtrack/features/diary/presentation/widgets/delete_entry_button.dart';
import 'package:medtrack/features/diary/presentation/widgets/mood_selector.dart';
import 'package:medtrack/features/diary/presentation/widgets/symptoms_selector.dart';
import 'package:medtrack/features/diary/presentation/widgets/wellbeing_note_field.dart';

class WellbeingEntryPage extends StatelessWidget {
  const WellbeingEntryPage({required this.date, super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<WellbeingFormCubit>(param1: date);
        unawaited(cubit.load());
        return cubit;
      },
      child: const WellbeingEntryView(),
    );
  }
}

class WellbeingEntryView extends StatelessWidget {
  const WellbeingEntryView({super.key});

  void _onStatusChanged(BuildContext context, WellbeingFormState state) {
    switch (state.status) {
      case WellbeingFormStatus.saved || WellbeingFormStatus.deleted:
        context.pop();
      case WellbeingFormStatus.saveFailure:
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.saveFailed)));
      case _:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (date, status, isExisting, isSaving) = context.selectEntry(
      (state) => (state.date, state.status, state.isExisting, state.isSaving),
    );
    final showForm =
        status != WellbeingFormStatus.loading &&
        status != WellbeingFormStatus.loadFailure;
    return BlocListener<WellbeingFormCubit, WellbeingFormState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onStatusChanged,
      child: Scaffold(
        appBar: AppBar(
          title: Text(DiaryFormatter(l10n).day(date, today: clock.now())),
          actions: [if (isExisting && showForm) const DeleteEntryButton()],
        ),
        body: switch (status) {
          WellbeingFormStatus.loading => const LoadingView(),
          WellbeingFormStatus.loadFailure => ErrorView(
            onRetry: context.read<WellbeingFormCubit>().load,
          ),
          _ => const _WellbeingForm(),
        },
        bottomNavigationBar: showForm
            ? BottomActionButton(
                label: l10n.save,
                isLoading: isSaving,
                onPressed: () => context.read<WellbeingFormCubit>().submit(),
              )
            : null,
      ),
    );
  }
}

class _WellbeingForm extends StatelessWidget {
  const _WellbeingForm();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 24,
        children: [MoodSelector(), SymptomsSelector(), WellbeingNoteField()],
      ),
    );
  }
}
