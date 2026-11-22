import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // ChangeNotifier 사용 가능

import '../data/models/rating_with_movie.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';

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
  String? refreshWarning; // 저장은 됐는데 목록 재조회만 실패한 경우의 안내

  bool isEditing = false; // 다중 선택 모드
  final Set<int> selectedRatingIds = {}; // 선택한 ratingId. Set이라 같은 id가 두 번 들어가지 않음
  bool isDeletingSelected = false; // 다중 삭제 중이면 오버레이를 띄우고 이탈을 막음

  Future<void> load() async {
    final version = ++_requestVersion;
    status = MyRatingsLoadStatus.loading;
    message = null;
    refreshWarning = null; // 조회를 다시 시작하면 이전 재조회 실패 안내를 지움
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

  Future<void> _refreshAfterWrite() async { // 쓰기 성공 뒤 목록을 서버와 맞춤. 여기서 실패해도 저장 실패로 던지지 않음
    await load();
    if (_disposed) return;
    if (status == MyRatingsLoadStatus.error) {
      refreshWarning = '저장은 완료됐지만 목록을 불러오지 못했습니다. 조회만 다시 시도해 주세요.';
      notifyListeners();
    }
  }

  Future<void> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    try {
      await _service.updateRating(
        memberId: memberId,
        ratingId: ratingId,
        score: score,
        comment: comment, // Dialog가 기존 코멘트로 채워서 넘기므로 지우지 않는 한 유지됨
      );
    } on DioException catch (error) {
      if (shouldRefreshAfterRatingError(error)) await load(); // 403, 404면 목록을 서버 상태로 맞춤
      rethrow; // 쓰기 실패일 때만 Dialog가 실패로 처리
    }
    await _refreshAfterWrite();
  }

  Future<void> deleteRating(int ratingId) async {
    try {
      await _service.deleteRating(memberId: memberId, ratingId: ratingId);
    } on DioException catch (error) {
      if (shouldRefreshAfterRatingError(error)) await load();
      rethrow;
    }
    await _refreshAfterWrite(); // 마지막 항목을 지웠으면 여기서 Empty가 됨
  }

  void startEditing() {
    isEditing = true;
    notifyListeners();
  }

  void cancelEditing() { // 선택을 모두 풀고 기본 목록으로
    isEditing = false;
    selectedRatingIds.clear();
    notifyListeners();
  }

  void toggleSelection(int ratingId) {
    if (!selectedRatingIds.remove(ratingId)) selectedRatingIds.add(ratingId); // 이미 있으면 빼고 없으면 넣음
    notifyListeners();
  }

  Future<int> deleteSelectedRatings() async { // 실패한 개수를 돌려줌
    if (isDeletingSelected || selectedRatingIds.isEmpty) return 0;
    isDeletingSelected = true;
    notifyListeners();
    var failed = 0;
    try {
      for (final ratingId in selectedRatingIds.toList()) { // 원본 Set을 돌면서 지우면 에러라 복사본을 돎
        try {
          await _service.deleteRating(memberId: memberId, ratingId: ratingId);
          selectedRatingIds.remove(ratingId); // 성공한 것만 선택에서 뺌
        } on DioException {
          failed++; // 실패한 항목은 선택 상태로 남김
        }
      }
      if (_disposed) return failed;
      if (failed == 0) isEditing = false; // 전부 지웠으면 기본 목록으로
      await _refreshAfterWrite(); // 재조회 실패는 삭제 성공 여부와 따로 안내
    } finally {
      isDeletingSelected = false; // 예상하지 못한 오류에도 오버레이를 내림
      if (!_disposed) notifyListeners();
    }
    return failed;
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}