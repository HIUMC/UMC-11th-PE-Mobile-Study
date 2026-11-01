import 'package:flutter/material.dart';

import 'data/movies.dart';
import 'services/fake_movie_service.dart';
import 'services/movie_list_preference.dart';
import 'theme/app_colors.dart';
import 'widgets/app_bottom_nav_bar.dart';
import 'widgets/movie_list/movie_grid.dart';
import 'widgets/movie_list/movie_list_empty.dart';
import 'widgets/movie_list/movie_list_error.dart';
import 'widgets/movie_list/movie_list_loading.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({
    super.key,
    this.movieService = const FakeMovieService(),
    this.preference,
    this.initialLoadMode = MovieLoadMode.success,
  });

  final FakeMovieService movieService;

  /// 테스트에서 주입할 수 있도록 열어 둡니다. null이면 기본 저장소를 사용합니다.
  final MovieListPreference? preference;

  final MovieLoadMode initialLoadMode;

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  static const _allGenre = MovieListPreference.allGenre;
  static const _genres = [_allGenre, '드라마', 'SF', '애니메이션', '스릴러', '로맨스'];

  late final MovieListPreference _preference =
      widget.preference ?? MovieListPreference();

  late Future<List<Movie>> _moviesFuture;
  late MovieLoadMode _loadMode = widget.initialLoadMode;

  String _selectedGenre = _allGenre;
  MovieSortOrder _sortOrder = MovieSortOrder.latest;

  /// 저장된 설정을 읽기 전에 사용자가 먼저 바꿨다면 복원값으로 덮어쓰지 않습니다.
  bool _userChangedPreference = false;

  /// 당겨서 새로고침 중에는 Skeleton 대신 기존 목록을 유지합니다.
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _moviesFuture = widget.movieService.fetchMovies(mode: _loadMode);
    _restorePreferences();
  }

  Future<void> _restorePreferences() async {
    // 서로 의존하지 않는 두 값은 Future.wait로 함께 읽습니다.
    final (genre, sortOrder) = await (
      _preference.readGenre(),
      _preference.readSortOrder(),
    ).wait;

    if (!mounted || _userChangedPreference) return;

    setState(() {
      _selectedGenre = _genres.contains(genre) ? genre : _allGenre;
      _sortOrder = sortOrder;
    });
  }

  /// 재시도·모드 변경처럼 작업을 다시 시작할 때만 새로운 Future를 만듭니다.
  void _retry() {
    setState(() {
      _moviesFuture = widget.movieService.fetchMovies(mode: _loadMode);
    });
  }

  Future<void> _refresh() async {
    final future = widget.movieService.fetchMovies(mode: _loadMode);
    setState(() {
      _isRefreshing = true;
      _moviesFuture = future;
    });

    try {
      await future;
    } on MovieLoadException {
      // 오류 표시는 FutureBuilder가 담당합니다. 여기서는 인디케이터만 닫습니다.
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  void _changeLoadMode(MovieLoadMode mode) {
    _loadMode = mode;
    _retry();
  }

  void _selectGenre(String genre) {
    _userChangedPreference = true;
    setState(() => _selectedGenre = genre);
    _preference.saveGenre(genre);
  }

  void _selectSortOrder(MovieSortOrder order) {
    _userChangedPreference = true;
    setState(() => _sortOrder = order);
    _preference.saveSortOrder(order);
  }

  List<Movie> _visibleMovies(List<Movie> loaded) {
    final filtered = _selectedGenre == _allGenre
        ? loaded
        : loaded.where((movie) => movie.genre == _selectedGenre);
    return _sortOrder.apply(filtered);
  }

  String _errorMessage(Object? error) {
    return switch (error) {
      MovieLoadTimeoutException() =>
        '응답이 너무 오래 걸리고 있어요.\n네트워크 상태를 확인한 뒤 다시 시도해 주세요.',
      _ => '영화를 불러오지 못했습니다.\n잠시 후 다시 시도해 주세요.',
    };
  }

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
          _buildSortMenu(),
          _buildLoadModeMenu(),
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: _buildGenreChips(),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _refresh,
              child: FutureBuilder<List<Movie>>(
                future: _moviesFuture,
                builder: _buildMovieList,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(current: NavTab.movies),
    );
  }

  Widget _buildMovieList(
    BuildContext context,
    AsyncSnapshot<List<Movie>> snapshot,
  ) {
    final isWaiting = snapshot.connectionState == ConnectionState.waiting;
    final keepPrevious = _isRefreshing && snapshot.hasData;

    if (isWaiting && !keepPrevious) {
      return const MovieListLoading();
    }

    if (snapshot.hasError) {
      return MovieListError(
        message: _errorMessage(snapshot.error),
        onRetry: _retry,
      );
    }

    final loaded = snapshot.data ?? const <Movie>[];
    final visible = _visibleMovies(loaded);

    if (visible.isEmpty) {
      // 불러온 영화는 있지만 장르 필터로 비었다면 필터 해제 동작을 제공합니다.
      return MovieListEmpty(
        onShowAll: loaded.isNotEmpty && _selectedGenre != _allGenre
            ? () => _selectGenre(_allGenre)
            : null,
      );
    }

    return MovieGrid(movies: visible);
  }

  Widget _buildSortMenu() {
    return PopupMenuButton<MovieSortOrder>(
      tooltip: '정렬: ${_sortOrder.label}',
      initialValue: _sortOrder,
      onSelected: _selectSortOrder,
      icon: const Icon(Icons.sort, color: AppColors.textSecondary),
      itemBuilder: (context) => [
        for (final order in MovieSortOrder.values)
          CheckedPopupMenuItem(
            value: order,
            checked: order == _sortOrder,
            child: Text(order.label),
          ),
      ],
    );
  }

  /// 4주차 Mock 전용: Empty·Error·Timeout 상태를 직접 확인하기 위한 메뉴입니다.
  Widget _buildLoadModeMenu() {
    return PopupMenuButton<MovieLoadMode>(
      tooltip: 'Mock 응답: ${_loadMode.label}',
      initialValue: _loadMode,
      onSelected: _changeLoadMode,
      icon: const Icon(
        Icons.bug_report_outlined,
        color: AppColors.textSecondary,
      ),
      itemBuilder: (context) => [
        for (final mode in MovieLoadMode.values)
          CheckedPopupMenuItem(
            value: mode,
            checked: mode == _loadMode,
            child: Text(mode.label),
          ),
      ],
    );
  }

  Widget _buildGenreChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _genres.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final genre = _genres[index];
          final isSelected = genre == _selectedGenre;
          return Align(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onTap: () => _selectGenre(genre),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
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
                  genre,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    color: isSelected
                        ? AppColors.white
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 16 / 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
