class RatingDto {
  const RatingDto({
    required this.ratingId,
    required this.movieId,
    required this.score,
    this.comment,
    required this.createdAt,
  });
  final int ratingId, movieId, score;
  final String? comment;
  final DateTime createdAt;
  factory RatingDto.fromJson(Map<String, dynamic> json) => RatingDto(
    ratingId: (json['ratingId'] as num).toInt(),
    movieId: (json['movieId'] as num).toInt(),
    score: (json['score'] as num).toInt(),
    comment: json['comment'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class MovieInfo {
  const MovieInfo({required this.title, this.posterPath});
  final String title;
  final String? posterPath;
  factory MovieInfo.fromJson(Map<String, dynamic> json) => MovieInfo(
    title: json['title'] as String,
    posterPath: json['poster_path'] as String?,
  );
}

class RatingWithMovie {
  const RatingWithMovie(this.rating, this.movie);
  final RatingDto rating;
  final MovieInfo? movie;
}
