import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_movies.dart';
import '../data/movie_store.dart';
import '../theme/app_colors.dart';
import '../widgets/movie_card.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = MovieStore.instance;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, child) {
          final favorites = mockMovies
              .where((movie) => store.isFavorite(movie.id))
              .toList();
          final ratings = store.userRatings.values.toList();
          final averageRating = ratings.isEmpty
              ? '—'
              : (ratings.reduce((a, b) => a + b) / ratings.length)
                    .toStringAsFixed(1);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.45),
                          width: 2,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage(
                          'assets/images/profile/profile_movielog.jpg',
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '무비러버',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '좋은 영화를 보고 기록하는 것을 좋아합니다.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context)
                          .showSnackBar(
                            const SnackBar(
                              content: Text('프로필 수정은 준비 중이에요.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          ),
                      icon: const Icon(Icons.edit_outlined, size: 17),
                      label: const Text('프로필 수정'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: '평점 남긴 영화',
                      value: '${ratings.length}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(label: '내 평점 평균', value: averageRating),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: '즐겨찾기',
                      value: '${favorites.length}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '즐겨찾는 영화',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/movies'),
                    child: const Text('영화 찾기'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (favorites.isEmpty)
                _EmptyFavorites(onExplore: () => context.go('/movies'))
              else
                SizedBox(
                  height: 284,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: favorites.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 14),
                    itemBuilder: (context, index) =>
                        MovieCard(movie: favorites[index], width: 148),
                  ),
                ),
              const SizedBox(height: 28),
              Text(
                '선호 장르',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 13),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _GenreTag(label: '드라마'),
                  _GenreTag(label: 'SF'),
                  _GenreTag(label: '미스터리'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 78),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.bookmark_border_rounded,
            size: 34,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          const Text('아직 찜한 영화가 없어요'),
          const SizedBox(height: 10),
          TextButton(onPressed: onExplore, child: const Text('영화 둘러보기')),
        ],
      ),
    );
  }
}

class _GenreTag extends StatelessWidget {
  const _GenreTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: AppColors.primaryTint,
      side: BorderSide.none,
      labelStyle: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
