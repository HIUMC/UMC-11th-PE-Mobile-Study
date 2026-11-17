import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/data/tmdb/tmdb_dto.dart';

/// 내 평점 하나와 그 영화의 TMDB 정보를 묶은 모델입니다.
class RatingWithMovie {
  const RatingWithMovie({required this.rating, this.movie});

  final RatingDto rating;
  final TmdbMovieDto? movie; // TMDB에서 찾지 못했으면 null입니다.
}
