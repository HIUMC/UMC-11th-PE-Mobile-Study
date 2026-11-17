import 'package:flutter/material.dart';
import 'package:movielog/core/network/movie_log_client.dart';
import 'package:movielog/view_models/learning_member_session.dart';
import 'package:provider/provider.dart';

import 'package:movielog/core/network/tmdb_client.dart';
import 'package:movielog/router/app_router.dart';
import 'package:movielog/data/services/sign_up_service.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/theme/app_theme.dart';

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final movieLogClient = createMovieLogClient();

    return MultiProvider(
      providers: [
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(createTmdbClient()),
        ),
        Provider<RatingApiService>(
          create: (_) => RatingApiService(movieLogClient),
        ),
        Provider<SignUpService>(
          create: (_) => SignUpService(movieLogClient),
        ),
        // 회원가입 성공 시 SignUpViewModel.createdMemberId를 여기에 저장합니다.
        ChangeNotifierProvider<LearningMemberSession>(
          create: (_) => LearningMemberSession(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'MovieLog',
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}


