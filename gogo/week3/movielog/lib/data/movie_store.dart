import 'package:flutter/foundation.dart';

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
