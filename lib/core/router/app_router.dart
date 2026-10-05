import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:medtrack/core/router/app_routes.dart';
import 'package:medtrack/core/widgets/home_shell.dart';
import 'package:medtrack/features/diary/presentation/pages/diary_page.dart';
import 'package:medtrack/features/medications/presentation/pages/medications_page.dart';
import 'package:medtrack/features/statistics/presentation/pages/statistics_page.dart';
import 'package:medtrack/features/today/presentation/pages/today_page.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.today,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          _branch(AppRoutes.today, const TodayPage()),
          _branch(AppRoutes.medications, const MedicationsPage()),
          _branch(AppRoutes.diary, const DiaryPage()),
          _branch(AppRoutes.statistics, const StatisticsPage()),
        ],
      ),
    ],
  );
}

StatefulShellBranch _branch(String path, Widget page) {
  return StatefulShellBranch(
    routes: [GoRoute(path: path, builder: (context, state) => page)],
  );
}
