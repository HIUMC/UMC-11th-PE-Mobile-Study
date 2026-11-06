import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Consumer 사용 가능

import 'data/models/rating_with_movie.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'view_models/my_ratings_view_model.dart';
import 'widgets/movie_list_states.dart'; // 로딩, 에러 화면을 재사용
import 'widgets/tmdb_poster_image.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // bottomNavigationBar를 넘기지 않아서 하단 탭이 없음
      appBar: AppBar( // push로 열려서 왼쪽 뒤로가기 버튼이 자동으로 생김
        title: const Text('내가 등록한 평점', style: AppTextStyles.appBarTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<MyRatingsViewModel>( // status가 바뀔 때마다 다시 그림
          builder: (context, viewModel, child) {
            return switch (viewModel.status) { // 상태 하나당 위젯 하나
              MyRatingsLoadStatus.idle ||
              MyRatingsLoadStatus.loading => const MovieListLoading(),
              MyRatingsLoadStatus.error => MovieListError(
                  message: viewModel.message,
                  onRetry: viewModel.load, // 다시 시도하면 처음부터 다시 불러옴
                ),
              MyRatingsLoadStatus.empty => const Center(
                  child: Text('아직 등록한 평점이 없습니다.', style: AppTextStyles.bodySmall),
                ),
              MyRatingsLoadStatus.success => ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (viewModel.message != null) ...[ // 일부 영화 정보를 못 가져왔을 때만 안내
                      Text(viewModel.message!, style: AppTextStyles.bodySmall),
                      const SizedBox(height: 12),
                    ],
                    for (final entry in viewModel.ratings) RatingCard(entry: entry),
                  ],
                ),
            };
          },
        ),
      ),
    );
  }
}

class RatingCard extends StatelessWidget { // 평점 카드 하나. 포스터, 제목, 별점, 후기, 등록일
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
        ],
      ),
    );
  }
}