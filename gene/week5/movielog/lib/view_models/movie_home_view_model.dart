import 'package:flutter/foundation.dart';

import '../core/network/tmdb_error_message.dart';
import '../data/movies.dart';
import '../services/tmdb_movie_service.dart';

enum MovieHomeLoadStatus { idle, loading, success, empty, error }

class MovieHomeViewModel extends ChangeNotifier {
  MovieHomeViewModel(this._service);

  final TmdbMovieService _service;

  List<Movie> popularMovies = const [];
  MovieHomeLoadStatus status = MovieHomeLoadStatus.idle;
  String? message;

  bool _disposed = false;

  Future<void> loadPopular() async {
    // 이미 불러오는 중이면 같은 요청을 겹쳐 보내지 않습니다.
    if (status == MovieHomeLoadStatus.loading) return;

    status = MovieHomeLoadStatus.loading;
    message = null;
    _notify();

    try {
      final genres = await _service.fetchGenres();
      final page = await _service.fetchPopular();
      final genreNames = {for (final g in genres) g.id: g.name};

      popularMovies = [
        for (final dto in page.results.take(5)) dto.toMovie(genreNames),
      ];
      status = popularMovies.isEmpty
          ? MovieHomeLoadStatus.empty
          : MovieHomeLoadStatus.success;
    } catch (error) {
      // DioException 외의 오류(응답 파싱 실패 등)도 화면이 loading에 멈추지 않게 받습니다.
      status = MovieHomeLoadStatus.error;
      message = tmdbErrorMessage(error, fallback: '인기 영화를 불러오지 못했어요.');
    }

    _notify();
  }

  /// 응답이 오기 전에 화면을 떠나면 dispose된 뒤 notify하지 않도록 막습니다.
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
