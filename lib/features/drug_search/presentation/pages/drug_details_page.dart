import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medtrack/core/di/injection.dart';
import 'package:medtrack/core/error/failure_messages.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/core/router/app_routes.dart';
import 'package:medtrack/core/widgets/bottom_action_button.dart';
import 'package:medtrack/core/widgets/error_view.dart';
import 'package:medtrack/core/widgets/loading_view.dart';
import 'package:medtrack/core/widgets/medical_disclaimer.dart';
import 'package:medtrack/features/drug_search/domain/entities/drug_label.dart';
import 'package:medtrack/features/drug_search/presentation/cubit/drug_details_cubit.dart';
import 'package:medtrack/features/drug_search/presentation/widgets/expandable_text_section.dart';

class DrugDetailsPage extends StatelessWidget {
  /// Shows [initialLabel] right away when it was passed from the search,
  /// otherwise loads the label by [id] (e.g. after a deep link).
  const DrugDetailsPage({required this.id, this.initialLabel, super.key});

  final String id;
  final DrugLabel? initialLabel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<DrugDetailsCubit>();
        final label = initialLabel;
        if (label != null) {
          cubit.show(label);
        } else {
          unawaited(cubit.load(id));
        }
        return cubit;
      },
      child: DrugDetailsView(id: id),
    );
  }
}

class DrugDetailsView extends StatelessWidget {
  const DrugDetailsView({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<DrugDetailsCubit>().state;
    final label = switch (state) {
      DrugDetailsLoaded(:final label) => label,
      _ => null,
    };
    final name = label?.name;
    return Scaffold(
      appBar: AppBar(title: Text(name ?? l10n.drugDetailsTitle)),
      body: switch (state) {
        DrugDetailsLoading() => const LoadingView(),
        DrugDetailsError(:final failure) => ErrorView(
          message: failure.message(l10n),
          onRetry: () => context.read<DrugDetailsCubit>().load(id),
        ),
        DrugDetailsLoaded(:final label) => _DrugDetailsContent(label: label),
      },
      bottomNavigationBar: name == null
          ? null
          : BottomActionButton(
              label: l10n.addToMyMedications,
              onPressed: () =>
                  context.push(AppRoutes.medicationNewWithName(name)),
            ),
    );
  }
}

class _DrugDetailsContent extends StatelessWidget {
  const _DrugDetailsContent({required this.label});

  final DrugLabel label;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final sections = [
      (l10n.drugPurpose, label.purpose),
      (l10n.drugDosage, label.dosage),
      (l10n.drugWarnings, label.warnings),
      (l10n.drugSideEffects, label.sideEffects),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const MedicalDisclaimer(),
        const SizedBox(height: 16),
        if (label.genericName case final genericName?)
          Text(genericName, style: theme.textTheme.titleSmall),
        if (label.manufacturer case final manufacturer?)
          Text(manufacturer, style: theme.textTheme.bodySmall),
        for (final (title, text) in sections)
          if (text != null) ...[
            const SizedBox(height: 24),
            ExpandableTextSection(title: title, text: text),
          ],
        const SizedBox(height: 24),
        Text(l10n.drugSourceNote, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
