import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:movielog/data/models/rating_request.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/view_models/sign_up_view_models.dart';

/// 영화 상세 화면의 평점 등록을 담당합니다.
class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(this._ratingService, this.memberId, this.movieId);
  final RatingApiService _ratingService;
  final int? memberId; // 학습용 현재 회원. 로그인 인증은 아닙니다.
  final int movieId; // TMDB 영화 ID
  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitMessage;
  bool _disposed = false;

  /// 실패하면 예외를 다시 던져 RatingDialog가 열린 채로 에러를 보여주게 합니다.
  Future<void> createRating({required int score, String? comment}) async {
    final id = memberId;
    if (id == null) {
      submitStatus = SubmitStatus.error;
      submitMessage = '먼저 회원가입을 완료해 주세요.';
      notifyListeners();
      throw StateError(submitMessage!);
    }
    if (submitStatus == SubmitStatus.submitting) return;
    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    notifyListeners();
    try {
      await _ratingService.createRating(
        memberId: id,
        request: CreateRatingRequest(
          movieId: movieId,
          score: score,
          comment: comment,
        ),
      );
      if (_disposed) return;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      if (!_disposed) {
        submitStatus = SubmitStatus.error;
        submitMessage = writeErrorMessage(error);
        notifyListeners();
      }
      rethrow;
    }
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
