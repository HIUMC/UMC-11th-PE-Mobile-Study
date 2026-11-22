import 'package:dio/dio.dart'; // DioException 사용 가능
import 'package:flutter/foundation.dart'; // ChangeNotifier 사용 가능

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';

enum MovieHomeLoadStatus { idle, loading, success, empty, error } // 홈 인기 영역이 가질 수 있는 상태 이름표. idle은 아직 시작 전

class MovieHomeViewModel extends ChangeNotifier { // 홈 화면 하나의 상태를 들고 있음. notifyListeners로 바뀐 걸 알림
  MovieHomeViewModel(this._service); // 공용 Service를 밖에서 받음
  final TmdbMovieService _service;

  List<TmdbMovieDto> popularMovies = const []; // 홈에 보여줄 인기 영화. 최대 5개
  MovieHomeLoadStatus status = MovieHomeLoadStatus.idle;
  String? message; // 오류일 때 화면에 보여줄 문구

  Future<void> loadPopular() async {
    status = MovieHomeLoadStatus.loading;
    notifyListeners(); // 로딩으로 바뀐 걸 알림. 구독 중인 화면이 로딩을 그림

    try {
      final page = await _service.fetchPopular(); // 인기 영화 1페이지
      popularMovies = page.results.take(5).toList(); // 앞에서부터 최대 5개. 결과가 적어도 범위 오류 없음
      status = popularMovies.isEmpty
          ? MovieHomeLoadStatus.empty
          : MovieHomeLoadStatus.success;
    } on DioException { // Service가 넘긴 요청 실패를 여기서 잡음
      status = MovieHomeLoadStatus.error;
      message = '인기 영화를 불러오지 못했어요.'; // 내부 오류 대신 사용자용 문구
    }

    notifyListeners(); // 결과가 정해졌으니 다시 알림
  }
}