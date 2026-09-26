import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // context.push, context.go 사용 가능

import 'data/movies.dart'; // Mock 영화 목록
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'widgets/movie_card.dart';

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
                      onPressed: () => context.push('/movies/${movie.id}'), // 카드와 같은 방식으로 상세를 위에 쌓음
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

class PopularMovieList extends StatelessWidget { // 인기 영화 가로 목록
  const PopularMovieList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 310, // 가로 ListView는 높이를 스스로 못 정해서 직접 지정. 포스터 240 + 제목과 연도 줄 높이
      child: ListView.separated( // 항목 사이에만 간격을 넣는 ListView
        scrollDirection: Axis.horizontal, // 가로 스크롤
        itemCount: movies.length, // Mock 영화 개수만큼
        separatorBuilder: (context, index) => const SizedBox(width: 12), // 카드와 카드 사이 간격. 마지막 카드 뒤에는 안 붙음
        itemBuilder: (context, index) {
          return SizedBox(
            width: 160, // 카드 폭. MovieCard의 AspectRatio가 이 폭으로 포스터 높이(240)를 계산
            child: MovieCard(movie: movies[index]), // index번째 영화를 카드로
          );
        },
      ),
    );
  }
}