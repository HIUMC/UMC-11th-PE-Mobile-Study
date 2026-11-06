import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // ChangeNotifier 사용 가능

import '../data/models/rating_with_movie.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';

const int sampleMemberId = 1; // 로그인한 내 계정이 아니라 학습용 공개 데이터의 회원 id

enum MyRatingsLoadStatus { idle, loading, success, empty, error }

class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(this._service, this._movieService, this.memberId);
  final RatingApiService _service;
  final TmdbMovieService _movieService;
  final int memberId;
  final Map<int, TmdbMovieDto?> _movieCache = {}; // 같은 movieId는 TMDB에 한 번만 물어봄. 없는 영화는 null로 기억
  int _requestVersion = 0; // 요청 번호표. 다르면 이전 요청의 응답이라 버림
  bool _disposed = false; // 화면을 나간 뒤 도착한 응답을 막음

  List<RatingWithMovie> ratings = const [];
  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  String? message; // Error 문구, 또는 일부 영화 정보를 못 가져왔다는 안내

  Future<void> load() async {
    final version = ++_requestVersion;
    status = MyRatingsLoadStatus.loading;
    message = null;
    notifyListeners();

    try {
      final rawRatings = await _service.fetchMyRatings(memberId);
      if (_disposed || version != _requestVersion) return;
      final entries = <RatingWithMovie>[];
      var missingMovies = 0;
      for (final rating in rawRatings) {
        if (_disposed || version != _requestVersion) return; // 영화를 하나씩 기다리는 사이에도 확인
        if (!_movieCache.containsKey(rating.movieId)) {
          try {
            _movieCache[rating.movieId] =
                await _movieService.findMovieById(rating.movieId);
          } on DioException {
            // 일시적인 네트워크 실패는 캐시하지 않음. 다음 로딩에서 다시 시도
          }
        }
        final movie = _movieCache[rating.movieId];
        if (movie == null) missingMovies++;
        entries.add(RatingWithMovie(rating: rating, movie: movie)); // 영화 정보가 없어도 평점은 남김
      }
      if (_disposed || version != _requestVersion) return;
      ratings = entries;
      status = entries.isEmpty // 빈 배열은 실패가 아니라 Empty
          ? MyRatingsLoadStatus.empty
          : MyRatingsLoadStatus.success;
      if (missingMovies > 0) {
        message = '일부 영화 정보를 가져오지 못해 제목, 포스터를 대신 표시합니다.';
      }
    } on DioException catch (error) { // 평점 조회 자체가 실패한 경우만 Error
      if (_disposed || version != _requestVersion) return;
      status = MyRatingsLoadStatus.error;
      message = writeMyRatingsErrorMessage(error);
    }
    if (!_disposed && version == _requestVersion) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}