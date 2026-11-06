import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // context.pop 사용 가능

import 'data/models/tmdb_movie_dto.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'widgets/rating_dialog.dart';
import 'widgets/tmdb_poster_image.dart';

class MovieDetailScreen extends StatelessWidget { // 영화 상세 화면
  const MovieDetailScreen({super.key, required this.movie}); // 목록이나 홈에서 extra로 넘긴 영화를 받음

  final TmdbMovieDto? movie; // extra 없이 주소로만 들어오면 null

  @override
  Widget build(BuildContext context) {
    final movie = this.movie; // 지역 변수로 옮겨야 null 검사 뒤에 null이 아님이 보장됨

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
      body: movie == null // Mock 추천 카드처럼 extra 없이 들어온 경우
          ? const Center(child: Text('영화 정보를 찾을 수 없어요'))
          : SingleChildScrollView( // 포스터와 줄거리가 화면보다 길어서 스크롤
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
      bottomNavigationBar: movie == null ? null : DetailBottomButtons(movieId: movie.id), // 평점 출력에 쓸 TMDB id를 넘김
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
  const DetailBottomButtons({super.key, required this.movieId});

  final int movieId; // 평점을 어느 영화에 남겼는지 출력할 때 씀

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

  @override
  Widget build(BuildContext context) {
    return SafeArea( // 하단 제스처 바와 겹치지 않게 여백을 줌
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
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
                onPressed: () async { // Dialog가 닫힐 때까지 기다려야 해서 async
                  final rating = await showDialog<double>(
                    context: context,
                    builder: (dialogContext) => const RatingDialog(),
                  );

                  if (rating == null) return; // 바깥을 누르거나 뒤로가기로 닫으면 null

                  debugPrint('movieId: ${widget.movieId}, rating: $rating'); // State 안에서는 widget.으로 위젯의 값을 꺼냄. TMDB id와 평점을 같이 출력
                },
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('평점 남기기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}