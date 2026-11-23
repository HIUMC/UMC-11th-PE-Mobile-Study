int validateServerScore(double value) { // RatingBar의 double 점수를 서버용 정수로 바꾸는 안전장치
  if (value < 1 || value > 5 || value != value.roundToDouble()) { // 1~5 밖이거나 3.5처럼 소수면 거부
    throw ArgumentError('서버 평점은 1~5 사이 정수여야 합니다.');
  }
  return value.toInt();
}

class CreateRatingRequest { // 평점 등록 요청 body를 담는 상자
  const CreateRatingRequest({
    required this.movieId,
    required this.score,
    this.comment,
  });

  final int movieId; // TMDB 영화 id. 목록 index가 아님
  final int score;
  final String? comment; // 선택 입력

  Map<String, dynamic> toJson() => {
        'movieId': movieId,
        'score': score,
        if (comment != null && comment!.trim().isNotEmpty) // 비어 있으면 comment 키를 아예 넣지 않음
          'comment': comment!.trim(),
      };
}