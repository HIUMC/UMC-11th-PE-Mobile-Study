import 'tmdb_movie_dto.dart';

class TmdbMoviePageDto { // Popular, Discover 응답 한 페이지를 담는 큰 상자
  const TmdbMoviePageDto({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  final int page; // 지금 페이지
  final List<TmdbMovieDto> results; // 이 페이지의 영화들
  final int totalPages; // 마지막 페이지 판단에 씀
  final int totalResults; // 전체 결과 수. 다 받는다는 뜻은 아님

  factory TmdbMoviePageDto.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as List<dynamic>? ?? const []; // 아직 상자에 안 담긴 영화 JSON 목록

    return TmdbMoviePageDto(
      page: (json['page'] as num).toInt(),
      results: rawResults
          .map(
            (item) => TmdbMovieDto.fromJson(
              item as Map<String, dynamic>, // 영화 JSON 하나씩 영화 상자로
            ),
          )
          .toList(),
      totalPages: (json['total_pages'] as num).toInt(),
      totalResults: (json['total_results'] as num).toInt(),
    );
  }
}