import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/movie_list_preference.dart';
import 'theme/app_colors.dart';
import 'view_models/movie_list_view_model.dart';
import 'widgets/app_bottom_nav_bar.dart';
import 'widgets/movie_list/movie_grid.dart';
import 'widgets/movie_list/movie_list_empty.dart';
import 'widgets/movie_list/movie_list_error.dart';
import 'widgets/movie_list/movie_list_loading.dart';

/// TMDB 영화 목록 화면. 상태는 [MovieListViewModel]이 관리합니다.
class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: const Text(
          '영화',
          style: TextStyle(
            fontFamily: 'Manrope',
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.w500,
            height: 28 / 22,
          ),
        ),
        actions: [
          const _SortMenu(),
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 16),
            child: _GenreChips(),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<MovieListViewModel>().refresh(),
              child: Consumer<MovieListViewModel>(
                builder: (context, viewModel, child) {
                  return switch (viewModel.status) {
                    MovieListLoadStatus.idle ||
                    MovieListLoadStatus.loading => const MovieListLoading(),
                    MovieListLoadStatus.error => MovieListError(
                      message: viewModel.message,
                      onRetry: viewModel.retry,
                    ),
                    MovieListLoadStatus.empty => MovieListEmpty(
                      // 장르 필터 때문에 비었다면 '전체 장르 보기'를 제공합니다.
                      onShowAll: viewModel.isFiltered
                          ? () => viewModel.selectGenre(null)
                          : null,
                    ),
                    MovieListLoadStatus.success => MovieGrid(
                      movies: viewModel.movies,
                    ),
                  };
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(current: NavTab.movies),
    );
  }
}

class _SortMenu extends StatelessWidget {
  const _SortMenu();

  @override
  Widget build(BuildContext context) {
    final sortOrder = context.select<MovieListViewModel, MovieSortOrder>(
      (vm) => vm.sortOrder,
    );
    return PopupMenuButton<MovieSortOrder>(
      tooltip: '정렬: ${sortOrder.label}',
      initialValue: sortOrder,
      onSelected: context.read<MovieListViewModel>().selectSortOrder,
      icon: const Icon(Icons.sort, color: AppColors.textSecondary),
      itemBuilder: (context) => [
        for (final order in MovieSortOrder.values)
          CheckedPopupMenuItem(
            value: order,
            checked: order == sortOrder,
            child: Text(order.label),
          ),
      ],
    );
  }
}

/// TMDB 장르 목록으로 만든 Chip. 맨 앞의 '전체'는 genreId가 null입니다.
class _GenreChips extends StatelessWidget {
  const _GenreChips();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MovieListViewModel>();
    final chips = <(int?, String)>[
      (null, MovieListPreference.allGenre),
      for (final genre in viewModel.genres) (genre.id, genre.name),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (id, name) = chips[index];
          return Align(
            alignment: Alignment.topCenter,
            child: _GenreChip(
              label: name,
              isSelected: id == viewModel.selectedGenreId,
              // 영화 목록을 받는 중에는 장르를 바꿀 수 없습니다.
              onTap: viewModel.isFetching
                  ? null
                  : () => viewModel.selectGenre(id),
            ),
          );
        },
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;

  /// null이면 비활성 상태로, 선택되지 않은 Chip을 흐리게 표시합니다.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedOpacity(
          opacity: enabled || isSelected ? 1 : 0.4,
          duration: const Duration(milliseconds: 150),
          child: _buildChip(),
        ),
      ),
    );
  }

  Widget _buildChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(9999),
        boxShadow: isSelected
            ? const [
                BoxShadow(
                  color: AppColors.shadowSubtle,
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Manrope',
          color: isSelected ? AppColors.white : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 16 / 12,
        ),
      ),
    );
  }
}
