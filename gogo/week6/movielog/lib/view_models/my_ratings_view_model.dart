import 'package:flutter/foundation.dart';

import '../data/models/rating_dto.dart';
import '../data/services/week6_services.dart';

const sampleMemberId = 1;

enum MyRatingsLoadStatus { idle, loading, success, empty, error }

class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(this.service, this.movieService);
  final RatingApiService service;
  final TmdbMovieService movieService;
  final Map<int, MovieInfo?> _cache = {};
  List<RatingWithMovie> ratings = const [];
  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  String? message;
  int _version = 0;
  bool _disposed = false;

  Future<void> load() async {
    if (_disposed) return;
    final version = ++_version;
    bool current() => !_disposed && version == _version;
    status = MyRatingsLoadStatus.loading;
    message = null;
    notifyListeners();
    try {
      final raw = await service.fetchMyRatings(sampleMemberId);
      if (!current()) return;
      final entries = <RatingWithMovie>[];
      // Failed movies are also deduplicated within a load, but retried next load.
      final attempted = <int, MovieInfo?>{};
      for (final rating in raw) {
        if (!current()) return;
        final id = rating.movieId;
        if (!attempted.containsKey(id)) {
          if (_cache.containsKey(id)) {
            attempted[id] = _cache[id];
          } else {
            try {
              final movie = await movieService.findMovieById(id);
              if (!current()) return;
              _cache[id] = movie;
              attempted[id] = movie;
            } catch (_) {
              if (!current()) return;
              attempted[id] = null;
            }
          }
        }
        entries.add(RatingWithMovie(rating, attempted[id]));
      }
      if (!current()) return;
      ratings = entries;
      status = entries.isEmpty
          ? MyRatingsLoadStatus.empty
          : MyRatingsLoadStatus.success;
      if (entries.any((entry) => entry.movie == null)) {
        message = '일부 영화 정보를 가져오지 못했습니다. 평점 기록은 그대로 표시합니다.';
      }
    } catch (error) {
      if (!current()) return;
      ratings = const [];
      status = MyRatingsLoadStatus.error;
      message = ratingsErrorMessage(error);
    }
    if (current()) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _version++;
    super.dispose();
  }
}
