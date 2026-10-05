import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:medtrack/core/router/app_routes.dart';
import 'package:medtrack/core/widgets/home_shell.dart';
import 'package:medtrack/features/diary/presentation/pages/diary_page.dart';
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
                builder: (context, state) => const MedicationFormPage(),
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
          _branch(AppRoutes.diary, const DiaryPage()),
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
