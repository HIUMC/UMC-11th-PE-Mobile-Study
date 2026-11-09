import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // context.push 사용 가능

import '../data/models/tmdb_movie_dto.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'tmdb_poster_image.dart';

class MovieCard extends StatelessWidget { // 영화 목록 Grid의 카드 하나. 누르면 상세로 이동
  const MovieCard({super.key, required this.movie, this.genreName}); // 장르 이름은 Genre API 목록에서 찾아 부모가 넘겨줌

  final TmdbMovieDto movie;
  final String? genreName; // 못 찾으면 null이라 표시 안 함

  String get _subtitle { // 연도와 장르 이름을 이은 한 줄. 없는 값은 빼고 이음
    final year = movie.releaseDate != null && movie.releaseDate!.length >= 4
        ? movie.releaseDate!.substring(0, 4) // 'yyyy-mm-dd'에서 연도 4글자만
        : null; // 개봉일이 없으면 연도 표시 안 함
    return [?year, ?genreName].join(' · '); // 값 앞의 ?는 null이면 목록에서 빼라는 뜻
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // Column에는 onTap이 없어서 감싸서 탭을 받음
      behavior: HitTestBehavior.opaque, // 글자 사이 빈 공간까지 카드 영역 전체가 탭을 받음
      onTap: () => context.push('/movies/${movie.id}', extra: movie), // 주소에는 TMDB id, 화면에 쓸 영화 정보는 extra로 같이 넘김
      child: Column(
        mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 차지
        crossAxisAlignment: CrossAxisAlignment.start, // 제목과 연도를 왼쪽 정렬
        children: [
          AspectRatio( // 폭은 GridView가 정하고 높이는 비율로 계산
            aspectRatio: 2 / 3, // 가로:세로 2:3 포스터 비율
            child: ClipRRect( // 둥근 사각형으로 잘라냄
              borderRadius: BorderRadius.circular(12),
              child: Stack( // 포스터 위에 평점 배지를 겹쳐 놓으려고 사용
                fit: StackFit.expand, // 위치를 안 정한 자식(포스터)을 Stack 크기에 꽉 채움
                children: [
                  TmdbPosterImage(
                    posterPath: movie.posterPath, // null이거나 받기 실패하면 위젯이 대체 이미지를 그림
                    width: double.infinity, // 크기는 AspectRatio가 정한 칸에 맞춰짐
                    height: double.infinity,
                  ),
                  Positioned( // 오른쪽 위 모서리에서 8씩 띄움
                    top: 8,
                    right: 8,
                    child: RatingBadge(rating: movie.voteAverage),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8), // 포스터와 제목 사이 간격
          Text(
            movie.title,
            style: AppTextStyles.titleMedium,
            maxLines: 1, // 제목이 길어도 한 줄. 줄이 늘면 카드 높이가 달라져서 넘침이 생김
            overflow: TextOverflow.ellipsis, // 넘치면 ...으로 자름
          ),
          const SizedBox(height: 4),
          Text(
            _subtitle,
            style: AppTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class RatingBadge extends StatelessWidget { // 포스터 오른쪽 위의 "★ 8.5" 배지
  const RatingBadge({super.key, required this.rating});

  final double rating; // TMDB 10점 만점 평점

  @override
  Widget build(BuildContext context) {
    return Container( // 배경색과 둥근 모서리가 필요해서 Container
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // 배지 내부 여백
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.6), // 반투명 검정. 포스터가 밝아도 글자가 보이게
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 차지
        children: [
          const Icon(Icons.star, size: 14, color: AppColors.white),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1), // 소수 첫째 자리까지. 8.0도 8이 아니라 8.0
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}