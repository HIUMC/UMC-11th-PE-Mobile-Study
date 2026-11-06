import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Consumer, context.watch, context.read 사용 가능

import 'data/models/tmdb_genre_dto.dart';
import 'data/models/tmdb_movie_dto.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'view_models/movie_list_view_model.dart';
import 'widgets/movie_card.dart';
import 'widgets/movie_list_states.dart'; // Loading, Empty, Error 화면

class MovieListScreen extends StatelessWidget { // 상태는 ViewModel이 들고 있어서 화면은 StatelessWidget
  const MovieListScreen({super.key});

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
          const GenreChipBar(),
          Expanded( // Chip 줄을 뺀 나머지 공간을 상태 화면이 차지
            child: Consumer<MovieListViewModel>( // 목록 영역만 구독. 알림이 오면 builder만 다시 그림
              builder: (context, viewModel, child) {
                return switch (viewModel.status) { // 상태 이름표를 보고 보여줄 위젯을 고름
                  MovieListLoadStatus.idle ||
                  MovieListLoadStatus.loading => const MovieListLoading(),
                  MovieListLoadStatus.error => MovieListError(
                      message: viewModel.message,
                      onRetry: () => context.read<MovieListViewModel>().loadInitial(), // 버튼은 부탁만 하면 돼서 read
                    ),
                  MovieListLoadStatus.empty => const MovieListEmpty(),
                  MovieListLoadStatus.success => MovieGrid(
                      movieList: viewModel.movies,
                      genres: viewModel.genres,
                    ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GenreChipBar extends StatelessWidget { // 상단 장르 Chip 한 줄. 전체 + Genre API가 준 장르들
  const GenreChipBar({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MovieListViewModel>(); // Chip 줄 전체가 구독. 선택 장르와 로딩 여부가 바뀌면 다시 그림
    final isLoading = viewModel.status == MovieListLoadStatus.loading; // 요청 중에는 장르를 못 바꾸게 막을 때 씀

    return SingleChildScrollView( // Chip이 화면 폭을 넘어서 가로로 스크롤
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        spacing: 8, // Chip 사이 간격
        children: [
          GenreChip(
            label: '전체',
            selected: viewModel.selectedGenreId == null, // 고른 장르가 없으면 전체가 선택된 상태
            onSelected: isLoading ? null : () => context.read<MovieListViewModel>().selectGenre(null), // 전체는 null로 요청해서 with_genres를 안 보냄
          ),
          for (final genre in viewModel.genres) // Genre API가 준 장르마다 Chip 하나
            GenreChip(
              label: genre.name, // Chip에는 이름
              selected: viewModel.selectedGenreId == genre.id,
              onSelected: isLoading ? null : () => context.read<MovieListViewModel>().selectGenre(genre.id), // 요청에는 id. 로딩 중이면 null이라 눌리지 않음
            ),
        ],
      ),
    );
  }
}

class GenreChip extends StatelessWidget { // Figma 모양의 장르 Chip 하나
  const GenreChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected, // null이면 비활성화
  });

  final String label;
  final bool selected;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip( // 여러 개 중 하나만 고르는 Chip
      label: Text(label),
      selected: selected,
      onSelected: onSelected == null ? null : (_) => onSelected!(), // 눌렸는지 여부(bool)는 안 쓰고 할 일만 실행. null이면 Chip이 눌리지 않음
      showCheckmark: false, // Figma에 체크 표시 없음
      selectedColor: AppColors.violet, // 선택된 Chip 배경
      backgroundColor: AppColors.fieldFill, // 선택 안 된 Chip 배경
      side: BorderSide.none, // 테두리 없음
      shape: const StadiumBorder(), // 양 끝이 둥근 알약 모양
      labelStyle: TextStyle(
        color: selected ? AppColors.white : AppColors.black, // 선택되면 흰 글자
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class MovieGrid extends StatelessWidget { // 영화 포스터 격자 목록
  const MovieGrid({super.key, required this.movieList, required this.genres});

  final List<TmdbMovieDto> movieList; // 최대 30개
  final List<TmdbGenreDto> genres; // 카드에 장르 이름을 붙일 때 씀

  @override
  Widget build(BuildContext context) {
    final genreNames = {for (final genre in genres) genre.id: genre.name}; // 장르 id로 이름을 바로 찾게 Map으로 바꿈

    return GridView.builder(
      padding: const EdgeInsets.all(16), // 격자 바깥 여백
      itemCount: movieList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount( // 한 줄에 몇 개를 놓을지 직접 정하는 배치 규칙
        crossAxisCount: 2, // 한 줄에 2개
        crossAxisSpacing: 12, // 좌우 카드 사이 간격
        mainAxisSpacing: 16, // 위아래 카드 사이 간격
        childAspectRatio: 0.52, // 카드 가로 ÷ 세로. 포스터(2:3) 아래 제목과 연도 줄까지 들어가도록 세로를 넉넉하게
      ),
      itemBuilder: (context, index) {
        final movie = movieList[index];
        return MovieCard(
          movie: movie,
          genreName: genreNames[movie.genreIds.firstOrNull], // 첫 번째 장르 이름. 장르가 없거나 못 찾으면 null
        );
      },
    );
  }
}