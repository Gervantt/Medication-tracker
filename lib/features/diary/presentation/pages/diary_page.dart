import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medtrack/core/di/injection.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/core/router/app_routes.dart';
import 'package:medtrack/core/widgets/empty_view.dart';
import 'package:medtrack/core/widgets/error_view.dart';
import 'package:medtrack/core/widgets/loading_view.dart';
import 'package:medtrack/features/diary/domain/entities/wellbeing_entry.dart';
import 'package:medtrack/features/diary/presentation/cubit/diary_cubit.dart';
import 'package:medtrack/features/diary/presentation/widgets/diary_entry_tile.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DiaryCubit>()..subscribe(),
      child: const DiaryView(),
    );
  }
}

class DiaryView extends StatelessWidget {
  const DiaryView({super.key});

  Future<void> _pickDay(BuildContext context) async {
    final today = clock.now();
    final date = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (date != null && context.mounted) {
      await context.push(AppRoutes.diaryEntry(date));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navDiary),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_calendar_outlined),
            tooltip: l10n.diaryPickDay,
            onPressed: () => _pickDay(context),
          ),
        ],
      ),
      body: BlocBuilder<DiaryCubit, DiaryState>(
        builder: (context, state) => switch (state) {
          DiaryLoading() => const LoadingView(),
          DiaryError() => ErrorView(
            onRetry: context.read<DiaryCubit>().subscribe,
          ),
          DiaryLoaded(:final entries) when entries.isEmpty => EmptyView(
            icon: Icons.book_outlined,
            title: l10n.diaryEmptyTitle,
            message: l10n.diaryEmptyMessage,
          ),
          DiaryLoaded(:final entries) => _DiaryList(entries: entries),
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        // Tabs stay alive in the shell, so every FAB needs its own tag.
        heroTag: AppRoutes.diary,
        onPressed: () => context.push(AppRoutes.diaryEntry(clock.now())),
        icon: const Icon(Icons.edit_outlined),
        label: Text(l10n.diaryTodayEntry),
      ),
    );
  }
}

class _DiaryList extends StatelessWidget {
  const _DiaryList({required this.entries});

  final List<WellbeingEntry> entries;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      // Bottom padding keeps the last item clear of the FAB.
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return DiaryEntryTile(
          entry: entry,
          onTap: () => context.push(AppRoutes.diaryEntry(entry.date)),
        );
      },
    );
  }
}
