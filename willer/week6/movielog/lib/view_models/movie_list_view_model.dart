import 'package:dio/dio.dart'; // DioException 사용 가능
import 'package:flutter/foundation.dart'; // ChangeNotifier 사용 가능

import '../data/models/tmdb_genre_dto.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';

enum MovieListLoadStatus { idle, loading, success, empty, error } // 영화 목록 화면이 가질 수 있는 상태 이름표

class MovieListViewModel extends ChangeNotifier { // 영화 목록 화면 하나의 상태를 들고 있음
  MovieListViewModel(this._service); // 공용 Service를 밖에서 받음
  final TmdbMovieService _service;

  List<TmdbMovieDto> movies = const []; // 화면에 보여줄 영화. 최대 30개
  List<TmdbGenreDto> genres = const []; // 장르 Chip 목록. Genre API가 준 id와 name
  int? selectedGenreId; // 지금 고른 장르. null이면 전체
  MovieListLoadStatus status = MovieListLoadStatus.idle;
  String? message; // 오류일 때 화면에 보여줄 문구

  int _requestVersion = 0; // 요청 번호표. 늦게 온 이전 요청 결과를 버릴 때 씀
  bool _disposed = false; // 화면이 사라져 정리됐는지. 정리된 뒤 온 응답은 무시

  Future<List<TmdbMovieDto>> fetchUpToThirtyMovies({int? genreId}) async { // 30개가 차거나 더 이상 페이지가 없을 때까지 반복 요청
    final byId = <int, TmdbMovieDto>{}; // TMDB id를 key로 써서 페이지 사이 중복을 걸러냄
    var pageNumber = 1;
    var hasNextPage = true;

    while (byId.length < 30 && hasNextPage) { // 30개가 안 찼고 다음 페이지도 있을 때만 계속
      final page = await _service.discoverMovies(
        page: pageNumber,
        genreId: genreId,
      );

      for (final movie in page.results) {
        byId[movie.id] = movie; // 같은 id면 같은 칸에 덮어써서 개수가 안 늘어남
        if (byId.length == 30) break; // 30개가 차면 이 페이지에 영화가 남아도 그만 넣음
      }

      hasNextPage = pageNumber < page.totalPages && page.results.isNotEmpty; // 마지막 페이지거나 빈 페이지면 멈춤
      pageNumber++;
    }

    return byId.values.take(30).toList(); // Map은 넣은 순서를 기억해서 인기순 유지
  }

  Future<void> loadInitial() async { // 처음 들어왔을 때와 다시 시도할 때. 장르 목록과 전체 영화를 불러옴
    final version = ++_requestVersion; // 번호를 올리고 이 요청의 번호표로 챙김
    status = MovieListLoadStatus.loading;
    notifyListeners();

    try {
      genres = await _service.fetchGenres();
      final discovered = await fetchUpToThirtyMovies();

      if (_disposed || version != _requestVersion) return; // 정리됐거나 더 새 요청이 있으면 이 결과는 버림
      movies = discovered;
      status = movies.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
    } on DioException {
      if (_disposed || version != _requestVersion) return;
      status = MovieListLoadStatus.error;
      message = '영화를 불러오지 못했어요. 다시 시도해 주세요.';
    }

    if (!_disposed && version == _requestVersion) notifyListeners(); // 최신 요청일 때만 알림
  }

  Future<void> selectGenre(int? genreId) async { // 장르 Chip을 눌렀을 때. with_genres로 1페이지부터 다시 요청
    selectedGenreId = genreId;
    final version = ++_requestVersion;
    status = MovieListLoadStatus.loading;
    notifyListeners();

    try {
      final result = await fetchUpToThirtyMovies(genreId: genreId); // 받아온 목록을 거르는 게 아니라 다시 요청
      if (_disposed || version != _requestVersion) return;
      movies = result;
      status = result.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
    } on DioException {
      if (_disposed || version != _requestVersion) return;
      status = MovieListLoadStatus.error;
      message = '해당 장르 영화를 불러오지 못했어요.';
    }

    if (!_disposed && version == _requestVersion) notifyListeners();
  }

  @override
  void dispose() { // ChangeNotifierProvider가 화면이 사라질 때 불러줌
    _disposed = true;
    _requestVersion++; // 날아오던 응답의 번호표를 전부 무효로 만듦
    super.dispose();
  }
}