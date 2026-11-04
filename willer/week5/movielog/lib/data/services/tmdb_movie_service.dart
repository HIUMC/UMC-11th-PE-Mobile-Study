import 'package:dio/dio.dart';

import '../models/tmdb_genre_dto.dart';
import '../models/tmdb_movie_page.dart';

class TmdbMovieService { // TMDB와 통신하고 JSON을 DTO로 바꾸는 역할만 함. 상태와 화면 정책은 없음
  TmdbMovieService(this._dio); // 설정이 끝난 Dio Client를 밖에서 받음
  final Dio _dio; // _라서 이 파일 밖에서는 직접 못 씀

  Future<TmdbMoviePageDto> fetchPopular({int page = 1}) async { // 인기 영화 한 페이지. 안 넘기면 1페이지
    final response = await _dio.get(
      '/movie/popular', // baseUrl 뒤에 붙는 뒷주소
      queryParameters: {'language': 'ko-KR', 'page': page}, // Dio가 ?language=..&page=..로 붙여줌
    );
    return TmdbMoviePageDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<TmdbMoviePageDto> discoverMovies({ // 조건을 붙인 영화 한 페이지
    required int page,
    int? genreId, // null이면 전체
  }) async {
    final response = await _dio.get(
      '/discover/movie',
      queryParameters: {
        'language': 'ko-KR',
        'page': page,
        'sort_by': 'popularity.desc', // 인기순
        'include_adult': false,
        'include_video': false,
        'with_genres': ?genreId, // 값 앞의 ?는 null이면 이 항목을 아예 안 넣는다는 뜻. 전체면 with_genres가 빠짐
      },
    );
    return TmdbMoviePageDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<List<TmdbGenreDto>> fetchGenres() async { // 공식 장르 목록. 페이지 모양이 아니라 목록으로 돌려줌
    final response = await _dio.get(
      '/genre/movie/list',
      queryParameters: {'language': 'ko'},
    );
    final data = response.data as Map<String, dynamic>;
    final genres = data['genres'] as List<dynamic>? ?? const [];
    return genres
        .map((item) => TmdbGenreDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}