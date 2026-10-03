import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_movies.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';

// 홈 화면
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 홈 상단의 큰 추천 영화
    //
    // Mock Data의 첫 번째 영화인
    // '별빛 아래 우리'를 사용함.
    final featuredMovie = movies.first;

    // 인기 영화 영역에서 보여줄 영화들
    //
    // 현재 제공된 Asset 안에 실제 포스터가 존재하는
    // 공통 Mock Data를 그대로 사용함.
    final popularMovies = movies.skip(1).toList();

    return Scaffold(
      // 홈 화면의 기본 배경
      //
      // Scaffold를 사용하면 Material 화면 구조가 만들어져서
      // Text, Icon 등의 기본 스타일이 정상적으로 적용됨.
      backgroundColor: const Color(0xFFFAF9F5),

      body: SafeArea(
        // 화면 전체가 세로로 길어질 수 있으므로
        // 아래위로 스크롤할 수 있게 구성함.
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 20, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------------------
              // 상단 MovieLog + 검색 아이콘
              // ---------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'MovieLog',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.violet,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const Spacer(),

                    IconButton(
                      // 아직 검색 화면은 이번 미션 범위가 아니므로
                      // UI만 표시함.
                      onPressed: () {},
                      icon: const Icon(Icons.search),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ---------------------------
              // 상단 질문 문구
              // ---------------------------
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '오늘은 어떤\n영화를 볼까요?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ---------------------------
              // 추천 영화 큰 카드
              // ---------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _FeaturedMovieCard(movie: featuredMovie),
              ),

              const SizedBox(height: 20),

              // ---------------------------
              // 인기 영화 제목
              // ---------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text(
                      '인기 영화',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const Spacer(),

                    TextButton(
                      // 영화 탭으로 이동
                      onPressed: () {
                        context.go('/movies');
                      },
                      child: const Text('전체보기 ›'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ---------------------------
              // 인기 영화 가로 목록
              // ---------------------------
              SizedBox(
                height: 245,
                child: ListView.separated(
                  // 가로 방향으로 스크롤
                  scrollDirection: Axis.horizontal,

                  padding: const EdgeInsets.symmetric(horizontal: 20),

                  itemCount: popularMovies.length,

                  separatorBuilder: (context, index) {
                    return const SizedBox(width: 12);
                  },

                  itemBuilder: (context, index) {
                    final movie = popularMovies[index];

                    return _PopularMovieCard(movie: movie);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------
// 추천 영화 큰 카드
// ---------------------------
//
// 홈 화면 상단에 크게 보이는
// '별빛 아래 우리' 영역을 별도 Widget으로 분리함.
class _FeaturedMovieCard extends StatelessWidget {
  const _FeaturedMovieCard({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 카드 전체를 누르면 영화 상세 화면으로 이동
      onTap: () {
        context.push('/movies/${movie.id}');
      },

      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),

        child: SizedBox(
          height: 390,

          child: Stack(
            fit: StackFit.expand,
            children: [
              // 추천 영화 배경 이미지
              Image.asset(movie.posterAsset, fit: BoxFit.cover),

              // 글자가 잘 보이도록
              // 이미지 아래쪽에 어두운 그라데이션을 추가함.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                    stops: [0.45, 1.0],
                  ),
                ),
              ),

              // 영화 정보와 상세보기 버튼
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 추천 신작 Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.violet,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '추천 신작',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${movie.genre} · ${movie.year}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.push('/movies/${movie.id}');
                        },

                        icon: const Icon(Icons.info, size: 16),

                        label: const Text('상세보기'),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.violet,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------
// 인기 영화 카드
// ---------------------------
//
// 같은 모양의 영화 카드를 여러 개 표시하므로
// ListView에서 반복해서 사용할 수 있도록
// 별도 Widget으로 분리함.
class _PopularMovieCard extends StatelessWidget {
  const _PopularMovieCard({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 인기 영화 카드도 누르면
      // 해당 영화 ID의 상세 화면으로 이동함.
      onTap: () {
        context.push('/movies/${movie.id}');
      },

      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 영화 포스터
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                movie.posterAsset,
                width: 120,
                height: 170,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 8),

            // 영화 제목
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 4),

            // 영화 평점
            Row(
              children: [
                const Icon(Icons.star, size: 13, color: Colors.amber),

                const SizedBox(width: 4),

                Text(
                  movie.rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
