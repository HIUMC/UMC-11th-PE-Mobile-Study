class TmdbMovieDto { // TMDB 영화 한 편을 담는 상자
  const TmdbMovieDto({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.genreIds,
    required this.voteAverage,
    required this.popularity,
  });

  final int id; // TMDB 영화 id. 상세 주소와 평점 movieId로 씀
  final String title;
  final String overview; // 줄거리. 없으면 빈 문자열
  final String? posterPath; // 포스터 파일 경로. 없으면 null 그대로 두고 화면에서 대체 이미지
  final String? backdropPath;
  final String? releaseDate; // 'yyyy-mm-dd'. 없으면 연도 표시 안 함
  final List<int> genreIds; // 장르 id 목록. 이름은 Genre API로 찾음
  final double voteAverage; // 10점 만점 평점
  final double popularity;

  factory TmdbMovieDto.fromJson(Map<String, dynamic> json) { // JSON 덩어리를 받아 값을 하나씩 꺼내 상자로 만듦
    return TmdbMovieDto(
      id: (json['id'] as num).toInt(), // 꼭 있어야 하는 값이라 기본값 없음
      title: json['title'] as String? ?? '제목 없음',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?, // snake_case 키를 camelCase 필드에 직접 연결
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String?,
      genreIds: (json['genre_ids'] as List<dynamic>? ?? const [])
          .map((value) => (value as num).toInt()) // 하나씩 int로 바꿔 List<int>로
          .toList(),
      voteAverage: (json['vote_average'] as num? ?? 0).toDouble(), // 8처럼 정수로 와도 안전하게 num으로 받고 double로
      popularity: (json['popularity'] as num? ?? 0).toDouble(),
    );
  }
}