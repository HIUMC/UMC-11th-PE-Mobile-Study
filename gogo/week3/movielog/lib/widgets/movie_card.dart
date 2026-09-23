import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/movie_store.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';
import 'movie_rating_input.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movie,
    this.width,
    this.showFavoriteButton = true,
  });

  final Movie movie;
  final double? width;
  final bool showFavoriteButton;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final store = MovieStore.instance;

    return SizedBox(
      width: width,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.push('/movies/${movie.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 0.72,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      movie.posterAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const ColoredBox(
                            color: AppColors.cardSurface,
                            child: Icon(Icons.movie_outlined, size: 42),
                          ),
                    ),
                    if (showFavoriteButton)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: AnimatedBuilder(
                          animation: store,
                          builder: (context, child) {
                            final isFavorite = store.isFavorite(movie.id);
                            return Material(
                              color: Colors.black.withValues(alpha: 0.38),
                              shape: const CircleBorder(),
                              child: IconButton(
                                tooltip: isFavorite ? '즐겨찾기 해제' : '즐겨찾기',
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  store.toggleFavorite(movie.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isFavorite
                                            ? '즐겨찾기에서 삭제했어요.'
                                            : '즐겨찾기에 추가했어요.',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  isFavorite
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                MovieRatingIndicator(rating: movie.rating, itemSize: 14),
                const SizedBox(width: 4),
                Text(
                  movie.rating.toStringAsFixed(1),
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
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
