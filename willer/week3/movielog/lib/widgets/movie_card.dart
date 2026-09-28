import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // context.push 사용 가능

import '../data/movies.dart'; // Movie 클래스
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MovieCard extends StatelessWidget { // 영화 한 편을 보여주는 공통 카드. 홈, 목록 어디서 써도 누르면 상세로 이동
  const MovieCard({super.key, required this.movie}); // 필수. 어떤 영화를 그릴지 밖에서 받음

  final Movie movie; // 달라지는 건 영화 데이터뿐이고 카드 구조는 안에서 고정

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // Column에는 onTap이 없어서 감싸서 탭을 받음
      behavior: HitTestBehavior.opaque, // 글자 사이 빈 공간까지 카드 영역 전체가 탭을 받음. 기본값은 그려진 부분만 받음
      onTap: () => context.push('/movies/${movie.id}'), // 현재 화면 위에 상세를 쌓음. 뒤로가기로 돌아올 수 있음. 주소에 id를 넣어 Path Parameter로 전달
      child: Column(
        mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 차지. 없으면 세로로 끝까지 늘어남
        crossAxisAlignment: CrossAxisAlignment.start, // 제목과 연도를 왼쪽 정렬
        children: [
          AspectRatio( // 폭은 부모가 정하고 높이는 비율로 계산. 홈 가로 목록, 목록 GridView 어디서든 같은 모양 유지
            aspectRatio: 2 / 3, // 가로:세로 2:3 포스터 비율
            child: ClipRRect( // 자식을 둥근 사각형으로 잘라냄. ClipOval의 사각형 버전
              borderRadius: BorderRadius.circular(12),
              child: Stack( // 포스터 위에 평점 배지를 겹쳐 놓으려고 사용
                fit: StackFit.expand, // 위치를 안 정한 자식(포스터)을 Stack 크기에 꽉 채움
                children: [
                  Image.asset(
                    movie.posterAsset, // 경로를 직접 쓰지 않고 Mock Data에서 읽음
                    fit: BoxFit.cover, // 비율이 달라도 빈 공간 없이 채우고 넘치는 부분은 잘라냄
                  ),
                  Positioned( // Stack 안에서 위치를 직접 정함. 오른쪽 위 모서리에서 8씩 띄움
                    top: 8,
                    right: 8,
                    child: RatingBadge(rating: movie.rating),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8), // 포스터와 제목 사이 간격
          Text(
            movie.title,
            style: AppTextStyles.titleMedium,
            maxLines: 1, // 제목이 길어도 한 줄. 줄이 늘면 카드 높이가 달라져서 넘침(overflow)이 생김
            overflow: TextOverflow.ellipsis, // 넘치면 ...으로 자름
          ),
          const SizedBox(height: 4),
          Text(
            '${movie.year} · ${movie.genre}', // ${}는 문자열 안에 값을 끼워 넣는 문법
            style: AppTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class RatingBadge extends StatelessWidget { // 포스터 오른쪽 위의 "★ 4.5" 배지
  const RatingBadge({super.key, required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container( // 배경색과 둥근 모서리가 필요해서 Container
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // 배지 내부 여백
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.6), // 반투명 검정. 포스터가 밝아도 글자가 보이게
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 차지. 없으면 가로로 끝까지 늘어남
        children: [
          const Icon(Icons.star, size: 14, color: AppColors.white),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1), // 소수 첫째 자리까지 문자열로. 4.0도 4가 아니라 4.0으로 표시
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}