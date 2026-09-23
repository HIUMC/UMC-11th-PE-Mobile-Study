import '../models/movie.dart';

const mockMovies = <Movie>[
  Movie(
    id: 1,
    title: '별빛 아래 우리',
    genre: '드라마',
    year: 2024,
    posterAsset: 'assets/images/posters/hero_under_the_starlight.jpg',
    rating: 4.8,
    synopsis: '도시의 불빛이 잠든 밤, 우연히 만난 두 사람이 서로의 가장 빛나는 순간을 기록해 갑니다.',
    director: '김하늘',
    runtime: 118,
  ),
  Movie(
    id: 2,
    title: '속삭이는 숲',
    genre: '미스터리',
    year: 2023,
    posterAsset: 'assets/images/posters/poster_whispering_woods.jpg',
    rating: 4.2,
    synopsis: '지도에도 없는 숲에 들어선 탐험가들은 나무 사이에서 자신들의 이름을 부르는 목소리를 듣습니다.',
    director: '박서준',
    runtime: 106,
  ),
  Movie(
    id: 3,
    title: '공허의 메아리',
    genre: 'SF',
    year: 2025,
    posterAsset: 'assets/images/posters/poster_echoes_of_the_void.jpg',
    rating: 4.6,
    synopsis: '외딴 우주 기지에 도착한 구조 대원은 사라진 승무원들이 남긴 신호를 따라갑니다.',
    director: '이수민',
    runtime: 132,
  ),
  Movie(
    id: 4,
    title: '심연의 방랑자',
    genre: '액션',
    year: 2022,
    posterAsset: 'assets/images/posters/poster_abyss_walker.jpg',
    rating: 4.1,
    synopsis: '깊은 바다 아래 봉인된 비밀을 찾아 나선 잠수부의 마지막 여정을 그린 작품입니다.',
    director: '최도윤',
    runtime: 124,
  ),
  Movie(
    id: 5,
    title: '네 번째 오후',
    genre: '로맨스',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_fourth_afternoon.jpg',
    rating: 4.4,
    synopsis: '매주 같은 카페에서 마주치는 두 사람이 조금씩 서로의 하루에 스며듭니다.',
    director: '정유진',
    runtime: 112,
  ),
  Movie(
    id: 6,
    title: '밤의 그림자',
    genre: '스릴러',
    year: 2021,
    posterAsset: 'assets/images/posters/poster_night_shadows.jpg',
    rating: 4.3,
    synopsis: '매일 밤 달라지는 그림자를 쫓던 형사가 오래된 실종 사건의 진실을 마주합니다.',
    director: '한지우',
    runtime: 109,
  ),
];

Movie? findMovieById(int? id) {
  for (final movie in mockMovies) {
    if (movie.id == id) return movie;
  }
  return null;
}
