import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

import 'data/favorites.dart';
import 'data/movies.dart';
import 'data/my_ratings.dart';
import 'theme/app_colors.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final String movieId;

  @override
  Widget build(BuildContext context) {
    final movie = findMovieById(movieId);

    if (movie == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: const Center(
          child: Text(
            '영화를 찾을 수 없어요',
            style: TextStyle(
              fontFamily: 'Manrope',
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Container(
                color: AppColors.surfaceNeutral,
                child: Image.asset(
                  movie.detailPoster ?? movie.poster,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            _InfoSection(movie: movie),
            if (movie.synopsis.isNotEmpty)
              _SynopsisSection(paragraphs: movie.synopsis),
          ],
        ),
      ),
      bottomNavigationBar: _ActionButtons(movie: movie),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        onPressed: () =>
            context.canPop() ? context.pop() : context.go('/movies'),
      ),
      title: const Text(
        'Cinema Archive',
        style: TextStyle(
          fontFamily: 'Manrope',
          color: AppColors.primary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          height: 28 / 22,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.share_outlined,
            color: AppColors.textSecondary,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie.title,
            style: const TextStyle(
              fontFamily: 'Manrope',
              color: AppColors.textHeading,
              fontSize: 28,
              fontWeight: FontWeight.w500,
              height: 36 / 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            [
              '${movie.year}',
              movie.genre,
              if (movie.runtime != null) '${movie.runtime}분',
            ].join(' • '),
            style: const TextStyle(
              fontFamily: 'Manrope',
              color: AppColors.textSecondary,
              fontSize: 14,
              letterSpacing: 0.25,
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              RatingBarIndicator(
                rating: movie.rating,
                itemSize: 17,
                unratedColor: AppColors.surfaceVariant,
                itemBuilder: (context, index) =>
                    const Icon(Icons.star_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text(
                movie.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  color: AppColors.textHeading,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.15,
                  height: 24 / 16,
                ),
              ),
              if (movie.ratingCount != null) ...[
                const SizedBox(width: 4),
                Text(
                  '(${movie.ratingCount})',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    letterSpacing: 0.25,
                    height: 20 / 14,
                  ),
                ),
              ],
            ],
          ),
          if (movie.tags.isNotEmpty) ...[
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final tag in movie.tags) _TagChip(label: tag)],
            ),
          ],
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceNeutral,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Manrope',
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 20 / 14,
        ),
      ),
    );
  }
}

class _SynopsisSection extends StatelessWidget {
  const _SynopsisSection({required this.paragraphs});

  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '시놉시스',
            style: TextStyle(
              fontFamily: 'Manrope',
              color: AppColors.textHeading,
              fontSize: 22,
              fontWeight: FontWeight.w500,
              height: 28 / 22,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < paragraphs.length; i++) ...[
            if (i > 0) const SizedBox(height: 26),
            Text(
              paragraphs[i],
              style: const TextStyle(
                fontFamily: 'Manrope',
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                height: 26 / 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.movie});

  final Movie movie;

  void _onFavoritePressed(BuildContext context) {
    final added = toggleFavorite(movie.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(added ? '즐겨찾기에 추가했어요' : '즐겨찾기에서 삭제했어요'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _onRatePressed(BuildContext context) async {
    final rating = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: AppColors.background,
      showDragHandle: true,
      builder: (context) => _RatingSheet(
        movieTitle: movie.title,
        initialRating: myRatingOf(movie.id) ?? 0,
      ),
    );
    if (rating == null || !context.mounted) return;

    saveMyRating(movie.id, rating);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('평점 ${rating.toStringAsFixed(1)}점을 남겼어요'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  static const _labelStyle = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 20 / 14,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: favoriteMovieIds,
                builder: (context, ids, _) {
                  final favorite = ids.contains(movie.id);
                  return OutlinedButton.icon(
                    onPressed: () => _onFavoritePressed(context),
                    icon: Icon(
                      favorite ? Icons.bookmark : Icons.bookmark_border,
                      size: 18,
                    ),
                    label: const Text('즐겨찾기', style: _labelStyle),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: const StadiumBorder(),
                      minimumSize: const Size.fromHeight(48),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _onRatePressed(context),
                icon: const Icon(Icons.rate_review_outlined, size: 20),
                label: const Text('평점 남기기', style: _labelStyle),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: const StadiumBorder(),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingSheet extends StatefulWidget {
  const _RatingSheet({required this.movieTitle, required this.initialRating});

  final String movieTitle;
  final double initialRating;

  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet> {
  late double _rating = widget.initialRating;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.movieTitle,
              style: const TextStyle(
                fontFamily: 'Manrope',
                color: AppColors.textHeading,
                fontSize: 22,
                fontWeight: FontWeight.w500,
                height: 28 / 22,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '이 영화는 어떠셨나요?',
              style: TextStyle(
                fontFamily: 'Manrope',
                color: AppColors.textSecondary,
                fontSize: 14,
                letterSpacing: 0.25,
                height: 20 / 14,
              ),
            ),
            const SizedBox(height: 24),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 0.5,
              allowHalfRating: true,
              glow: false,
              itemSize: 40,
              itemPadding: const EdgeInsets.symmetric(horizontal: 2),
              unratedColor: AppColors.surfaceVariant,
              itemBuilder: (context, _) =>
                  const Icon(Icons.star_rounded, color: AppColors.primary),
              onRatingUpdate: (rating) => setState(() => _rating = rating),
            ),
            const SizedBox(height: 12),
            Text(
              _rating == 0 ? '별을 눌러 평가해 주세요' : '${_rating.toStringAsFixed(1)}점',
              style: const TextStyle(
                fontFamily: 'Manrope',
                color: AppColors.textHeading,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 24 / 16,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _rating == 0
                  ? null
                  : () => Navigator.of(context).pop(_rating),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: AppColors.primaryDisabled,
                disabledForegroundColor: AppColors.white,
                shape: const StadiumBorder(),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text(
                '등록',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
