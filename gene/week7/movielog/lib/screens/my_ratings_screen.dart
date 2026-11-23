import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/data/models/rating_with_movie.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_style.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';
import 'package:movielog/widgets/common_app_bar.dart';
import 'package:movielog/widgets/movie_list/movie_list_error.dart';
import 'package:movielog/widgets/movie_list/scrollable_fill.dart';
import 'package:movielog/widgets/movie_poster_image.dart';
import 'package:movielog/widgets/movielog_button.dart';
import 'package:movielog/widgets/rating_dialog.dart';

/// 내가 등록한 평점 목록 화면입니다. (경로: /my/ratings)
/// 하위 화면이라 하단 NavigationBar 없이 뒤로가기 버튼만 둡니다.
class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MyRatingsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(
        title: '내가 등록한 평점',
        centerTitle: true,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: viewModel.load,
          child: _buildBody(viewModel),
        ),
      ),
    );
  }

  Widget _buildBody(MyRatingsViewModel viewModel) {
    switch (viewModel.status) {
      case MyRatingsLoadStatus.idle:
      case MyRatingsLoadStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      case MyRatingsLoadStatus.error:
        return MovieListError(
          message: viewModel.message ?? '평점을 불러오지 못했습니다.',
          onRetry: viewModel.load,
        );
      case MyRatingsLoadStatus.empty:
        return const ScrollableFill(
          child: Text('아직 등록한 평점이 없습니다.', style: AppTextStyles.bodyMedium),
        );
      case MyRatingsLoadStatus.success:
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          // 일부 영화 정보를 못 가져왔다면 맨 위에 안내 문구를 한 줄 둡니다.
          itemCount:
              viewModel.ratings.length + (viewModel.message != null ? 1 : 0),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (viewModel.message != null) {
              if (index == 0) {
                return Text(viewModel.message!, style: AppTextStyles.bodySmall);
              }
              index--;
            }
            return _RatingTile(item: viewModel.ratings[index]);
          },
        );
    }
  }
}

class _RatingTile extends StatelessWidget {
  const _RatingTile({required this.item});

  final RatingWithMovie item;

  Future<void> _onEditPressed(BuildContext context, RatingDto rating) async {
    final viewModel = context.read<MyRatingsViewModel>();
    // 저장 후 목록을 다시 불러오면 이 타일이 새로 만들어져 context가 사라지므로,
    // SnackBar를 띄울 ScaffoldMessenger를 미리 잡아 둡니다.
    final messenger = ScaffoldMessenger.of(context);
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 저장 중 바깥 탭으로 닫히는 것도 막습니다.
      builder: (_) => RatingDialog(
        initialScore: rating.score,
        initialComment: rating.comment, // null이면 TextField가 빈 칸으로 시작합니다.
        onSubmit: (score, comment) => viewModel.updateRating(
          ratingId: rating.ratingId,
          score: score,
          comment: comment,
        ),
      ),
    );

    if (saved != true || !messenger.mounted) return;
    // 저장은 됐지만 목록 새로고침이 실패했다면 그 안내를, 아니면 완료 문구를 보여줍니다.
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(viewModel.refreshWarning ?? '평점을 수정했어요'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _onDeletePressed(BuildContext context, RatingDto rating) async {
    final viewModel = context.read<MyRatingsViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 삭제 중 바깥 탭으로 닫히는 것도 막습니다.
      builder: (_) => _DeleteRatingDialog(
        onConfirm: () => viewModel.deleteRating(rating.ratingId),
      ),
    );
    // confirmed는 실제로 삭제까지 마쳤을 때만 true입니다.
    if (confirmed != true || !messenger.mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(viewModel.refreshWarning ?? '평점을 삭제했어요'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final rating = item.rating;
    final movie = item.movie;
    // TMDB에서 영화를 못 찾으면 ID로 대신 표시합니다.
    final title = movie?.title ?? '영화 #${rating.movieId}';
    final date = rating.createdAt.toLocal();
    final dateText =
        '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 90,
              child: MoviePosterImage(movie?.posterUrl ?? ''),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('${rating.score}', style: AppTextStyles.bodyMedium),
                    const SizedBox(width: 8),
                    Text(dateText, style: AppTextStyles.bodySmall),
                  ],
                ),
                if (rating.comment case final comment?
                    when comment.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    comment,
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                tooltip: '평점 수정',
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                onPressed: () => _onEditPressed(context, rating),
              ),
              IconButton(
                tooltip: '평점 삭제',
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () => _onDeletePressed(context, rating),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeleteRatingDialog extends StatefulWidget {
  const _DeleteRatingDialog({required this.onConfirm});
  final Future<void> Function() onConfirm;

  @override
  State<_DeleteRatingDialog> createState() => _DeleteRatingDialogState();
}

class _DeleteRatingDialogState extends State<_DeleteRatingDialog> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDeleting,
      child: AlertDialog(
        title: const Text('평점을 삭제할까요?'),
        content: const Text('삭제한 평점은 복구할 수 없습니다.'),
        actions: [
          MovieLogButton(
            label: '취소',
            onPressed: _isDeleting ? null : () => Navigator.pop(context, false),
          ),
          MovieLogButton(
            label: '삭제',
            isLoading: _isDeleting,
            onPressed: _isDeleting ? null : _onConfirm,
          ),
        ],
      ),
    );
  }

  Future<void> _onConfirm() async {
    setState(() => _isDeleting = true);
    try {
      await widget.onConfirm();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제하지 못했습니다. 잠시 후 다시 시도해 주세요.')),
      );
    }
  }
}
