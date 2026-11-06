class RatingDto { // 자체 API의 평점 하나를 담는 상자. 서버 RatingResponse와 필드 이름이 같음
  const RatingDto({
    required this.ratingId,
    required this.movieId,
    required this.score,
    required this.comment,
    required this.createdAt,
  });

  final int ratingId;
  final int movieId; // TMDB 영화 id
  final int score; // 1~5점
  final String? comment; // 코멘트 없이 점수만 남길 수 있어서 null 가능
  final DateTime createdAt;

  factory RatingDto.fromJson(Map<String, dynamic> json) {
    return RatingDto(
      ratingId: (json['ratingId'] as num).toInt(), // 서버가 이미 camelCase로 보내서 키 그대로 씀
      movieId: (json['movieId'] as num).toInt(),
      score: (json['score'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String), // '2026-11-01T04:25:06' 문자열을 날짜로
    );
  }
}