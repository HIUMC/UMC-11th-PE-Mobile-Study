import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // context.pop 사용 가능
import 'package:provider/provider.dart'; // context.read 사용 가능

import 'data/models/tmdb_movie_dto.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'view_models/movie_detail_view_model.dart';
import 'view_models/signup_view_model.dart'; // SubmitStatus 사용
import 'widgets/rating_dialog.dart';
import 'widgets/tmdb_poster_image.dart';

class MovieDetailScreen extends StatelessWidget { // 영화 상세 화면
  const MovieDetailScreen({super.key}); // 영화는 MovieDetailLoader가 준비해서 ViewModel에 넣어둠

  @override
  Widget build(BuildContext context) {
    final movie = context.read<MovieDetailViewModel>().movie; // 화면에 있는 동안 바뀌지 않아서 read

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.violet),
          onPressed: () => context.pop(), // 스택 맨 위(상세)를 치우고 이전 화면으로 돌아감
        ),
        title: const Text('Cinema Archive', style: AppTextStyles.appBarTitle),
        centerTitle: true, // 이 화면만 가운데 정렬
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.violet),
            onPressed: () {}, // 공유는 요구사항에 없어서 Figma대로 모양만 둠
          ),
        ],
      ),
      body: SingleChildScrollView( // 포스터와 줄거리가 화면보다 길어서 스크롤
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio( // 화면 폭에 맞춰 포스터 높이를 2:3 비율로 계산
              aspectRatio: 2 / 3,
              child: TmdbPosterImage(
                posterPath: movie.posterPath, // 없으면 회색 대체 이미지
                width: double.infinity, // AspectRatio가 정한 크기를 꽉 채움
                height: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: MovieInfo(movie: movie),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DetailBottomButtons(), // movieId는 ViewModel이 들고 있어서 넘기지 않음
    );
  }
}

class MovieInfo extends StatelessWidget { // 포스터 아래 제목부터 줄거리까지
  const MovieInfo({super.key, required this.movie});

  final TmdbMovieDto movie;

  String? get _year { // 'yyyy-mm-dd'에서 앞 4글자만. 날짜가 없거나 짧으면 null
    final date = movie.releaseDate;
    if (date == null || date.length < 4) return null;
    return date.substring(0, 4);
  }

  @override
  Widget build(BuildContext context) {
    final year = _year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(movie.title, style: AppTextStyles.titleLarge),
        if (year != null) ...[ // 연도가 없으면 연도 줄과 간격을 통째로 뺌
          const SizedBox(height: 4),
          Text(year, style: AppTextStyles.bodySmall),
        ],
        const SizedBox(height: 12),
        Row( // 별 아이콘과 TMDB 평점을 나란히
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(movie.voteAverage.toStringAsFixed(1), style: AppTextStyles.titleMedium), // 10점 만점 그대로. 소수 첫째 자리까지
          ],
        ),
        const Divider(height: 48, color: AppColors.fieldBorder), // 가로 구분선. height는 위아래 여백까지 합친 높이
        const Text('시놉시스', style: AppTextStyles.titleMedium),
        const SizedBox(height: 12),
        Text(
          movie.overview.isEmpty ? '줄거리 정보가 없어요.' : movie.overview, // 줄거리가 빈 문자열이면 안내 문구
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}

class DetailBottomButtons extends StatefulWidget { // 하단 즐겨찾기, 평점 남기기 버튼. 즐겨찾기 상태에 따라 아이콘이 바뀌어서 StatefulWidget
  const DetailBottomButtons({super.key});

  @override
  State<DetailBottomButtons> createState() => _DetailBottomButtonsState();
}

class _DetailBottomButtonsState extends State<DetailBottomButtons> {
  bool isFavorite = false; // 즐겨찾기 여부. 서버에 저장하지 않아서 상세를 나갔다 오면 false

  void toggleFavorite() { // 누를 때마다 추가와 삭제를 번갈아 함
    setState(() {
      isFavorite = !isFavorite;
    });

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar(); // 떠 있는 Snackbar를 먼저 치움. 연타해도 줄 서지 않음
    messenger.showSnackBar(
      SnackBar(
        content: Text(isFavorite ? '즐겨찾기에 추가했어요' : '즐겨찾기에서 삭제했어요'),
        behavior: SnackBarBehavior.floating, // 하단 버튼 위에 살짝 떠 있는 모양
      ),
    );
  }

  Future<void> onRatingPressed() async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 저장 중 바깥 탭으로 닫히는 것도 막음
      builder: (_) => RatingDialog(
        onSubmit: (score, comment) async {
          final viewModel = context.read<MovieDetailViewModel>(); // Dialog 쪽 context가 아니라 상세 화면 context에서 찾음
          await viewModel.createRating(score: score, comment: comment);
          if (viewModel.submitStatus != SubmitStatus.success) { // 실패를 예외로 바꿔야 Dialog가 닫히지 않고 문구를 보여줌
            throw StateError(viewModel.submitMessage ?? '저장에 실패했습니다.');
          }
        },
      ),
    );

    if (!mounted || saved != true) return; // 취소나 실패면 Snackbar 없음

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('평점을 등록했습니다. 마이페이지의 "내가 등록한 평점"에서 확인할 수 있습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMember = context.read<MovieDetailViewModel>().memberId != null; // 가입 전이면 등록 버튼 비활성

    return SafeArea( // 하단 제스처 바와 겹치지 않게 여백을 줌
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 하단 영역이 화면을 덮지 않게 내용 크기만큼만
          children: [
            if (!hasMember) ...[
              const Text('학습용 회원가입 후 평점을 남길 수 있습니다.', style: AppTextStyles.bodySmall),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded( // 두 버튼이 가로 공간을 반씩 나눔
                  child: OutlinedButton.icon(
                    onPressed: toggleFavorite, // 괄호 없이 함수 자체를 넘김
                    icon: Icon(isFavorite ? Icons.bookmark : Icons.bookmark_border),
                    label: const Text('즐겨찾기'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18), // 옆 버튼과 높이를 맞춤
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: hasMember ? onRatingPressed : null, // null이면 비활성
                    icon: const Icon(Icons.rate_review_outlined),
                    label: const Text('평점 남기기'),
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