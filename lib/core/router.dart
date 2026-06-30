import 'package:go_router/go_router.dart';

import '../features/resonator_list/screens/resonator_list_screen.dart';
import '../features/resonator_detail/screens/resonator_detail_screen.dart';
import '../features/compare/screens/echo_compare_screen.dart';
import '../features/settings/screens/settings_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ResonatorListScreen(),
      routes: [
        GoRoute(
          path: 'resonator/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ResonatorDetailScreen(resonatorId: id);
          },
          routes: [
            GoRoute(
              path: 'compare/:echoIndex',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                final echoIndex =
                    int.parse(state.pathParameters['echoIndex']!);
                return EchoCompareScreen(
                  resonatorId: id,
                  echoIndex: echoIndex,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
