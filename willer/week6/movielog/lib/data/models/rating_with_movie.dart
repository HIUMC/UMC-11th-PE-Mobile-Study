import 'rating_dto.dart';
import 'tmdb_movie_dto.dart';

class RatingWithMovie { // 평점 하나와 그 영화 정보를 한 쌍으로 묶음
  const RatingWithMovie({
    required this.rating,
    this.movie,
  });

  final RatingDto rating;
  final TmdbMovieDto? movie; // TMDB에서 찾지 못했으면 null. 화면에서 placeholder로 대신함
}