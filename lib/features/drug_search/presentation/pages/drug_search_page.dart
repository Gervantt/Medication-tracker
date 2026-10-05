import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medtrack/core/di/injection.dart';
import 'package:medtrack/core/error/failure_messages.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/core/router/app_routes.dart';
import 'package:medtrack/core/widgets/empty_view.dart';
import 'package:medtrack/core/widgets/error_view.dart';
import 'package:medtrack/core/widgets/loading_view.dart';
import 'package:medtrack/features/drug_search/presentation/bloc/drug_search_bloc.dart';
import 'package:medtrack/features/drug_search/presentation/widgets/drug_result_tile.dart';

class DrugSearchPage extends StatelessWidget {
  const DrugSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DrugSearchBloc>(),
      child: const DrugSearchView(),
    );
  }
}

class DrugSearchView extends StatelessWidget {
  const DrugSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.drugSearchHint,
            border: InputBorder.none,
          ),
          onChanged: (query) =>
              context.read<DrugSearchBloc>().add(DrugSearchQueryChanged(query)),
        ),
      ),
      body: BlocBuilder<DrugSearchBloc, DrugSearchState>(
        builder: (context, state) => switch (state.status) {
          DrugSearchStatus.initial => EmptyView(
            icon: Icons.travel_explore,
            title: l10n.drugSearchTitle,
            message: l10n.drugSearchIntro,
          ),
          DrugSearchStatus.loading => const LoadingView(),
          DrugSearchStatus.failure => ErrorView(
            message: state.failure?.message(l10n),
            onRetry: () =>
                context.read<DrugSearchBloc>().add(const DrugSearchRetried()),
          ),
          DrugSearchStatus.success when state.results.isEmpty => EmptyView(
            icon: Icons.search_off,
            title: l10n.drugSearchEmptyTitle,
            message: l10n.drugSearchEmptyMessage,
          ),
          DrugSearchStatus.success => ListView.separated(
            itemCount: state.results.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final label = state.results[index];
              return DrugResultTile(
                label: label,
                onTap: () =>
                    context.push(AppRoutes.drugDetails(label.id), extra: label),
              );
            },
          ),
        },
      ),
    );
  }
}
