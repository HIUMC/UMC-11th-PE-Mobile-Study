import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/movies.dart';
import '../home_screen.dart';
import '../movie_detail_screen.dart';
import '../movie_list_screen.dart';
import '../my_screen.dart';
import '../services/tmdb_movie_service.dart';
import '../signup_screen.dart';
import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) =>
              MovieHomeViewModel(context.read<TmdbMovieService>())
                ..loadPopular(),
          child: const MovieHomeScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/movies',
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) =>
              MovieListViewModel(context.read<TmdbMovieService>())
                ..loadInitial(),
          child: const MovieListScreen(),
        ),
        routes: [
          GoRoute(
            path: ':movieId',
            builder: (context, state) => MovieDetailScreen(
              movieId: state.pathParameters['movieId']!,
              // 목록에서 넘겨준 영화. 없으면(딥링크 등) 로컬 데이터에서 찾습니다.
              movie: state.extra is Movie ? state.extra as Movie : null,
            ),
          ),
        ],
      ),
      GoRoute(path: '/my', builder: (context, state) => const MyScreen()),
    ],
  );
}
