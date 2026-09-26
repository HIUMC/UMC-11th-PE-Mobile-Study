import 'package:go_router/go_router.dart';

import '../home_screen.dart';
import '../movie_detail_screen.dart';
import '../movies_screen.dart';
import '../my_screen.dart';
import '../signup_screen.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/movies',
        builder: (context, state) => const MoviesScreen(),
        routes: [
          GoRoute(
            path: ':movieId',
            builder: (context, state) =>
                MovieDetailScreen(movieId: state.pathParameters['movieId']!),
          ),
        ],
      ),
      GoRoute(path: '/my', builder: (context, state) => const MyScreen()),
    ],
  );
}
