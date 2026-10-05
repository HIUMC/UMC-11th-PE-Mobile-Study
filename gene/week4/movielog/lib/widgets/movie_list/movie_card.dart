import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/movies.dart';
import '../../theme/app_colors.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie});

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
