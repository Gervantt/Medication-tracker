import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:medtrack/core/extensions/date_time_extensions.dart';
import 'package:medtrack/core/router/app_routes.dart';
import 'package:medtrack/core/widgets/home_shell.dart';
import 'package:medtrack/features/diary/presentation/pages/diary_page.dart';
import 'package:medtrack/features/diary/presentation/pages/wellbeing_entry_page.dart';
import 'package:medtrack/features/drug_search/domain/entities/drug_label.dart';
import 'package:medtrack/features/drug_search/presentation/pages/drug_details_page.dart';
import 'package:medtrack/features/drug_search/presentation/pages/drug_search_page.dart';
import 'package:medtrack/features/medications/presentation/pages/medication_form_page.dart';
import 'package:medtrack/features/medications/presentation/pages/medications_page.dart';
import 'package:medtrack/features/statistics/presentation/pages/statistics_page.dart';
import 'package:medtrack/features/today/presentation/pages/today_page.dart';

GoRouter createAppRouter() {
  // Routes attached to the root navigator are shown above the bottom bar.
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.today,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          _branch(AppRoutes.today, const TodayPage()),
          _branch(
            AppRoutes.medications,
            const MedicationsPage(),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => MedicationFormPage(
                  initialName: state.uri.queryParameters['name'],
                ),
              ),
              GoRoute(
                path: 'search',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const DrugSearchPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => DrugDetailsPage(
                      id: state.pathParameters['id']!,
                      // Present when opened from the search results.
                      initialLabel: state.extra as DrugLabel?,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: ':id/edit',
                parentNavigatorKey: rootNavigatorKey,
                redirect: (context, state) =>
                    _medicationId(state) == null ? AppRoutes.medications : null,
                builder: (context, state) =>
                    MedicationFormPage(medicationId: _medicationId(state)),
              ),
            ],
          ),
          _branch(
            AppRoutes.diary,
            const DiaryPage(),
            routes: [
              GoRoute(
                path: 'entry/:date',
                parentNavigatorKey: rootNavigatorKey,
                redirect: (context, state) =>
                    _diaryDate(state) == null ? AppRoutes.diary : null,
                builder: (context, state) =>
                    WellbeingEntryPage(date: _diaryDate(state)!),
              ),
            ],
          ),
          _branch(AppRoutes.statistics, const StatisticsPage()),
        ],
      ),
    ],
  );
}

StatefulShellBranch _branch(
  String path,
  Widget page, {
  List<RouteBase> routes = const [],
}) {
  return StatefulShellBranch(
    routes: [
      GoRoute(path: path, builder: (context, state) => page, routes: routes),
    ],
  );
}

int? _medicationId(GoRouterState state) =>
    int.tryParse(state.pathParameters['id'] ?? '');

/// Parses `yyyy-MM-dd`; future days cannot have diary entries.
DateTime? _diaryDate(GoRouterState state) {
  final date = DateTime.tryParse(state.pathParameters['date'] ?? '')?.dateOnly;
  if (date == null || date.isAfter(clock.now())) return null;
  return date;
}
