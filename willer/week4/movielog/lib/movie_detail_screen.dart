import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // RatingBarIndicator 사용 가능
import 'package:go_router/go_router.dart'; // context.pop 사용 가능

import 'data/movies.dart'; // findMovieById 사용
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'widgets/rating_dialog.dart';

class MovieDetailScreen extends StatelessWidget { // 영화 상세 화면
  const MovieDetailScreen({super.key, required this.movieId}); // 필수. 주소에서 꺼낸 영화 id를 받음

  final String movieId; // 주소는 문자열이라 '1'처럼 String으로 들어옴

  @override
  Widget build(BuildContext context) {
    final movie = findMovieById(int.tryParse(movieId)); // '1'을 숫자 1로 바꿔서 Mock Data에서 찾음. 숫자가 아니면 tryParse가 에러 대신 null을 줌

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.violet),
          onPressed: () => context.pop(), // 스택 맨 위(상세)를 치우고 이전 화면(홈이나 목록)으로 돌아감. 들어올 때 push로 쌓았기 때문에 가능
        ),
        title: const Text('Cinema Archive', style: AppTextStyles.appBarTitle),
        centerTitle: true, // AppTheme에는 false로 두었지만 이 화면만 가운데 정렬로 덮어씀
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.violet),
            onPressed: () {}, // 공유는 요구사항에 없어서 Figma대로 모양만 둠
          ),
        ],
      ),
      body: movie == null // 없는 id(/movies/999)나 숫자가 아닌 값(/movies/abc)이면 null
          ? const Center(child: Text('영화를 찾을 수 없어요'))
          : SingleChildScrollView( // 포스터와 시놉시스가 길어서 화면보다 김. 스크롤 필요
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 글자들을 왼쪽 정렬
                children: [
                  AspectRatio( // 화면 폭에 맞춰 포스터 높이를 비율로 계산
                    aspectRatio: 2 / 3,
                    child: Image.asset(movie.posterAsset, fit: BoxFit.cover), // 위에서 null 검사를 해서 여기선 movie가 null이 아님이 보장됨
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: MovieInfo(movie: movie),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: movie == null ? null : const DetailBottomButtons(), // 화면 맨 아래 고정 자리. 스크롤해도 버튼이 항상 보임. 영화가 없으면 버튼도 없음
    );
  }
}

class MovieInfo extends StatelessWidget { // 포스터 아래 제목부터 시놉시스까지
  const MovieInfo({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(movie.title, style: AppTextStyles.titleLarge),
        const SizedBox(height: 4),
        Text('${movie.year} • ${movie.genre} • ${movie.runtime}분', style: AppTextStyles.bodySmall),
        const SizedBox(height: 12),
        Row( // 별, 평균 평점, 리뷰 수를 가로로 나란히
          children: [
            RatingBarIndicator( // 읽기 전용 별점. 눌러도 안 바뀜. 입력용과 달리 4.3 같은 소수도 그대로 표시
              rating: movie.rating, // 채울 별의 양. 별빛 아래 우리는 4.5
              itemCount: 5, // 별 5개
              itemSize: 20, // 별 하나 크기
              itemBuilder: (context, index) { // index번째 별을 어떻게 그릴지
                return const Icon(
                  Icons.star,
                  color: Colors.amber,
                );
              },
            ),
            const SizedBox(width: 8), // 별과 숫자 사이 간격
            Text(movie.rating.toStringAsFixed(1), style: AppTextStyles.titleMedium), // 소수 첫째 자리까지. 4.0도 4가 아니라 4.0
            const SizedBox(width: 4),
            Text('(${movie.reviewCount})', style: AppTextStyles.bodySmall),
          ],
        ),
        const SizedBox(height: 16),
        Wrap( // Row와 비슷하지만 공간이 모자라면 자동으로 다음 줄로 넘김. 태그 개수가 영화마다 달라서 사용
          spacing: 8, // 가로 간격
          runSpacing: 8, // 줄이 넘어갔을 때 세로 간격
          children: movie.tags
              .map( // 문자열 리스트를 Chip 위젯 리스트로 바꿈
                (tag) => Chip(
                  label: Text(tag),
                  labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.black),
                  backgroundColor: AppColors.fieldFill,
                  side: BorderSide.none, // 테두리 없음
                  shape: const StadiumBorder(), // 양 끝이 완전히 둥근 알약 모양
                ),
              )
              .toList(), // map의 결과는 Iterable이라 List로 바꿈
        ),
        const Divider(height: 48, color: AppColors.fieldBorder), // 가로 구분선. height는 선 위아래 여백까지 합친 전체 높이
        const Text('시놉시스', style: AppTextStyles.titleMedium),
        const SizedBox(height: 12),
        Text(movie.synopsis, style: AppTextStyles.bodyMedium), // bodyMedium은 줄 간격 1.5라 긴 글 읽기 편함
      ],
    );
  }
}

class DetailBottomButtons extends StatefulWidget { // 하단 즐겨찾기, 평점 남기기 버튼. 즐겨찾기 상태에 따라 아이콘이 바뀌어야 해서 StatefulWidget
  const DetailBottomButtons({super.key});

  @override
  State<DetailBottomButtons> createState() => _DetailBottomButtonsState();
}

class _DetailBottomButtonsState extends State<DetailBottomButtons> {
  bool isFavorite = false; // 즐겨찾기 여부. 서버에 저장하지 않는 화면 내부 상태라 상세를 나갔다 오면 false로 돌아감

  void toggleFavorite() { // 즐겨찾기 버튼을 누를 때마다 추가와 삭제를 번갈아 함
    setState(() {
      isFavorite = !isFavorite; // !는 true와 false를 뒤집음
    });

    final messenger = ScaffoldMessenger.of(context); // 모든 화면보다 위에 있는 Snackbar 관리자. 화면을 벗어나도 Snackbar가 유지됨
    messenger.hideCurrentSnackBar(); // 떠 있는 Snackbar를 먼저 치움. 없으면 연타할 때 Snackbar가 줄을 서서 하나씩 뜸
    messenger.showSnackBar(
      SnackBar(
        content: Text(isFavorite ? '즐겨찾기에 추가했어요' : '즐겨찾기에서 삭제했어요'), // 바뀐 상태에 맞는 문구
        behavior: SnackBarBehavior.floating, // 화면 아래에 붙지 않고 살짝 떠 있는 모양. 하단 버튼 위에 뜸
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea( // 하단 제스처 바와 겹치지 않게 여백을 자동으로 줌
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded( // 두 버튼이 가로 공간을 반씩 나눠 가짐
              child: OutlinedButton.icon( // 테두리만 있는 버튼
                onPressed: toggleFavorite, // 괄호 없이 함수 자체를 넘김. 괄호를 붙이면 그리는 순간 바로 실행됨
                icon: Icon(isFavorite ? Icons.bookmark : Icons.bookmark_border), // 추가되면 채워진 아이콘, 아니면 빈 아이콘
                label: const Text('즐겨찾기'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18), // 옆 ElevatedButton(AppTheme 기준 18)과 높이를 맞춤
                ),
              ),
            ),
            const SizedBox(width: 12), // 버튼 사이 간격
            Expanded(
              child: ElevatedButton.icon( // 색과 모양은 AppTheme의 elevatedButtonTheme을 따름
                onPressed: () async { // Dialog가 닫힐 때까지 기다려야 해서 async
                  final rating = await showDialog<double>( // Dialog를 띄우고 닫힐 때까지 기다림. <double>은 돌려받을 값의 타입
                    context: context,
                    builder: (dialogContext) => const RatingDialog(), // Dialog 전용 context. Dialog 안에서 닫을 때는 이 context 기준
                  );

                  if (rating == null) return; // 확인 대신 바깥을 누르거나 뒤로가기로 닫으면 null이 옴. 그땐 아무것도 안 함

                  debugPrint('선택한 평점: $rating'); // Dialog가 돌려준 점수를 밖에서 받았는지 확인. print는 analyze 경고가 나서 debugPrint 사용
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