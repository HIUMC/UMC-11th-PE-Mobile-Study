import 'package:flutter/foundation.dart';

/// 내가 남긴 평점 (영화 id → 점수, 앱 실행 중에만 유지)
final myRatings = ValueNotifier<Map<String, double>>({});

double? myRatingOf(String movieId) => myRatings.value[movieId];

void saveMyRating(String movieId, double rating) {
  myRatings.value = {...myRatings.value, movieId: rating};
}
