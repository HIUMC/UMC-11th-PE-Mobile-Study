import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_movies.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../widgets/movie_card.dart';

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

  List<String> get _genres =>
      mockMovies.map((movie) => movie.genre).toSet().toList();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _selectedGenres = widget.initialGenres.toSet();
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
    }).toList()..sort((left, right) => right.rating.compareTo(left.rating));
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

  Future<void> _openGenreFilter() async {
    final selected = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          GenreFilterSheet(genres: _genres, selectedGenres: _selectedGenres),
    );
    if (selected == null || !mounted) return;
    setState(() => _selectedGenres = selected.toSet());
    _syncRoute();
  }

  @override
  Widget build(BuildContext context) {
    final movies = _filteredMovies;

    return Scaffold(
      appBar: AppBar(
        title: const Text('영화'),
        actions: [
          IconButton(
            tooltip: '장르 필터',
            onPressed: _openGenreFilter,
            icon: Badge(
              isLabelVisible: _selectedGenres.isNotEmpty,
              label: Text('${_selectedGenres.length}'),
              child: const Icon(Icons.tune_rounded),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _syncRoute(),
              decoration: InputDecoration(
                hintText: '영화 제목이나 장르를 검색해보세요',
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
            height: 42,
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
                ..._genres.map(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Text(
                  '전체 영화',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 8),
                Text(
                  '${movies.length}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.swap_vert_rounded, size: 18),
                const SizedBox(width: 4),
                Text('평점순', style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          ),
          Expanded(
            child: movies.isEmpty
                ? const _EmptyMovies()
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: movies.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 18,
                          childAspectRatio: 0.62,
                        ),
                    itemBuilder: (context, index) =>
                        MovieCard(movie: movies[index]),
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
      backgroundColor: AppColors.cardSurface,
      side: BorderSide(color: selected ? AppColors.primary : AppColors.divider),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 7),
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

class GenreFilterSheet extends StatefulWidget {
  const GenreFilterSheet({
    super.key,
    required this.genres,
    required this.selectedGenres,
  });

  final List<String> genres;
  final Set<String> selectedGenres;

  @override
  State<GenreFilterSheet> createState() => _GenreFilterSheetState();
}

class _GenreFilterSheetState extends State<GenreFilterSheet> {
  late final Set<String> _selection = {...widget.selectedGenres};

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.42,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '장르 필터',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(_selection.clear),
                      child: const Text('초기화'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: widget.genres.length,
                  itemBuilder: (context, index) {
                    final genre = widget.genres[index];
                    return CheckboxListTile(
                      value: _selection.contains(genre),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selection.add(genre);
                          } else {
                            _selection.remove(genre);
                          }
                        });
                      },
                      title: Text(genre),
                      activeColor: AppColors.primary,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_selection.toList()),
                    child: const Text('영화 보기'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
