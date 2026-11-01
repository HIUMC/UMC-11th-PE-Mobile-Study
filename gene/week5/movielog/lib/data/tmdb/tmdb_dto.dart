import '../movies.dart';

/// `/genre/movie/list`의 장르 하나.
class TmdbGenreDto {
  const TmdbGenreDto({required this.id, required this.name});

  final int id;
  final String name;

  factory TmdbGenreDto.fromJson(Map<String, dynamic> json) =>
      TmdbGenreDto(id: json['id'] as int, name: json['name'] as String);
}

/// `/movie/popular`, `/discover/movie` 결과의 영화 하나.
class TmdbMovieDto {
  const TmdbMovieDto({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.genreIds,
  });

  static const _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  final int id;
  final String title;
  final String overview;
  final String? posterPath;

  /// `yyyy-MM-dd`. 개봉일이 없는 영화는 빈 문자열로 옵니다.
  final String releaseDate;

  /// 10점 만점
  final double voteAverage;
  final int voteCount;
  final List<int> genreIds;

  factory TmdbMovieDto.fromJson(Map<String, dynamic> json) => TmdbMovieDto(
    id: json['id'] as int,
    title: json['title'] as String? ?? '',
    overview: json['overview'] as String? ?? '',
    posterPath: json['poster_path'] as String?,
    releaseDate: json['release_date'] as String? ?? '',
    voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
    voteCount: json['vote_count'] as int? ?? 0,
    genreIds: [
      for (final id in json['genre_ids'] as List? ?? const []) id as int,
    ],
  );

  String? get posterUrl =>
      posterPath == null ? null : '$_imageBaseUrl$posterPath';

  int get year => int.tryParse(releaseDate.split('-').first) ?? 0;

  /// 기존 화면 위젯을 그대로 쓰기 위해 앱 내부 [Movie] 모델로 바꿉니다.
  ///
  /// [genreNames]는 장르 id → 이름. 모르는 id는 건너뜁니다.
  Movie toMovie(Map<int, String> genreNames) {
    final names = [for (final id in genreIds) ?genreNames[id]];
    return Movie(
      id: '$id',
      title: title,
      year: year,
      genre: names.isEmpty ? '기타' : names.first,
      // 앱의 별점은 5점 만점이라 절반으로 맞춥니다.
      rating: voteAverage / 2,
      poster: posterUrl ?? '',
      ratingCount: '$voteCount',
      tags: names,
      synopsis: overview.isEmpty ? const [] : [overview],
    );
  }
}

/// TMDB 목록 응답의 공통 페이지 형태.
class TmdbPage<T> {
  const TmdbPage({
    required this.page,
    required this.totalPages,
    required this.results,
  });

  final int page;
  final int totalPages;
  final List<T> results;

  factory TmdbPage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) => TmdbPage(
    page: json['page'] as int? ?? 1,
    totalPages: json['total_pages'] as int? ?? 1,
    results: [
      for (final item in json['results'] as List? ?? const [])
        fromItem(item as Map<String, dynamic>),
    ],
  );
}
