// 영화 한 편의 정보를 담는 데이터 모델
class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.posterAsset,
    required this.rating,
  });

  // 영화를 구분하기 위한 고유 ID
  //
  // 나중에
  // /movies/1
  // 처럼 상세 화면으로 이동할 때 사용함.
  final int id;

  // 영화 제목
  final String title;

  // 영화 장르
  final String genre;

  // 개봉 연도
  final int year;

  // assets 안에 있는 영화 포스터 경로
  final String posterAsset;

  // 화면에 표시할 Mock 평점
  final double rating;
}
