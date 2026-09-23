import 'package:go_router/go_router.dart';

import '../data/mock_movies.dart';
import '../screens/home_screen.dart';
import '../screens/main_screen.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/profile_view.dart';
import '../screens/register_screen.dart';
import '../screens/start_screen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/start', builder: (context, state) => const StartScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/movies',
                builder: (context, state) {
                  final rawGenres = state.uri.queryParameters['genre'];
                  return MovieListScreen(
                    initialQuery: state.uri.queryParameters['q'] ?? '',
                    initialGenres: rawGenres == null || rawGenres.isEmpty
                        ? const <String>[]
                        : rawGenres.split(','),
                  );
                },
                routes: [
                  GoRoute(
                    path: ':movieId',
                    builder: (context, state) {
                      final id = int.tryParse(
                        state.pathParameters['movieId'] ?? '',
                      );
                      return MovieDetailScreen(movie: findMovieById(id));
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my',
                builder: (context, state) => const MyPageScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
