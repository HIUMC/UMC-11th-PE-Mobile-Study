import 'package:flutter/foundation.dart';

// [복습 · ChangeNotifier] 즐겨찾기·평점 변경을 notifyListeners로 구독 위젯에 알림.
// 메모리 상태라 프로세스 종료 시 사라짐. 4주차 장르·정렬의 영구 저장과 구분.
class MovieStore extends ChangeNotifier {
  MovieStore._();

  static final MovieStore instance = MovieStore._();

  final Set<int> _favoriteIds = {};
  final Map<int, double> _userRatings = {};

  Set<int> get favoriteIds => Set.unmodifiable(_favoriteIds);
  Map<int, double> get userRatings => Map.unmodifiable(_userRatings);

  bool isFavorite(int movieId) => _favoriteIds.contains(movieId);
  double? ratingFor(int movieId) => _userRatings[movieId];

  void toggleFavorite(int movieId) {
    if (!_favoriteIds.add(movieId)) {
      _favoriteIds.remove(movieId);
    }
    notifyListeners();
  }

  void saveRating(int movieId, double rating) {
    _userRatings[movieId] = rating;
    notifyListeners();
  }
}
