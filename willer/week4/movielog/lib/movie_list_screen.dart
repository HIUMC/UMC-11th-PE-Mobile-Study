import 'package:flutter/material.dart';

import 'data/movies.dart'; // Movie 타입
import 'services/fake_movie_service.dart'; // 영화 목록을 비동기로 받아오는 서비스
import 'services/genre_preference.dart'; // 마지막 선택 장르 저장소
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'widgets/movie_card.dart';
import 'widgets/movie_list_states.dart'; // Loading·Empty·Error 화면

class MovieListScreen extends StatefulWidget { // Future와 선택 장르를 State에 들고 있어야 해서 StatefulWidget
  const MovieListScreen({super.key}); // 장르를 주소로 받지 않아서 넘겨받는 값이 없음

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  static const initialLoadMode = MovieLoadMode.success; // 상태 확인용. empty나 failure로 바꾸고 재시작하면 해당 화면이 나옴
  final movieService = const FakeMovieService(); // TODO(5주차 유저별 평점 조회 API): FakeMovieService를 실제 API Service로 교체
  final genrePreference = GenrePreference();
  late Future<List<Movie>> _moviesFuture; // 영화 목록 요청 작업. late는 initState에서 값을 넣겠다는 약속
  String selectedGenre = '전체'; // 저장된 값을 읽기 전까지 쓰는 기본값

  @override
  void initState() { // 화면이 처음 만들어질 때 한 번만 실행
    super.initState();
    _moviesFuture = movieService.fetchMovies(mode: initialLoadMode); // build가 아니라 여기서 생성. build는 여러 번 다시 실행돼서 거기서 만들면 요청이 반복됨
    loadSelectedGenre(); // 저장된 장르 복원. 영화 요청과 서로 기다리지 않고 따로 진행
  }

  Future<void> loadSelectedGenre() async { // 폰에 저장된 장르를 읽어서 Chip 선택에 반영
    final savedGenre = await genrePreference.read();
    if (!mounted) return; // 읽는 사이 화면이 사라졌으면 setState하면 안 돼서 멈춤

    setState(() {
      selectedGenre = savedGenre;
    });
  }

  Future<void> selectGenre(String genre) async { // Chip을 눌렀을 때 화면 갱신 후 저장
    setState(() {
      selectedGenre = genre; // 목록은 이미 받아온 결과를 다시 거르기만 해서 로딩 없음
    });
    await genrePreference.save(genre); // 앱을 껐다 켜도 남도록 저장
  }

  void _retry() { // 다시 시도 버튼. 이때만 새 Future를 만듦
    setState(() {
      _moviesFuture = movieService.fetchMovies(); // 재시도는 항상 성공 모드. 일시적 오류 후 다시 요청하면 성공하는 상황
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('영화', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.violet),
            onPressed: () {}, // 검색은 요구사항에 없어서 Figma대로 모양만 둠
          ),
        ],
      ),
      body: Column(
        children: [
          GenreChipBar(
            selectedGenre: selectedGenre,
            onSelected: selectGenre,
          ),
          Expanded( // Chip 줄을 뺀 나머지 공간을 상태 화면이 차지
            child: FutureBuilder<List<Movie>>( // Future의 진행 상태를 보고 그때그때 다른 화면을 그림. 요청을 직접 하지는 않음
              future: _moviesFuture, // initState나 재시도에서 만든 Future. 여기서 fetchMovies()를 직접 부르면 안 됨
              builder: (context, snapshot) { // snapshot에 현재 상태(connectionState)와 결과(data, error)가 들어 있음
                if (snapshot.connectionState == ConnectionState.waiting) { // 아직 결과가 없는 상태
                  return const MovieListLoading();
                }

                if (snapshot.hasError) { // 오류를 빈 목록보다 먼저 확인. 순서가 바뀌면 오류인데 Empty가 뜸
                  return MovieListError(onRetry: _retry);
                }

                final loadedMovies = snapshot.data ?? const <Movie>[]; // 결과가 null이면 빈 리스트로. 전역 movies와 헷갈리지 않게 이름을 다르게 지음
                final filteredMovies = selectedGenre == '전체' // 전체면 받아온 영화 전부, 아니면 고른 장르만
                    ? loadedMovies
                    : loadedMovies.where((movie) => movie.genre == selectedGenre).toList();

                if (filteredMovies.isEmpty) { // 빈 목록 결과와 장르에 맞는 영화가 없는 경우 둘 다
                  return const MovieListEmpty();
                }

                return MovieGrid(movieList: filteredMovies); // 3주차 MovieGrid 재사용
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GenreChipBar extends StatelessWidget { // 상단 장르 Chip 한 줄. 선택값과 누를 때 할 일은 부모가 정함
  const GenreChipBar({
    super.key,
    required this.selectedGenre,
    required this.onSelected,
  });

  static const genres = ['전체', '드라마', 'SF', '애니메이션', '스릴러', '로맨스', '액션']; // Mock 데이터에 있는 장르 + 전체

  final String selectedGenre;
  final ValueChanged<String> onSelected; // 눌린 장르를 넘겨받는 함수 타입

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Chip이 화면 폭을 넘어서 가로로 스크롤
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        spacing: 8, // Chip 사이 간격
        children: [
          for (final genre in genres) // 장르마다 Chip 하나
            ChoiceChip( // 여러 개 중 하나만 고르는 Chip
              label: Text(genre),
              selected: genre == selectedGenre,
              onSelected: (_) => onSelected(genre), // 눌렸는지 여부(bool)는 안 쓰고 장르만 넘김
              showCheckmark: false, // Figma에 체크 표시 없음
              selectedColor: AppColors.violet, // 선택된 Chip 배경
              backgroundColor: AppColors.fieldFill, // 선택 안 된 Chip 배경
              side: BorderSide.none, // 테두리 없음
              shape: const StadiumBorder(), // 양 끝이 둥근 알약 모양
              labelStyle: TextStyle(
                color: genre == selectedGenre ? AppColors.white : AppColors.black, // 선택되면 흰 글자
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class MovieGrid extends StatelessWidget { // 영화 포스터 격자 목록. 무엇을 보여줄지는 부모가 걸러서 넘겨줌
  const MovieGrid({super.key, required this.movieList});

  final List<Movie> movieList; // 걸러진 영화 목록. 전체 Mock 목록 이름(movies)과 헷갈리지 않게 이름을 다르게 지음

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16), // 격자 바깥 여백
      itemCount: movieList.length, // 걸러진 영화 개수만큼
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount( // 한 줄에 몇 개를 놓을지 직접 정하는 배치 규칙
        crossAxisCount: 2, // 한 줄에 2개
        crossAxisSpacing: 12, // 좌우 카드 사이 간격
        mainAxisSpacing: 16, // 위아래 카드 사이 간격
        childAspectRatio: 0.52, // 카드 가로 ÷ 세로. 포스터(2:3) 아래 제목과 연도 줄까지 들어가도록 세로를 넉넉하게
      ),
      itemBuilder: (context, index) => MovieCard(movie: movieList[index]), // 홈과 같은 MovieCard 재사용. 폭은 GridView가 정해줌
    );
  }
}