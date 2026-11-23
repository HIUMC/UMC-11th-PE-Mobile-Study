import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // ChangeNotifier 사용 가능

import '../data/models/rating_request.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import 'signup_view_model.dart'; // SubmitStatus를 같이 씀

class MovieDetailViewModel extends ChangeNotifier { // 영화 상세의 영화 정보와 평점 등록 상태. 수정, 삭제는 마이페이지 몫
  MovieDetailViewModel(this._ratingService, this.memberId, this.movie);
  final RatingApiService _ratingService;
  final int? memberId; // 학습용 현재 회원. 가입 전이면 null. 로그인 인증은 아님
  final TmdbMovieDto movie;

  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitMessage; // 실패했을 때 서버 message
  bool _disposed = false; // 화면을 나간 뒤 도착한 응답을 막음

  Future<void> createRating({required int score, String? comment}) async {
    final id = memberId;
    if (id == null) { // 가입 전에는 요청을 보내지 않음
      submitStatus = SubmitStatus.error;
      submitMessage = '먼저 회원가입을 완료해 주세요.';
      notifyListeners();
      return;
    }
    if (submitStatus == SubmitStatus.submitting) return; // 연속 탭 방지

    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    notifyListeners();

    try {
      await _ratingService.createRating(
        memberId: id,
        request: CreateRatingRequest(
          movieId: movie.id, // TMDB 영화 id
          score: score,
          comment: comment,
        ),
      );
      if (_disposed) return;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      if (_disposed) return;
      submitStatus = SubmitStatus.error;
      submitMessage = writeErrorMessage(error); // code가 같아도 뜻이 달라서 서버 message를 그대로 씀
    }
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}