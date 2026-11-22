import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ChangeNotifierProvider, context.read 사용 가능

import 'data/models/tmdb_movie_dto.dart';
import 'data/services/rating_api_service.dart';
import 'data/services/tmdb_movie_service.dart';
import 'movie_detail_screen.dart';
import 'view_models/learning_member_session.dart';
import 'view_models/movie_detail_view_model.dart';

class MovieDetailLoader extends StatefulWidget { // 상세 화면의 시작점. extra가 없으면 TMDB에서 영화를 다시 불러옴
  const MovieDetailLoader({super.key, required this.movieId, this.initialMovie});

  final int movieId;
  final TmdbMovieDto? initialMovie; // 목록에서 넘긴 영화. 주소로만 들어오면 null

  @override
  State<MovieDetailLoader> createState() => _MovieDetailLoaderState();
}

class _MovieDetailLoaderState extends State<MovieDetailLoader> {
  late final Future<TmdbMovieDto> _movieFuture; // build마다 새 요청을 만들지 않게 한 번만 만듦

  @override
  void initState() {
    super.initState();
    _movieFuture = widget.initialMovie != null
        ? Future.value(widget.initialMovie!) // 이미 있으면 요청 없이 바로 씀
        : context.read<TmdbMovieService>().fetchMovieDetail(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TmdbMovieDto>(
      future: _movieFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Scaffold(body: Center(child: Text('영화를 불러오지 못했습니다.')));
        }
        return ChangeNotifierProvider<MovieDetailViewModel>( // 영화가 준비된 뒤에 ViewModel을 만듦
          create: (context) => MovieDetailViewModel(
            context.read<RatingApiService>(),
            context.read<LearningMemberSession>().memberId, // 고정 1이 아니라 가입 결과 id
            snapshot.data!,
          ),
          child: const MovieDetailScreen(),
        );
      },
    );
  }
}