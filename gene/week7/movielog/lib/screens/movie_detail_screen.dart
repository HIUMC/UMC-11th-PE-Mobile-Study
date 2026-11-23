import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:movielog/data/favorites.dart';
import 'package:movielog/data/movies.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/movie_poster_image.dart';
import 'package:movielog/widgets/rating_dialog.dart';
import 'package:movielog/view_models/movie_detail_view_model.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key, required this.movieId, this.movie});

  final String movieId;

  /// 목록에서 넘겨준 영화. TMDB 영화는 로컬 데이터에 없으므로 이 값을 먼저 씁니다.
  final Movie? movie;

  @override
  Widget build(BuildContext context) {
    final movie = this.movie ?? findMovieById(movieId);

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
                child: MoviePosterImage(movie.detailPoster ?? movie.poster),
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

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _onRatePressed(BuildContext context) async {
    final viewModel = context.read<MovieDetailViewModel>();
    // 평점은 회원 ID로 서버에 저장하므로, 가입 전이면 다이얼로그를 열지 않습니다.
    if (viewModel.memberId == null) {
      _showSnackBar(context, '먼저 회원가입을 완료해 주세요.');
      return;
    }

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 저장 중 바깥 탭으로 닫히는 것도 막습니다.
      builder: (_) => RatingDialog(
        onSubmit: (score, comment) =>
            viewModel.createRating(score: score, comment: comment),
      ),
    );
    if (saved != true || !context.mounted) return;
    _showSnackBar(context, '평점을 등록했어요');
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
