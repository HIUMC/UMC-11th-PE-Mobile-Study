import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 로컬 asset 경로와 TMDB 이미지 URL을 모두 그립니다.
/// 포스터가 없거나 불러오지 못하면 아이콘 placeholder를 보여줍니다.
class MoviePosterImage extends StatelessWidget {
  const MoviePosterImage(this.source, {super.key, this.fit = BoxFit.cover});

  final String source;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (source.isEmpty) return const _PosterPlaceholder();

    if (source.startsWith('http')) {
      return Image.network(
        source,
        fit: fit,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const ColoredBox(color: AppColors.surfaceVariant),
        errorBuilder: (context, error, stackTrace) =>
            const _PosterPlaceholder(),
      );
    }
    return Image.asset(source, fit: fit);
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          color: AppColors.textTertiary,
          size: 32,
        ),
      ),
    );
  }
}
