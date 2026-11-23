class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.genre,
    required this.rating,
    required this.poster,
    this.detailPoster,
    this.runtime,
    this.ratingCount,
    this.tags = const [],
    this.synopsis = const [],
  });

  final String id;
  final String title;
  final int year;
  final String genre;
  final double rating;

  /// 목록 카드용 세로 포스터
  final String poster;

  /// 상세 화면용 포스터. 없으면 [poster]를 사용
  final String? detailPoster;

  // 아래는 상세 정보가 있는 영화만 채움
  final int? runtime;
  final String? ratingCount;
  final List<String> tags;
  final List<String> synopsis;
}

const movies = [
  Movie(
    id: '1',
    title: '별빛 아래 우리',
    year: 2023,
    genre: '드라마',
    rating: 4.8,
    poster: 'assets/images/movies/starlight.jpg',
    detailPoster: 'assets/images/movies/starlight_hero.jpg',
    runtime: 124,
    ratingCount: '1,245',
    tags: ['로맨스', '드라마', '감동적인'],
    synopsis: [
      '바쁜 현대 사회 속에서 서로의 존재를 잊고 살아가던 두 남녀가 우연한 계기로 작은 천문대에서 만나게 됩니다. '
          '매일 밤 별을 관측하며 서로의 상처를 치유하고, 잊고 있던 꿈과 사랑을 다시금 깨닫게 되는 따뜻한 이야기입니다.',
      '과거의 아픔으로 인해 사람에게 마음을 열지 못하던 여주인공은, 별자리처럼 변함없는 모습으로 자신을 기다려주는 '
          '남주인공을 통해 서서히 마음의 문을 열게 됩니다. 하지만 두 사람 앞에 놓인 현실적인 장벽들은 그들의 관계를 시험하게 되는데...',
      '별이 쏟아지는 밤하늘 아래, 그들이 나눈 조용한 약속들은 과연 영원할 수 있을까요? '
          '눈부신 영상미와 감성적인 OST가 어우러져 깊은 여운을 남기는 올 겨울 최고의 로맨스 영화.',
      '잔잔한 감동과 함께 삶의 의미를 다시 한번 되돌아보게 만드는 수작입니다.',
    ],
  ),
  Movie(
    id: '2',
    title: '우주의 끝에서',
    year: 2024,
    genre: 'SF',
    rating: 4.2,
    poster: 'assets/images/movies/end_of_universe.jpg',
  ),
  Movie(
    id: '3',
    title: '기억의 숲',
    year: 2022,
    genre: '애니메이션',
    rating: 4.9,
    poster: 'assets/images/movies/forest_of_memory.jpg',
  ),
  Movie(
    id: '4',
    title: '밤의 그림자',
    year: 2024,
    genre: '스릴러',
    rating: 3.8,
    poster: 'assets/images/movies/night_shadows.jpg',
  ),
  Movie(
    id: '5',
    title: '봄날의 커피',
    year: 2021,
    genre: '로맨스',
    rating: 4.5,
    poster: 'assets/images/movies/spring_coffee.jpg',
  ),
  Movie(
    id: '6',
    title: '도시의 선',
    year: 2023,
    genre: '다큐멘터리',
    rating: 4.1,
    poster: 'assets/images/movies/city_lines.jpg',
  ),
];

Movie? findMovieById(String id) {
  for (final movie in movies) {
    if (movie.id == id) return movie;
  }
  return null;
}
