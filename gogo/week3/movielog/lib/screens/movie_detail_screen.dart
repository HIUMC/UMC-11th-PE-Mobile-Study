import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/movie_store.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../widgets/movie_rating_input.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movie});

  final Movie? movie;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Future<void> _openRatingDialog(Movie movie) async {
    final rating = await showDialog<double>(
      context: context,
      builder: (context) => RatingDialog(movieTitle: movie.title),
    );
    if (rating == null || !mounted) return;

    MovieStore.instance.saveRating(movie.id, rating);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('내 평점 ${rating.toStringAsFixed(1)}점을 기록했어요.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleFavorite(Movie movie) {
    final store = MovieStore.instance;
    final wasFavorite = store.isFavorite(movie.id);
    store.toggleFavorite(movie.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(wasFavorite ? '즐겨찾기에서 삭제했어요.' : '즐겨찾기에 추가했어요.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    if (movie == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/movies'),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text('영화를 찾을 수 없어요'),
        ),
        body: const Center(child: Text('요청하신 영화 정보가 없습니다.')),
      );
    }

    final textTheme = Theme.of(context).textTheme;
    final store = MovieStore.instance;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: '뒤로 가기',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/movies'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('영화 상세'),
        actions: [
          AnimatedBuilder(
            animation: store,
            builder: (context, child) {
              final favorite = store.isFavorite(movie.id);
              return IconButton(
                tooltip: favorite ? '즐겨찾기 해제' : '즐겨찾기 추가',
                onPressed: () => _toggleFavorite(movie),
                icon: Icon(
                  favorite
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: favorite ? AppColors.primary : AppColors.textPrimary,
                ),
              );
            },
          ),
          IconButton(
            tooltip: '공유',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('공유 기능은 준비 중이에요.'),
                behavior: SnackBarBehavior.floating,
              ),
            ),
            icon: const Icon(Icons.ios_share_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, child) {
          final userRating = store.ratingFor(movie.id);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 1.45,
                    child: Image.asset(
                      movie.posterAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const ColoredBox(
                            color: AppColors.cardSurface,
                            child: Icon(Icons.movie_outlined, size: 54),
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(label: movie.genre),
                    _InfoChip(label: '${movie.year}년'),
                    _InfoChip(label: '${movie.runtime}분'),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  movie.title,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    MovieRatingIndicator(rating: movie.rating, itemSize: 20),
                    const SizedBox(width: 8),
                    Text(
                      movie.rating.toStringAsFixed(1),
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '관객 평점',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _openRatingDialog(movie),
                        icon: const Icon(Icons.star_rounded),
                        label: Text(
                          userRating == null
                              ? '평점 남기기'
                              : '내 평점 ${userRating.toStringAsFixed(1)}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () => _toggleFavorite(movie),
                      icon: Icon(
                        store.isFavorite(movie.id)
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_add_outlined,
                      ),
                      label: const Text('찜하기'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  '줄거리',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  movie.synopsis,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.65,
                  ),
                ),
                const SizedBox(height: 25),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 16),
                _CreditRow(label: '감독', value: movie.director),
                const SizedBox(height: 14),
                _CreditRow(label: '장르', value: movie.genre),
                const SizedBox(height: 14),
                _CreditRow(label: '개봉 연도', value: '${movie.year}년'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _CreditRow extends StatelessWidget {
  const _CreditRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key, required this.movieTitle});

  final String movieTitle;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardSurface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 26),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_movies_rounded,
              color: AppColors.primary,
              size: 30,
            ),
            const SizedBox(height: 12),
            Text(
              '영화는 어떠셨나요?',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              widget.movieTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            MovieRatingInput(
              rating: _rating,
              onChanged: (value) => setState(() => _rating = value),
              itemSize: 38,
            ),
            const SizedBox(height: 8),
            Text(
              _rating == 0
                  ? '별을 눌러 평점을 선택하세요'
                  : '${_rating.toStringAsFixed(1)}점',
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: _rating == 0
                        ? null
                        : () => Navigator.of(context).pop(_rating),
                    child: const Text('기록하기'),
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
