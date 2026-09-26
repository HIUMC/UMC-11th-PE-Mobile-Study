import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/movies.dart';
import 'theme/app_colors.dart';
import 'widgets/app_bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _featuredMovieId = '1';

  // 별점 높은 순 상위 3편
  List<Movie> get _popularMovies => ([
    ...movies,
  ]..sort((a, b) => b.rating.compareTo(a.rating))).take(3).toList();

  @override
  Widget build(BuildContext context) {
    final featuredMovie = findMovieById(_featuredMovieId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: const Text(
          'MovieLog',
          style: TextStyle(
            fontFamily: 'Manrope',
            color: AppColors.primaryDark,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.55,
            height: 28 / 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.primaryDark),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '오늘은 어떤\n영화를 볼까요?',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.7,
                    height: 36 / 28,
                  ),
                ),
              ),
              if (featuredMovie != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: _FeaturedMovieBanner(movie: featuredMovie),
                ),
              _PopularMoviesSection(movies: _popularMovies),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(current: NavTab.home),
    );
  }
}

class _FeaturedMovieBanner extends StatelessWidget {
  const _FeaturedMovieBanner({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: AppColors.surfaceVariant),
            Image.asset(movie.poster, fit: BoxFit.cover),
            Container(color: Colors.black.withValues(alpha: 0.7)),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark90,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Text(
                      '추천 신작',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      height: 36 / 28,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      movie.genre,
                      if (movie.runtime != null) '${movie.runtime}분',
                    ].join(' · '),
                    style: TextStyle(
                      color: AppColors.textOnImage.withValues(alpha: 0.9),
                      fontSize: 16,
                      height: 24 / 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/movies/${movie.id}'),
                      icon: const Icon(Icons.info_outline, size: 17),
                      label: const Text('상세보기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: AppColors.white,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularMoviesSection extends StatelessWidget {
  const _PopularMoviesSection({required this.movies});

  final List<Movie> movies;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '인기 영화',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  height: 28 / 22,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/movies'),
                child: const Row(
                  children: [
                    Text(
                      '전체보기',
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 24 / 16,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.primaryDark,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 272,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: movies.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              if (index == movies.length) {
                return const _UpcomingMovieCard();
              }
              return _MovieCard(rank: index + 1, movie: movies[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({required this.rank, required this.movie});

  final int rank;
  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: GestureDetector(
        onTap: () => context.push('/movies/${movie.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 140,
                    height: 200,
                    color: AppColors.surfaceVariant,
                    child: Image.asset(movie.poster, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text(
                      '$rank',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 24 / 16,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 12),
                const SizedBox(width: 4),
                Text(
                  movie.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 16 / 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingMovieCard extends StatelessWidget {
  const _UpcomingMovieCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 140,
              height: 200,
              color: AppColors.surfaceContainer,
              child: const Center(
                child: Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.primaryDark,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '개봉 예정작',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 24 / 16,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'D-5',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              height: 16 / 12,
            ),
          ),
        ],
      ),
    );
  }
}
