import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_movies.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../widgets/movie_card.dart';

const _movieGenres = <String>[
  '드라마',
  'SF',
  '애니메이션',
  '스릴러',
  '액션',
  '로맨스',
  '다큐멘터리',
];

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
    _selectedGenres = widget.initialGenres.toSet();
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
      _selectedGenres = widget.initialGenres.toSet();
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
          SizedBox(
            height: 48,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              children: [
                _GenreChip(
                  label: '전체',
                  selected: _selectedGenres.isEmpty,
                  onTap: () {
                    setState(() => _selectedGenres.clear());
                    _syncRoute();
                  },
                ),
                ..._movieGenres.map(
                  (genre) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _GenreChip(
                      label: genre,
                      selected: _selectedGenres.contains(genre),
                      onTap: () {
                        setState(() {
                          if (!_selectedGenres.add(genre)) {
                            _selectedGenres.remove(genre);
                          }
                        });
                        _syncRoute();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          Expanded(
            child: movies.isEmpty
                ? const _EmptyMovies()
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: movies.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.57,
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

class _GenreChip extends StatelessWidget {
  const _GenreChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 13,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.primaryTint,
      side: BorderSide.none,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
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
