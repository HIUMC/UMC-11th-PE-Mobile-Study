class Movie { // 영화 한 편의 정보를 담는 틀. 홈, 목록, 상세가 모두 이 모양으로 영화를 읽음
  const Movie({ // const 생성자. 필드가 전부 final이라 가능
    required this.id, // 필수. 영화를 구분하는 번호. 상세 주소 /movies/1의 1이 이 값
    required this.title,
    required this.genre,
    required this.year,
    required this.posterAsset,
    required this.rating,
    required this.runtime,
    required this.reviewCount,
    required this.tags,
    required this.synopsis,
  });

  final int id; // final이라 한 번 정해지면 안 바뀜
  final String title; // 제목
  final String genre; // 장르. 목록의 장르 Chip 필터 기준
  final int year; // 개봉 연도
  final String posterAsset; // 포스터 이미지 경로. pubspec.yaml에 등록한 assets 폴더 안이어야 함
  final double rating; // 평균 평점. 4.5처럼 소수라서 double
  final int runtime; // 러닝타임(분)
  final int reviewCount; // 평점을 남긴 사람 수
  final List<String> tags; // 상세 화면의 태그 Chip들
  final String synopsis; // 상세 화면의 시놉시스 본문
}

const movies = [ // 앱 전체가 같이 쓰는 영화 목록. 클래스 밖(파일 최상단)에 둬서 어디서든 import해서 사용. 화면마다 따로 하드코딩하지 않음
  Movie(
    id: 1,
    title: '별빛 아래 우리',
    genre: '드라마',
    year: 2024,
    posterAsset: 'assets/images/posters/hero_under_the_starlight.jpg', // 워크북 예제의 movie_1.png 대신 레포에 있는 포스터 사용
    rating: 4.5, // 상세 Figma와 미션의 평균 평점 4.5에 맞춤
    runtime: 124,
    reviewCount: 1245,
    tags: ['로맨스', '드라마', '감동적인'],
    synopsis: '바쁜 현대 사회 속에서 서로의 존재를 잊고 살아가던 두 남녀가 우연한 계기로 작은 천문대에서 만나게 됩니다. 매일 밤 별을 관측하며 서로의 상처를 치유하고, 잊고 있던 꿈과 사랑을 다시금 깨닫게 되는 따뜻한 이야기입니다.\n\n' // \n\n은 빈 줄 하나를 둔 문단 나누기
        '과거의 아픔으로 인해 사람에게 마음을 열지 못하던 여주인공은, 별자리처럼 변함없는 모습으로 자신을 기다려주는 남주인공을 통해 서서히 마음의 문을 열게 됩니다. 하지만 두 사람 앞에 놓인 현실적인 장벽들은 그들의 관계를 시험하게 되는데...\n\n' // 문자열을 줄마다 나눠 써도 붙어 있으면 하나로 합쳐짐
        '별이 쏟아지는 밤하늘 아래, 그들이 나눈 조용한 약속들은 과연 영원할 수 있을까요? 눈부신 영상미와 감성적인 OST가 어우러져 깊은 여운을 남기는 올 겨울 최고의 로맨스 영화.\n\n'
        '잔잔한 감동과 함께 삶의 의미를 다시 한번 되돌아보게 만드는 수작입니다.',
  ),
  Movie(
    id: 2,
    title: '우주의 끝에서',
    genre: 'SF',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_echoes_of_the_void.jpg',
    rating: 4.2,
    runtime: 118,
    reviewCount: 987,
    tags: ['SF', '모험', '우주'],
    synopsis: '인류의 마지막 희망을 싣고 떠난 탐사대가 우주의 끝에서 예상치 못한 신호를 발견하며 벌어지는 이야기입니다.',
  ),
  Movie(
    id: 3,
    title: '기억의 숲',
    genre: '애니메이션',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_whispering_woods.jpg',
    rating: 4.9,
    runtime: 102,
    reviewCount: 2310,
    tags: ['애니메이션', '판타지', '가족'],
    synopsis: '잃어버린 기억을 찾아 신비한 숲으로 들어간 소녀가 작은 숲의 정령과 함께 모험을 떠나는 이야기입니다.',
  ),
  Movie(
    id: 4,
    title: '밤의 그림자',
    genre: '스릴러',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_night_shadows.jpg',
    rating: 3.8,
    runtime: 115,
    reviewCount: 654,
    tags: ['스릴러', '미스터리', '범죄'],
    synopsis: '비 내리는 도시의 뒷골목, 연쇄 실종 사건을 쫓던 형사가 자신의 과거와 마주하게 되는 이야기입니다.',
  ),
  Movie(
    id: 5,
    title: '네 번째 오후',
    genre: '로맨스',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_fourth_afternoon.jpg',
    rating: 4.3,
    runtime: 110,
    reviewCount: 1120,
    tags: ['로맨스', '일상', '잔잔한'],
    synopsis: '매주 같은 카페에서 마주치던 두 사람이 네 번째 오후에 처음 말을 건네며 시작되는 이야기입니다.',
  ),
  Movie(
    id: 6,
    title: '미션 임프로버블',
    genre: '액션',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_abyss_walker.jpg',
    rating: 4.0,
    runtime: 128,
    reviewCount: 876,
    tags: ['액션', '코미디', '첩보'],
    synopsis: '실수투성이 요원 맥스가 우연히 세계를 구할 임무를 맡게 되며 벌어지는 좌충우돌 첩보 액션입니다.',
  ),
];

Movie? findMovieById(int? id) { // id로 영화 한 편을 찾음. 주소에서 꺼낸 값은 숫자로 못 바꿀 수도 있어서 int?로 받음. 못 찾으면 null이라 반환도 Movie?
  for (final movie in movies) { // 목록을 앞에서부터 하나씩 꺼내봄
    if (movie.id == id) return movie; // id가 같으면 그 영화를 바로 반환하고 함수 종료
  }
  return null; // 끝까지 못 찾으면 null
}