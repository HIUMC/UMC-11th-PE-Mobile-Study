import '../models/movie.dart';

// ---------------------------
// 영화 Mock Data
// ---------------------------
//
// 실제 서버와 연결하지 않고
// 3주차 화면에서 공통으로 사용할 영화 데이터.
//
// HomeScreen, MovieListScreen, MovieDetailScreen이
// 각각 다른 값을 직접 작성하는 것이 아니라
// 이 데이터를 함께 사용함.
const movies = [
  // ---------------------------
  // 별빛 아래 우리
  // ---------------------------
  Movie(
    id: 1,
    title: '별빛 아래 우리',
    genre: '드라마',
    year: 2023,
    posterAsset: 'assets/images/posters/hero_under_the_starlight.jpg',
    rating: 4.8,
  ),

  // ---------------------------
  // 우주의 끝에서
  // ---------------------------
  Movie(
    id: 2,
    title: '우주의 끝에서',
    genre: 'SF',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_echoes_of_the_void.jpg',
    rating: 4.2,
  ),

  // ---------------------------
  // 기억의 숲
  // ---------------------------
  Movie(
    id: 3,
    title: '기억의 숲',
    genre: '애니메이션',
    year: 2022,
    posterAsset: 'assets/images/posters/poster_whispering_woods.jpg',
    rating: 4.9,
  ),

  // ---------------------------
  // 밤의 그림자
  // ---------------------------
  Movie(
    id: 4,
    title: '밤의 그림자',
    genre: '스릴러',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_night_shadows.jpg',
    rating: 3.8,
  ),

  // ---------------------------
  // 봄날의 커피
  // ---------------------------
  Movie(
    id: 5,
    title: '봄날의 커피',
    genre: '로맨스',
    year: 2021,
    posterAsset: 'assets/images/posters/poster_fourth_afternoon.jpg',
    rating: 4.5,
  ),
];

// ---------------------------
// ID로 영화 찾기
// ---------------------------
//
// 예를 들어 상세 화면의 주소가
//
// /movies/3
//
// 이라면 movieId는 3이 되고,
// 이 함수를 사용해서 id가 3인 영화를 찾음.
Movie? findMovieById(int? id) {
  for (final movie in movies) {
    if (movie.id == id) {
      return movie;
    }
  }

  // 해당 ID의 영화가 없으면 null 반환
  return null;
}
