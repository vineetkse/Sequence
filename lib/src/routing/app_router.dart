import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../screens/player/routine_player_screen.dart';
import '../screens/routines/routine_editor_screen.dart';
import '../screens/shell_screen.dart';

class AppRouter {
  static GoRouter build(BuildContext context) {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const ShellScreen(),
          routes: [
            GoRoute(
              path: 'routines/new',
              builder: (context, state) => const RoutineEditorScreen(),
            ),
            GoRoute(
              path: 'routines/:id/edit',
              builder: (context, state) =>
                  RoutineEditorScreen(routineId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: 'routines/:id/play',
              builder: (context, state) =>
                  RoutinePlayerScreen(routineId: state.pathParameters['id']!),
            ),
          ],
        ),
      ],
    );
  }
}

