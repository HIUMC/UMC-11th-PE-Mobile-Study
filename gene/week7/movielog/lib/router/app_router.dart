import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:movielog/data/movies.dart';
import 'package:movielog/screens/home_screen.dart';
import 'package:movielog/screens/movie_detail_screen.dart';
import 'package:movielog/screens/movie_list_screen.dart';
import 'package:movielog/screens/my_ratings_screen.dart';
import 'package:movielog/screens/my_screen.dart';
import 'package:movielog/data/services/sign_up_service.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/screens/signup_screen.dart';
import 'package:movielog/view_models/learning_member_session.dart';
import 'package:movielog/view_models/movie_detail_view_model.dart';
import 'package:movielog/view_models/movie_home_view_model.dart';
import 'package:movielog/view_models/movie_list_view_model.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';
import 'package:movielog/view_models/sign_up_view_models.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/signup',
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
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) =>
              SignUpViewModel(context.read<SignUpService>()),
          child: const SignupScreen(),
        ),
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
            builder: (context, state) {
              final rawId = state.pathParameters['movieId']!;
              final screen = MovieDetailScreen(
                movieId: rawId,
                // 목록에서 넘겨준 영화. 없으면(딥링크 등) 로컬 데이터에서 찾습니다.
                movie: state.extra is Movie ? state.extra as Movie : null,
              );
              final movieId = int.tryParse(rawId);
              // 숫자가 아닌 ID는 어차피 "영화를 찾을 수 없어요" 화면이 됩니다.
              if (movieId == null) return screen;
              // "평점 남기기"가 context.read<MovieDetailViewModel>()로 읽습니다.
              return ChangeNotifierProvider(
                create: (context) => MovieDetailViewModel(
                  context.read<RatingApiService>(),
                  context.read<LearningMemberSession>().memberId,
                  movieId,
                ),
                child: screen,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/my',
        builder: (context, state) => const MyScreen(),
        routes: [
          GoRoute(
            path: 'ratings', // 최종 경로: /my/ratings
            builder: (context, state) {
              // 회원가입에서 저장한 학습용 회원 ID를 씁니다.
              final id = context.read<LearningMemberSession>().memberId;
              if (id == null) {
                return Scaffold(
                  appBar: AppBar(
                    centerTitle: true,
                    title: const Text('내가 등록한 평점'),
                  ),
                  body: const Center(child: Text('학습용 회원가입이 필요합니다.')),
                );
              }
              return ChangeNotifierProvider(
                create: (context) => MyRatingsViewModel(
                  context.read<RatingApiService>(),
                  context.read<TmdbMovieService>(),
                  id,
                )..load(),
                child: const MyRatingsScreen(),
              );
            },
          ),
        ],
      ),
    ],
  );
}
