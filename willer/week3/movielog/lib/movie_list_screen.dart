import 'package:flutter/material.dart';

import 'data/movies.dart'; // Mock 영화 목록
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'widgets/movie_card.dart';

class MovieListScreen extends StatefulWidget { // 선택한 장르에 따라 화면이 바뀌어야 해서 StatefulWidget
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  String selectedGenre = '전체'; // 지금 선택된 장르. Chip 목록과 GridView가 둘 다 알아야 해서 공통 부모가 들고 있음. 값이 바뀌어서 final이 아님

  @override
  Widget build(BuildContext context) {
    final filteredMovies = selectedGenre == '전체' // 전체면 모든 영화, 아니면 장르가 같은 영화만
        ? movies
        : movies.where((movie) => movie.genre == selectedGenre).toList(); // where는 조건에 맞는 것만 걸러냄. 결과가 Iterable이라 toList로 List로 바꿈

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
          GenreChipList(
            selectedGenre: selectedGenre, // 현재 선택된 장르를 넘겨줌
            onSelected: (genre) { // Chip이 눌리면 실행됨. 누른 장르가 genre로 들어옴
              setState(() {
                selectedGenre = genre; // 값을 바꾸고 다시 그리라고 알림. Chip과 GridView가 같이 바뀜
              });
            },
          ),
          Expanded(child: MovieGrid(movieList: filteredMovies)), // GridView는 세로로 끝까지 늘어나려 해서 Column 안에서는 Expanded로 남은 공간만 쓰게 함. 없으면 무한 높이 에러
        ],
      ),
    );
  }
}

class GenreChipList extends StatelessWidget { // 상단 장르 Chip 가로 목록. 선택 상태는 부모에게 받고, 눌리면 부모에게 알리기만 함
  const GenreChipList({
    super.key,
    required this.selectedGenre,
    required this.onSelected,
  });

  static const genres = ['전체', '드라마', 'SF', '애니메이션', '스릴러', '로맨스', '액션']; // Mock 영화의 장르 + 전체. Figma 순서대로

  final String selectedGenre;
  final ValueChanged<String> onSelected; // void Function(String)의 별칭. 누른 장르 이름을 들고 부모에게 알림

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48, // 가로 ListView는 높이를 스스로 못 정해서 직접 지정. Chip의 터치 영역 높이
      child: ListView.separated( // 항목 사이에만 간격을 넣는 ListView
        scrollDirection: Axis.horizontal, // 화면 폭보다 Chip이 많아서 가로 스크롤
        padding: const EdgeInsets.symmetric(horizontal: 16), // 첫 Chip과 마지막 Chip이 화면 끝에 붙지 않게
        itemCount: genres.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8), // Chip 사이 간격
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = genre == selectedGenre; // 부모가 넘겨준 선택 장르와 같으면 선택된 Chip

          return ChoiceChip( // 여러 개 중 하나를 고르는 Chip. selected로 선택 상태를 가짐
            label: Text(genre),
            selected: isSelected,
            onSelected: (_) => onSelected(genre), // 이 Chip의 장르를 부모에게 넘김. (_)는 ChoiceChip이 주는 bool 값을 안 쓴다는 표시
            showCheckmark: false, // Material 3 기본값은 선택 시 체크 표시. Figma에 없어서 끔
            selectedColor: AppColors.violet, // 선택됐을 때 배경
            backgroundColor: AppColors.fieldFill, // 선택 안 됐을 때 배경
            labelStyle: AppTextStyles.bodySmall.copyWith(
              color: isSelected ? AppColors.white : AppColors.black, // 선택되면 흰 글자, 아니면 검정 글자
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide.none, // 테두리 없음
            shape: const StadiumBorder(), // 양 끝이 완전히 둥근 알약 모양
          );
        },
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