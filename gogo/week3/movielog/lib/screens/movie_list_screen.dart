import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_movies.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../widgets/movie_card.dart';
import '../widgets/genre_filter_sheet.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({
    super.key,
    this.initialQuery = '',
    this.initialGenres = const [],
  });

  final String initialQuery;
  final List<String> initialGenres;

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  late final TextEditingController _searchController;
  late Set<String> _selectedGenres;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _selectedGenres = widget.initialGenres.where(movieGenres.contains).toSet();
    _isSearching = widget.initialQuery.isNotEmpty;
  }

  @override
  void didUpdateWidget(covariant MovieListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery != widget.initialQuery &&
        _searchController.text != widget.initialQuery) {
      _searchController.value = TextEditingValue(
        text: widget.initialQuery,
        selection: TextSelection.collapsed(offset: widget.initialQuery.length),
      );
      _isSearching = widget.initialQuery.isNotEmpty;
    }
    if (oldWidget.initialGenres.join(',') != widget.initialGenres.join(',')) {
      _selectedGenres = widget.initialGenres
          .where(movieGenres.contains)
          .toSet();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Movie> get _filteredMovies {
    final query = _searchController.text.trim().toLowerCase();
    return mockMovies.where((movie) {
      final matchesQuery =
          query.isEmpty ||
          movie.title.toLowerCase().contains(query) ||
          movie.genre.toLowerCase().contains(query);
      final matchesGenre =
          _selectedGenres.isEmpty || _selectedGenres.contains(movie.genre);
      return matchesQuery && matchesGenre;
    }).toList();
  }

  void _syncRoute() {
    final query = _searchController.text.trim();
    final parameters = <String, String>{};
    if (query.isNotEmpty) parameters['q'] = query;
    if (_selectedGenres.isNotEmpty) {
      parameters['genre'] = _selectedGenres.join(',');
    }
    final location = Uri(
      path: '/movies',
      queryParameters: parameters.isEmpty ? null : parameters,
    ).toString();
    context.go(location);
  }

  Future<void> _openFilter() async {
    FocusScope.of(context).unfocus();
    final selected = await showModalBottomSheet<Set<String>>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => GenreFilterSheet(selectedGenres: _selectedGenres),
    );
    if (!mounted || selected == null) return;
    setState(() => _selectedGenres = selected);
    _syncRoute();
  }

  @override
  Widget build(BuildContext context) {
    final movies = _filteredMovies;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        centerTitle: false,
        title: Text(
          '영화',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: _isSearching ? '검색 닫기' : '영화 검색',
            onPressed: () {
              setState(() => _isSearching = !_isSearching);
              if (!_isSearching) {
                _searchController.clear();
                _syncRoute();
              }
            },
            icon: const Icon(
              Icons.search_rounded,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            tooltip: '장르 필터',
            onPressed: _openFilter,
            icon: Badge(
              isLabelVisible: _selectedGenres.isNotEmpty,
              label: Text('${_selectedGenres.length}'),
              child: const Icon(Icons.filter_alt_outlined),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _syncRoute(),
                decoration: InputDecoration(
                  hintText: '영화 제목 검색',
                  isDense: true,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: '검색어 지우기',
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                            _syncRoute();
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_selectedGenres.isEmpty ? "전체 장르" : _selectedGenres.join(" · ")} · ${movies.length}편',
              ),
            ),
          ),
          const SizedBox(height: 11),
          Expanded(
            child: movies.isEmpty
                ? const _EmptyMovies()
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: movies.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 20,
                      mainAxisExtent:
                          (MediaQuery.sizeOf(context).width - 58) / 2 / 0.69 +
                          82,
                    ),
                    itemBuilder: (context, index) => MovieCard(
                      movie: movies[index],
                      showScoreBadge: true,
                      showMetadata: true,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMovies extends StatelessWidget {
  const _EmptyMovies();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.movie_filter_outlined,
              size: 48,
              color: AppColors.hint,
            ),
            const SizedBox(height: 12),
            Text(
              '조건에 맞는 영화가 없어요',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 5),
            Text(
              '검색어나 장르 필터를 바꿔보세요.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
