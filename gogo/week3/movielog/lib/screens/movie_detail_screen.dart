import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../data/movie_store.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../widgets/movie_rating_input.dart';
import '../widgets/rating_dialog.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movie});

  final Movie? movie;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  void _goBack() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    context.canPop() ? context.pop() : context.go('/movies');
  }

  Future<void> _openRatingDialog(Movie movie) async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    final previousRating = MovieStore.instance.ratingFor(movie.id);
    final rating = await showDialog<double>(
      context: context,
      builder: (context) => RatingDialog(
        movieTitle: movie.title,
        initialRating: previousRating ?? 0,
      ),
    );
    if (rating == null || !mounted) return;

    MovieStore.instance.saveRating(movie.id, rating);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
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
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
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
          title: const Text('Cinema Archive'),
          leading: IconButton(
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: const Center(child: Text('요청하신 영화 정보가 없습니다.')),
      );
    }

    final store = MovieStore.instance;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 44,
        title: const Text(
          'Cinema Archive',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          tooltip: '뒤로 가기',
          onPressed: _goBack,
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        actions: [
          IconButton(
            tooltip: '공유',
            onPressed: () => ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('공유 기능은 준비 중이에요.'),
                  behavior: SnackBarBehavior.floating,
                ),
              ),
            icon: SvgPicture.asset(
              'assets/icons/share.svg',
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                AppColors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: store,
        builder: (context, child) {
          final userRating = store.ratingFor(movie.id);
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(17, 10, 17, 9),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _toggleFavorite(movie),
                      icon: Icon(
                        store.isFavorite(movie.id)
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        size: 17,
                      ),
                      label: Text(
                        store.isFavorite(movie.id) ? '즐겨찾기 해제' : '즐겨찾기',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        minimumSize: const Size(0, 42),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _openRatingDialog(movie),
                      icon: const Icon(Icons.rate_review_outlined, size: 17),
                      label: Text(userRating == null ? '평점 남기기' : '평점 수정하기'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 42),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, child) {
          final userRating = store.ratingFor(movie.id);
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  key: const ValueKey("movie-detail-scroll"),
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 0.68,
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(17, 14, 17, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              style: textTheme.titleLarge?.copyWith(
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${movie.year} · ${movie.detailGenre ?? movie.genre} · ${movie.runtime}분',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                MovieRatingIndicator(
                                  rating: movie.rating,
                                  itemSize: 15,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  '${movie.rating.toStringAsFixed(1)} (${_formatCount(movie.ratingCount)})',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontSize: 11,
                                  ),
                                ),
                                if (userRating != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '내 평점 ${userRating.toStringAsFixed(1)}',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 7,
                              runSpacing: 7,
                              children: movie.tags
                                  .map((tag) => _GenreTag(label: tag))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.divider),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(17, 10, 17, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '시놉시스',
                              style: textTheme.titleMedium?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              movie.synopsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                height: 1.52,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _formatCount(int count) {
  final digits = count.toString();
  return digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
}

class _GenreTag extends StatelessWidget {
  const _GenreTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: AppColors.textSecondary, fontSize: 10),
        ),
      ),
    );
  }
}
