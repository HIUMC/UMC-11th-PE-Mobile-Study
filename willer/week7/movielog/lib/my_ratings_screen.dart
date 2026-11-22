import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Consumer 사용 가능

import 'data/models/rating_dto.dart';
import 'data/models/rating_with_movie.dart';
import 'data/services/rating_api_service.dart'; // writeErrorMessage 사용
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'view_models/my_ratings_view_model.dart';
import 'widgets/loading_overlay.dart';
import 'widgets/movie_list_states.dart'; // 로딩, 에러 화면을 재사용
import 'widgets/movielog_button.dart';
import 'widgets/rating_dialog.dart';
import 'widgets/tmdb_poster_image.dart';

Future<void> onEditPressed(BuildContext context, RatingDto rating) async {
  await showDialog<bool>(
    context: context,
    barrierDismissible: false, // 저장 중 바깥 탭으로 닫히는 것도 막음
    builder: (_) => RatingDialog(
      initialScore: rating.score, // 기존 값을 채워서 열기
      initialComment: rating.comment, // null이면 빈 칸으로 시작
      onSubmit: (score, comment) => context.read<MyRatingsViewModel>().updateRating(
            ratingId: rating.ratingId,
            score: score,
            comment: comment,
          ),
    ),
  ); // 성공하면 ViewModel이 이미 재조회해서 화면에서 더 할 일이 없음
}

Future<void> onDeletePressed(BuildContext context, RatingDto rating) async {
  await showDialog<bool>(
    context: context,
    barrierDismissible: false, // 삭제 중 바깥 탭으로 닫히는 것도 막음
    builder: (_) => _DeleteRatingDialog(
      onConfirm: () => context.read<MyRatingsViewModel>().deleteRating(rating.ratingId),
    ),
  ); // true는 실제로 삭제까지 마쳤을 때만
}

Future<void> onDeleteSelectedPressed(BuildContext context) async {
  final viewModel = context.read<MyRatingsViewModel>();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => const _DeleteRatingDialog(title: '선택한 평점을 삭제할까요?'), // onConfirm이 없어서 삭제를 누르면 바로 닫힘
  );
  if (confirmed != true || !context.mounted) return; // 취소하면 요청을 보내지 않음

  final failed = await viewModel.deleteSelectedRatings(); // 로딩은 Dialog가 아니라 화면 위 오버레이가 보여줌
  if (!context.mounted || failed == 0) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$failed개 항목을 삭제하지 못했습니다. 선택된 항목을 다시 확인해 주세요.')),
  );
}

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MyRatingsViewModel>( // status, 편집 모드, 선택이 바뀔 때마다 다시 그림
      builder: (context, viewModel, child) {
        final selectedCount = viewModel.selectedRatingIds.length;
        return PopScope( // 다중 삭제 중에는 화면을 못 나감
          canPop: !viewModel.isDeletingSelected,
          child: LoadingOverlay( // 다중 삭제 중이면 AppBar까지 덮는 막과 인디케이터
            isLoading: viewModel.isDeletingSelected,
            child: Scaffold( // bottomNavigationBar를 편집 모드에서만 넘김
              appBar: AppBar( // push로 열려서 왼쪽 뒤로가기 버튼이 자동으로 생김
                title: const Text('내가 등록한 평점', style: AppTextStyles.appBarTitle),
                centerTitle: true,
              ),
              body: SafeArea(
                child: switch (viewModel.status) { // 상태 하나당 위젯 하나
                  MyRatingsLoadStatus.idle ||
                  MyRatingsLoadStatus.loading => const MovieListLoading(),
                  MyRatingsLoadStatus.error => MovieListError(
                      message: viewModel.refreshWarning ?? viewModel.message, // 저장 뒤 재조회만 실패했으면 그 안내를 우선
                      onRetry: viewModel.load, // 다시 시도하면 처음부터 다시 불러옴
                    ),
                  MyRatingsLoadStatus.empty => const Center(
                      child: Text('아직 등록한 평점이 없습니다.', style: AppTextStyles.bodySmall),
                    ),
                  MyRatingsLoadStatus.success => ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        Row( // 왼쪽 선택 수, 오른쪽 편집 또는 취소
                          children: [
                            if (viewModel.isEditing)
                              Text('$selectedCount개 선택됨', style: AppTextStyles.linkText),
                            const Spacer(), // 남은 가로 공간을 채워서 버튼을 오른쪽 끝으로 밈
                            TextButton(
                              onPressed: viewModel.isEditing
                                  ? viewModel.cancelEditing
                                  : viewModel.startEditing,
                              child: Text(
                                viewModel.isEditing ? '취소' : '편집',
                                style: AppTextStyles.linkText,
                              ),
                            ),
                          ],
                        ),
                        if (viewModel.message != null) ...[ // 일부 영화 정보를 못 가져왔을 때만 안내
                          Text(viewModel.message!, style: AppTextStyles.bodySmall),
                          const SizedBox(height: 12),
                        ],
                        for (final entry in viewModel.ratings)
                          viewModel.isEditing
                              ? _SelectableRatingCard(
                                  entry: entry,
                                  isSelected: viewModel.selectedRatingIds.contains(entry.rating.ratingId),
                                  onToggle: () => viewModel.toggleSelection(entry.rating.ratingId),
                                )
                              : RatingCard(entry: entry),
                      ],
                    ),
                },
              ),
              bottomNavigationBar: viewModel.isEditing
                  ? SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        child: MovieLogButton(
                          label: '선택한 $selectedCount개 삭제',
                          width: double.infinity,
                          borderRadius: 22, // 높이 44의 절반이라 알약 모양
                          onPressed: selectedCount > 0 ? () => onDeleteSelectedPressed(context) : null, // 1개 이상 골라야 활성
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}

class RatingCard extends StatelessWidget { // 평점 카드 하나. 포스터, 제목, 별점, 후기, 등록일, 수정과 삭제 버튼
  const RatingCard({super.key, required this.entry});

  final RatingWithMovie entry;

  @override
  Widget build(BuildContext context) {
    final rating = entry.rating;
    final movie = entry.movie; // TMDB에서 못 찾았으면 null
    final date = rating.createdAt.toIso8601String().substring(0, 10); // 날짜 부분만

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.violetLight, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // 포스터와 글 묶음을 위쪽에 맞춤
        children: [
          ClipRRect( // 포스터 모서리를 둥글게 자름
            borderRadius: BorderRadius.circular(8),
            child: TmdbPosterImage(
              posterPath: movie?.posterPath, // movie가 null이면 posterPath도 null이라 대체 이미지
              width: 82,
              height: 124,
            ),
          ),
          const SizedBox(width: 16),
          Expanded( // 포스터를 뺀 나머지 너비를 글이 차지
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie?.title ?? '영화 #${rating.movieId}', // 영화 정보가 없으면 movieId로 대신함
                  style: AppTextStyles.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '별점 ${rating.score} / 5',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.violet,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (movie == null) ...[
                  const SizedBox(height: 8),
                  const Text('포스터 정보 없음', style: AppTextStyles.bodySmall),
                ],
                if (rating.comment != null) ...[ // 후기가 없으면 줄과 간격을 통째로 뺌
                  const SizedBox(height: 8),
                  Text(rating.comment!, style: AppTextStyles.bodySmall),
                ],
                const SizedBox(height: 8),
                Text(date, style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column( // 카드 오른쪽 수정, 삭제 버튼
            children: [
              _CardActionButton(
                label: '수정',
                backgroundColor: AppColors.violetSoft,
                foregroundColor: AppColors.violet,
                onPressed: () => onEditPressed(context, rating),
              ),
              const SizedBox(height: 8),
              _CardActionButton(
                label: '삭제',
                backgroundColor: AppColors.errorFill,
                foregroundColor: AppColors.error,
                onPressed: () => onDeletePressed(context, rating),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectableRatingCard extends StatelessWidget { // 편집 모드 카드. 포스터와 수정, 삭제 버튼 대신 CheckBox
  const _SelectableRatingCard({
    required this.entry,
    required this.isSelected,
    required this.onToggle,
  });

  final RatingWithMovie entry;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final rating = entry.rating;
    final title = entry.movie?.title ?? '영화 #${rating.movieId}'; // 영화 정보가 없으면 movieId로 대신함

    return GestureDetector( // 카드 어디를 눌러도 선택이 바뀜
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.fromLTRB(8, 24, 16, 24),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.violetLight, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Checkbox(value: isSelected, onChanged: (_) => onToggle()), // 색과 모양은 AppTheme의 checkboxTheme을 따름
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$title · 별점 ${rating.score}', style: AppTextStyles.titleMedium),
                  if (rating.comment != null) ...[ // 후기가 없으면 줄과 간격을 통째로 뺌
                    const SizedBox(height: 8),
                    Text(rating.comment!, style: AppTextStyles.bodySmall),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardActionButton extends StatelessWidget { // 카드 오른쪽 작은 버튼. 수정과 삭제가 색만 달라서 하나로 만듦
  const _CardActionButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 36,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: EdgeInsets.zero, // 기본 좌우 여백 때문에 글자가 잘리지 않게 함
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}

class _DeleteRatingDialog extends StatefulWidget { // 삭제 확인 Dialog. onConfirm이 있으면 삭제 요청이 끝날 때까지 열어둠
  const _DeleteRatingDialog({this.title = '평점을 삭제할까요?', this.onConfirm});

  final String title;
  final Future<void> Function()? onConfirm; // null이면 요청 없이 true만 돌려주고 닫힘. 다중 삭제에서 씀

  @override
  State<_DeleteRatingDialog> createState() => _DeleteRatingDialogState();
}

class _DeleteRatingDialogState extends State<_DeleteRatingDialog> {
  bool _isDeleting = false; // 삭제 중이면 버튼과 닫기를 막음

  Future<void> _onConfirm() async {
    final onConfirm = widget.onConfirm;
    if (onConfirm == null) { // 다중 삭제는 화면 위 오버레이가 로딩을 맡아서 바로 닫음
      Navigator.pop(context, true);
      return;
    }
    setState(() => _isDeleting = true);
    try {
      await onConfirm();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isDeleting = false); // 다시 시도할 수 있게 버튼을 되돌림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is DioException
                ? writeErrorMessage(error) // 403, 404를 서버 문구로 구분
                : '삭제하지 못했습니다. 잠시 후 다시 시도해 주세요.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope( // 삭제 중에는 뒤로가기로 못 닫음
      canPop: !_isDeleting,
      child: Dialog(
        backgroundColor: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 차지
            children: [
              Text(widget.title, style: AppTextStyles.titleLarge),
              const SizedBox(height: 16),
              const Text('삭제한 평점은 복구할 수 없습니다.', style: AppTextStyles.bodySmall),
              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded( // 두 버튼이 가로를 반씩 나눔
                    child: SizedBox(
                      height: 44, // 옆의 삭제 버튼과 높이를 맞춤
                      child: TextButton(
                        onPressed: _isDeleting ? null : () => Navigator.pop(context, false), // 취소는 삭제 요청을 보내지 않음
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.violetSoft,
                          foregroundColor: AppColors.violet,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: AppTextStyles.button,
                        ),
                        child: const Text('취소'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MovieLogButton(
                      label: '삭제',
                      width: double.infinity, // Expanded가 정한 너비를 꽉 채움
                      isLoading: _isDeleting, // 삭제 중이면 회색 버튼과 인디케이터
                      onPressed: _onConfirm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}