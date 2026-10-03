import 'package:flutter/material.dart';
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
    initialLocation: '/start',
    routes: [
      GoRoute(path: '/start', builder: (context, state) => const StartScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // [복습 · 탭 상태 유지] 각 탭의 Navigator를 보존해 이동 후에도 화면 상태 유지.
      // 디스크 저장은 아니므로 앱 종료 후 복원은 SharedPreferences가 별도로 담당.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) =>
                    const PopScope(canPop: false, child: HomeScreen()),
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
      GoRoute(
        path: '/movies/:movieId',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['movieId'] ?? '');
          return MovieDetailScreen(movie: findMovieById(id));
        },
      ),
    ],
  );
}
