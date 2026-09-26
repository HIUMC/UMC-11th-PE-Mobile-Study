import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // context.go 사용 가능

import 'data/movies.dart'; // Mock 영화 목록
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'widgets/genre_filter_sheet.dart';
import 'widgets/movie_card.dart';

class MovieListScreen extends StatelessWidget { // 선택한 장르를 State가 아니라 주소(Query Parameter)가 기억해서 StatelessWidget
  const MovieListScreen({super.key, required this.selectedGenres}); // 필수. router가 주소에서 꺼내서 넘겨줌

  final List<String> selectedGenres; // 적용된 장르들. 주소가 /movies?genre=드라마&genre=SF면 ['드라마', 'SF'], /movies면 빈 리스트

  Future<void> openFilterSheet(BuildContext context) async { // 필터 시트를 열고, 확인하면 주소를 바꿈. 시트가 닫힐 때까지 기다려야 해서 async
    final result = await showModalBottomSheet<List<String>>( // 시트를 띄우고 닫힐 때까지 기다림. <List<String>>은 돌려받을 값의 타입
      context: context,
      isScrollControlled: true, // 기본값이면 시트가 화면 절반 남짓까지만 커짐. true여야 0.9까지 끌어올릴 수 있음
      useSafeArea: true, // 시트를 끝까지 올려도 상단 상태바(시계, 배터리)를 침범하지 않음
      builder: (sheetContext) => GenreFilterSheet(initialGenres: selectedGenres), // 지금 적용된 장르를 넘겨서 체크된 채로 열림
    );

    if (result == null) return; // 확인 대신 아래로 내리거나 바깥을 눌러 닫으면 null. 그땐 필터를 안 바꿈
    if (!context.mounted) return; // 기다리는 사이 화면이 사라졌으면 context를 쓰면 안 돼서 멈춤. 없으면 analyze 경고

    final location = Uri( // 주소를 직접 이어 붙이지 않고 Uri로 조립. 한글이나 특수문자를 주소에 쓸 수 있는 형태로 알아서 바꿔줌
      path: '/movies',
      queryParameters: result.isEmpty ? null : {'genre': result}, // 아무것도 안 고르면 Query 없이 전체. 리스트를 넣으면 ?genre=드라마&genre=SF처럼 같은 키를 반복
    ).toString();

    context.go(location); // 위에 쌓지 않고 주소만 바꿈. router가 새 주소로 화면을 다시 그림
  }

  @override
  Widget build(BuildContext context) {
    final filteredMovies = selectedGenres.isEmpty // 고른 게 없으면 모든 영화, 있으면 고른 장르 중 하나에 해당하는 영화만
        ? movies
        : movies.where((movie) => selectedGenres.contains(movie.genre)).toList(); // contains는 리스트 안에 그 값이 있는지 확인

    return Scaffold(
      appBar: AppBar(
        title: const Text('영화', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.violet),
            onPressed: () {}, // 검색은 요구사항에 없어서 Figma대로 모양만 둠
          ),
          IconButton(
            icon: const Icon(Icons.filter, color: AppColors.violet), // 워크북에 적힌 아이콘
            onPressed: () => openFilterSheet(context),
          ),
        ],
      ),
      body: MovieGrid(movieList: filteredMovies), // Chip 줄이 없어져서 Column과 Expanded 없이 GridView만 body에 둠
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