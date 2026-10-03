import '../models/movie.dart';

const mockMovies = <Movie>[
  Movie(
    id: 1,
    title: '별빛 아래 우리',
    genre: '드라마',
    year: 2023,
    posterAsset: 'assets/images/posters/hero_under_the_starlight.jpg',
    rating: 4.5,
    synopsis: '바쁜 현대 사회 속에서 서로의 존재를 잊고 살아가던 두 남녀가 우연한 계기로 작은 천문대에서 만나게 됩니다. 매일 밤 별을 관측하며 서로의 상처를 치유하고, 잊고 있던 꿈과 사랑을 다시 발견하게 되는 이야기입니다.\n\n과거의 아픔으로 인해 사람에게 마음을 열지 못하던 주인공은, 별자리를 변함없는 모습으로 기록하는 단 한 사람을 만나 조금씩 마음의 문을 열게 됩니다. 하지만 두 사람 앞에 놓인 현실의 장벽들은 그들의 관계를 시험하게 되는데...\n\n별이 쏟아지는 밤하늘 아래, 그들이 나눈 조용한 약속은 과연 영원할 수 있을까요? 두 사람의 섬세한 감정선이 OST와 어우러져 깊은 여운을 남기는 로맨스 영화입니다.',
    director: '김하늘',
    runtime: 124,
    detailGenre: '로맨스/드라마',
    ratingCount: 1245,
    tags: ['로맨스', '드라마', '감동적인'],
  ),
  Movie(
    id: 2,
    title: '우주의 끝에서',
    genre: 'SF',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_echoes_of_the_void.jpg',
    rating: 4.2,
    synopsis: '우주의 끝에서 발견한 신호를 따라가는 탐사대의 이야기.',
    director: '박서준',
    runtime: 128,
  ),
  Movie(
    id: 3,
    title: '기억의 숲',
    genre: '애니메이션',
    year: 2022,
    posterAsset: 'assets/images/posters/poster_whispering_woods.jpg',
    rating: 4.9,
    synopsis: '오래된 숲에서 만난 친구들과 함께 마음의 길을 찾아가는 애니메이션.',
    director: '최도윤',
    runtime: 102,
  ),
  Movie(
    id: 4,
    title: '밤의 그림자',
    genre: '스릴러',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_night_shadows.jpg',
    rating: 3.8,
    synopsis: '도시의 밤에 남겨진 단서를 쫓는 형사의 이야기.',
    director: '한지우',
    runtime: 109,
  ),
  Movie(
    id: 5,
    title: '봄날의 커피',
    genre: '로맨스',
    year: 2021,
    posterAsset: 'assets/images/posters/poster_fourth_afternoon.jpg',
    rating: 4.5,
    synopsis: '작은 카페에서 마주친 두 사람이 서로의 하루에 스며드는 이야기.',
    director: '정유진',
    runtime: 112,
  ),
  Movie(
    id: 6,
    title: '도시의 선',
    genre: '다큐멘터리',
    year: 2023,
    posterAsset: 'assets/images/posters/poster_city_lines.jpg',
    rating: 4.1,
    synopsis: '도시의 건축과 그 안에서 살아가는 사람들의 이야기를 담은 다큐멘터리.',
    director: '한지우',
    runtime: 98,
  ),
];

Movie? findMovieById(int? id) {
  for (final movie in mockMovies) {
    if (movie.id == id) return movie;
  }
  return null;
}
