import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_movies.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';

// 영화 목록 화면
//
// 장르 Chip을 선택하면
// 해당 장르의 영화만 GridView에 표시함.
//
// 선택된 장르는 이 화면 안에서만 관리하므로
// StatefulWidget을 사용함.
class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  // ---------------------------
  // 장르 목록
  // ---------------------------
  //
  // Figma에 보이는 장르 Chip을 기준으로 구성함.
  final List<String> _genres = ['전체', '드라마', 'SF', '애니메이션', '스릴러'];

  // 처음에는 전체 영화가 보이도록
  // '전체'를 기본 선택값으로 사용함.
  String _selectedGenre = '전체';

  // ---------------------------
  // 현재 화면에 표시할 영화
  // ---------------------------
  //
  // '전체'가 선택되어 있으면 모든 영화 반환
  //
  // 특정 장르가 선택되어 있으면
  // 해당 장르의 영화만 반환함.
  List<Movie> get _filteredMovies {
    if (_selectedGenre == '전체') {
      return movies;
    }

    return movies.where((movie) => movie.genre == _selectedGenre).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Figma의 밝은 배경색
      backgroundColor: const Color(0xFFFAF9F5),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------------------
              // 상단 제목 + 검색 버튼
              // ---------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
                child: Row(
                  children: [
                    const Text(
                      '영화',
                      style: TextStyle(
                        color: AppColors.violet,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const Spacer(),

                    IconButton(
                      // 검색 화면은 현재 미션 범위가 아니므로
                      // 검색 아이콘 UI만 표시함.
                      onPressed: () {},
                      icon: const Icon(Icons.search, size: 24),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ---------------------------
              // 장르 Chip 목록
              // ---------------------------
              //
              // 가로 ListView를 사용해서
              // 화면 너비보다 Chip이 많아져도
              // 좌우로 스크롤할 수 있도록 함.
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,

                  padding: const EdgeInsets.symmetric(horizontal: 20),

                  itemCount: _genres.length,

                  separatorBuilder: (context, index) {
                    return const SizedBox(width: 8);
                  },

                  itemBuilder: (context, index) {
                    final genre = _genres[index];

                    final isSelected = _selectedGenre == genre;

                    return ChoiceChip(
                      label: Text(genre),

                      selected: isSelected,

                      // Chip을 눌렀을 때
                      // 선택된 장르를 변경하고
                      // 화면을 다시 그림.
                      onSelected: (_) {
                        setState(() {
                          _selectedGenre = genre;
                        });
                      },

                      // 선택된 Chip은 보라색
                      selectedColor: AppColors.violet,

                      // 선택되지 않은 Chip은 연한 보라색
                      backgroundColor: AppColors.lightViolet,

                      showCheckmark: false,

                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.gray,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),

                      side: BorderSide.none,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ---------------------------
              // 영화 Grid
              // ---------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: GridView.builder(
                  // 바깥 SingleChildScrollView가
                  // 전체 세로 스크롤을 담당하므로
                  // GridView 자체 스크롤은 막음.
                  physics: const NeverScrollableScrollPhysics(),

                  // GridView가 필요한 높이만큼만
                  // 차지하도록 함.
                  shrinkWrap: true,

                  itemCount: _filteredMovies.length,

                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    // 한 줄에 영화 카드 2개
                    crossAxisCount: 2,

                    // 좌우 카드 간격
                    crossAxisSpacing: 14,

                    // 위아래 카드 간격
                    mainAxisSpacing: 18,

                    // 영화 포스터 + 제목 + 설명이
                    // 들어갈 수 있도록 세로가 더 길게 설정
                    childAspectRatio: 0.58,
                  ),

                  itemBuilder: (context, index) {
                    final movie = _filteredMovies[index];

                    return _MovieGridCard(movie: movie);
                  },
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------
// 영화 Grid 카드
// ---------------------------
//
// 영화 목록에서 반복해서 사용하는
// 한 개의 영화 카드 Widget.
class _MovieGridCard extends StatelessWidget {
  const _MovieGridCard({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 영화 카드를 누르면
      // 해당 영화의 ID를 Path Parameter로 전달함.
      onTap: () {
        context.push('/movies/${movie.id}');
      },

      behavior: HitTestBehavior.opaque,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------
          // 포스터 + 평점 배지
          // ---------------------------
          Expanded(
            child: Stack(
              children: [
                // 영화 포스터
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),

                    child: Image.asset(
                      movie.posterAsset,

                      // 별빛 아래 우리의 경우
                      // 세로 포스터 Asset이 따로 없기 때문에
                      // 현재 제공된 이미지를 카드 크기에 맞게 잘라 사용함.
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Figma처럼
                // 포스터 오른쪽 위에 평점 표시
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 11),

                        const SizedBox(width: 2),

                        Text(
                          movie.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ---------------------------
          // 영화 제목
          // ---------------------------
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 4),

          // ---------------------------
          // 연도 + 장르
          // ---------------------------
          Text(
            '${movie.year} · ${movie.genre}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.gray, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
