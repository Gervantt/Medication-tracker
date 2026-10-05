import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medtrack/core/di/injection.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/core/router/app_routes.dart';
import 'package:medtrack/core/widgets/empty_view.dart';
import 'package:medtrack/core/widgets/error_view.dart';
import 'package:medtrack/core/widgets/loading_view.dart';
import 'package:medtrack/features/medications/domain/entities/medication.dart';
import 'package:medtrack/features/medications/presentation/cubit/medications_list_cubit.dart';
import 'package:medtrack/features/medications/presentation/widgets/medication_list_tile.dart';

class MedicationsPage extends StatelessWidget {
  const MedicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MedicationsListCubit>()..subscribe(),
      child: const MedicationsView(),
    );
  }
}

class MedicationsView extends StatelessWidget {
  const MedicationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navMedications),
        actions: [
          IconButton(
            icon: const Icon(Icons.travel_explore),
            tooltip: l10n.drugSearchTitle,
            onPressed: () => context.push(AppRoutes.drugSearch),
          ),
        ],
      ),
      body: BlocBuilder<MedicationsListCubit, MedicationsListState>(
        builder: (context, state) => switch (state) {
          MedicationsListLoading() => const LoadingView(),
          MedicationsListError() => ErrorView(
            onRetry: context.read<MedicationsListCubit>().subscribe,
          ),
          MedicationsListLoaded(:final medications) when medications.isEmpty =>
            EmptyView(
              icon: Icons.medication_outlined,
              title: l10n.medicationsEmptyTitle,
              message: l10n.medicationsEmptyMessage,
            ),
          MedicationsListLoaded(:final medications) => _MedicationsList(
            medications: medications,
          ),
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.medicationNew),
        icon: const Icon(Icons.add),
        label: Text(l10n.addMedication),
      ),
    );
  }
}

class _MedicationsList extends StatelessWidget {
  const _MedicationsList({required this.medications});

  final List<Medication> medications;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: medications.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      // Bottom padding keeps the last item clear of the FAB.
      padding: const EdgeInsets.only(bottom: 88),
      itemBuilder: (context, index) {
        final medication = medications[index];
        return MedicationListTile(
          medication: medication,
          onTap: () => context.push(AppRoutes.medicationEdit(medication.id!)),
        );
      },
    );
  }
}
