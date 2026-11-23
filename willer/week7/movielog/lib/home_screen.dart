import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // context.push, context.go 사용 가능
import 'package:provider/provider.dart'; // Consumer, context.read 사용 가능

import 'data/models/tmdb_movie_dto.dart';
import 'data/movies.dart'; // 추천 카드에 쓰는 Mock 영화
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'view_models/movie_home_view_model.dart';
import 'widgets/tmdb_poster_image.dart';

class HomeScreen extends StatelessWidget { // 홈 화면
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MovieLog', style: AppTextStyles.appBarTitle), // 왼쪽 정렬은 AppTheme의 centerTitle: false를 따름
        actions: [ // AppBar 오른쪽 자리. 여러 개를 놓을 수 있어서 리스트
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.violet),
            onPressed: () {}, // 검색은 요구사항에 없어서 Figma대로 모양만 둠
          ),
        ],
      ),
      body: SingleChildScrollView( // 추천 카드가 커서 화면보다 길어짐. 스크롤 필요
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), // 왼쪽, 위, 오른쪽, 아래 여백을 각각 지정
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 제목과 섹션 제목을 왼쪽 정렬
          children: [
            const Text('오늘은 어떤\n영화를 볼까요?', style: AppTextStyles.titleLarge), // \n은 줄바꿈
            const SizedBox(height: 24),
            RecommendCard(movie: movies[0]), // Mock 목록의 첫 번째 영화를 추천 영화로 사용
            const SizedBox(height: 32),
            const SectionHeader(),
            const SizedBox(height: 12),
            const PopularMovieList(),
          ],
        ),
      ),
    );
  }
}

class RecommendCard extends StatelessWidget { // 포스터 위에 글자와 버튼을 겹친 큰 추천 카드
  const RecommendCard({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return AspectRatio( // 화면 폭에 맞춰 높이를 비율로 계산. 기기가 달라도 같은 모양
      aspectRatio: 2 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack( // 포스터, 어두운 그라데이션, 글자와 버튼을 순서대로 겹쳐 쌓음. 나중에 쓴 것이 위에 그려짐
          fit: StackFit.expand, // 위치를 안 정한 자식(포스터, 그라데이션)을 카드 크기에 꽉 채움
          children: [
            Image.asset(movie.posterAsset, fit: BoxFit.cover),
            const DecoratedBox( // 포스터 위에 덮는 그라데이션. 밝은 포스터에서도 흰 글자가 보이게
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, // 위에서
                  end: Alignment.bottomCenter, // 아래로
                  colors: [Colors.transparent, Colors.black87], // 투명에서 거의 검정으로 점점 어두워짐
                ),
              ),
            ),
            Positioned( // 카드 아래쪽에 글자와 버튼을 붙임. 좌우 아래 24씩 띄움
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    label: const Text('추천 신작'),
                    labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.white, fontWeight: FontWeight.w700),
                    backgroundColor: AppColors.violet,
                    side: BorderSide.none, // 테두리 없음
                    shape: const StadiumBorder(), // 양 끝이 완전히 둥근 알약 모양
                  ),
                  const SizedBox(height: 12),
                  Text(movie.title, style: AppTextStyles.titleLarge.copyWith(color: AppColors.white)),
                  const SizedBox(height: 4),
                  Text(
                    '${movie.genre} · ${movie.runtime}분',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.white.withValues(alpha: 0.8)), // 제목보다 살짝 흐리게
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity, // 버튼을 가로로 꽉 채움
                    child: ElevatedButton.icon( // 아이콘과 글자가 같이 있는 버튼. 색과 모양은 AppTheme의 elevatedButtonTheme을 따름
                      onPressed: () => context.push('/movies/${movie.id}'), // 상세를 위에 쌓음
                      icon: const Icon(Icons.info),
                      label: const Text('상세보기'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget { // "인기 영화 / 전체보기 >" 한 줄
  const SectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // 제목은 왼쪽 끝, 버튼은 오른쪽 끝
      children: [
        const Text('인기 영화', style: AppTextStyles.titleMedium),
        TextButton.icon(
          onPressed: () => context.go('/movies'), // 상세처럼 위에 쌓는 게 아니라 목록 탭으로 위치를 바꾸는 이동이라 go
          icon: const Icon(Icons.chevron_right),
          label: const Text('전체보기'),
          iconAlignment: IconAlignment.end, // 아이콘을 글자 뒤(오른쪽)에 둠. 기본은 앞
        ),
      ],
    );
  }
}

class PopularMovieList extends StatelessWidget { // 인기 영화 가로 목록. 홈 ViewModel 상태에 따라 다른 화면을 그림
  const PopularMovieList({super.key});

  static const _height = 310.0; // 가로 ListView는 높이를 스스로 못 정해서 직접 지정. 상태가 바뀌어도 영역 높이 유지

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: Consumer<MovieHomeViewModel>( // 이 영역만 ViewModel을 구독. 알림이 오면 builder만 다시 그림
        builder: (context, viewModel, child) {
          return switch (viewModel.status) { // 상태 이름표를 보고 보여줄 위젯을 고름
            MovieHomeLoadStatus.idle ||
            MovieHomeLoadStatus.loading => const Center(child: CircularProgressIndicator()),
            MovieHomeLoadStatus.error => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(viewModel.message ?? '인기 영화를 불러오지 못했어요.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context.read<MovieHomeViewModel>().loadPopular(), // 버튼은 부탁만 하면 돼서 read
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            MovieHomeLoadStatus.empty => const Center(child: Text('인기 영화가 없어요.')),
            MovieHomeLoadStatus.success => ListView.separated( // 항목 사이에만 간격을 넣는 ListView
                scrollDirection: Axis.horizontal, // 가로 스크롤
                itemCount: viewModel.popularMovies.length, // 최대 5개. 적게 와도 있는 만큼만
                separatorBuilder: (context, index) => const SizedBox(width: 12), // 카드 사이 간격. 마지막 카드 뒤에는 안 붙음
                itemBuilder: (context, index) => PopularMovieCard(
                  movie: viewModel.popularMovies[index],
                  rank: index + 1, // index는 0부터라 순위는 1을 더함
                ),
              ),
          };
        },
      ),
    );
  }
}

class PopularMovieCard extends StatelessWidget { // 인기 영화 카드 하나. 포스터 위 순위, 아래 제목과 평점
  const PopularMovieCard({super.key, required this.movie, required this.rank});

  final TmdbMovieDto movie;
  final int rank;

  static const _width = 160.0;
  static const _posterHeight = 240.0; // 2:3 포스터 비율

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // Column에는 onTap이 없어서 감싸서 탭을 받음
      behavior: HitTestBehavior.opaque, // 빈 공간까지 카드 영역 전체가 탭을 받음
      onTap: () => context.push('/movies/${movie.id}', extra: movie), // 주소에는 TMDB id, 화면에 쓸 영화 정보는 extra로 같이 넘김
      child: SizedBox(
        width: _width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect( // 포스터 모서리를 둥글게 자름
              borderRadius: BorderRadius.circular(12),
              child: Stack( // 포스터 위에 순위 배지를 겹침
                children: [
                  TmdbPosterImage(
                    posterPath: movie.posterPath, // null이어도 위젯이 대체 이미지를 그림
                    width: _width,
                    height: _posterHeight,
                  ),
                  Positioned( // 왼쪽 위 모서리에서 8씩 띄움
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.6), // 반투명 검정. 포스터가 밝아도 숫자가 보이게
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$rank',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title,
              style: AppTextStyles.titleMedium,
              maxLines: 1, // 제목이 길어도 한 줄. 넘치면 ...으로 자름
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 2),
                Text(
                  movie.voteAverage.toStringAsFixed(1), // TMDB 10점 만점 평점. 소수 첫째 자리까지
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}