import 'package:dio/dio.dart';

import '../data/tmdb/tmdb_dto.dart';

/// TMDB API 호출만 담당합니다. 화면 상태는 ViewModel이 관리합니다.
///
/// 실패하면 [DioException]이 그대로 올라갑니다.
class TmdbMovieService {
  TmdbMovieService(this._dio);

  final Dio _dio;

  /// 장르 목록은 거의 바뀌지 않으므로 한 번 받은 결과를 재사용합니다.
  /// 실패하면 캐시를 비워 다음 호출 때 다시 요청합니다.
  Future<List<TmdbGenreDto>>? _genres;

  Future<List<TmdbGenreDto>> fetchGenres() {
    return _genres ??= _requestGenres().onError((error, stackTrace) {
      _genres = null;
      Error.throwWithStackTrace(error!, stackTrace);
    });
  }

  Future<List<TmdbGenreDto>> _requestGenres() async {
    final response = await _dio.get<Map<String, dynamic>>('/genre/movie/list');
    return [
      for (final item in response.data?['genres'] as List? ?? const [])
        TmdbGenreDto.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<TmdbPage<TmdbMovieDto>> fetchPopular({int page = 1}) {
    return _getMoviePage('/movie/popular', {'page': page});
  }

  /// [genreId]가 null이면 전체 장르의 인기순 목록을 받습니다.
  Future<TmdbPage<TmdbMovieDto>> discoverMovies({int? genreId, int page = 1}) {
    return _getMoviePage('/discover/movie', {
      'page': page,
      'sort_by': 'popularity.desc',
      'with_genres': ?genreId,
    });
  }

  Future<TmdbPage<TmdbMovieDto>> _getMoviePage(
    String path,
    Map<String, dynamic> query,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: query,
    );
    return TmdbPage.fromJson(response.data ?? const {}, TmdbMovieDto.fromJson);
  }

  void dispose() => _dio.close();
}
