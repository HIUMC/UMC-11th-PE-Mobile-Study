import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/movies.dart';
import 'theme/app_colors.dart';
import 'widgets/app_bottom_nav_bar.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  static const _allGenre = '전체';
  static const _genres = [_allGenre, '드라마', 'SF', '애니메이션', '스릴러', '로맨스'];

  String _selectedGenre = _allGenre;

  List<Movie> get _filteredMovies => _selectedGenre == _allGenre
      ? movies
      : movies.where((movie) => movie.genre == _selectedGenre).toList();

  @override
  Widget build(BuildContext context) {
    final filteredMovies = _filteredMovies;

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
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
                mainAxisExtent: 316.5,
              ),
              itemCount: filteredMovies.length,
              itemBuilder: (context, index) =>
                  _MovieCard(movie: filteredMovies[index]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(current: NavTab.movies),
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
              onTap: () => setState(() => _selectedGenre = genre),
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

class _MovieCard extends StatelessWidget {
  const _MovieCard({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/movies/${movie.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowSubtle,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(movie.poster, fit: BoxFit.cover),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.overlayDark,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '★ ${movie.rating.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          color: AppColors.textOnDark,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          height: 16 / 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Manrope',
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 24 / 16,
            ),
          ),
          Opacity(
            opacity: 0.8,
            child: Text(
              '${movie.year} · ${movie.genre}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Manrope',
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 24 / 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
