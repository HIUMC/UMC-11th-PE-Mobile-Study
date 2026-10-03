import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_movies.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../widgets/movie_rating_input.dart';

// 영화 상세 화면
//
// Route로 전달받은 movieId를 이용해
// Mock Data에서 해당 영화를 찾아 화면에 표시함.
class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  // /movies/:movieId에서 전달받은 영화 ID
  final int movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  // 즐겨찾기 여부
  //
  // 실제 서버에는 저장하지 않고
  // 현재 화면 안에서만 상태를 관리함.
  bool _isFavorite = false;

  // 사용자가 Dialog에서 등록한 별점
  //
  // 아직 등록하지 않았다면 null
  double? _myRating;

  // ---------------------------
  // 평점 Dialog 열기
  // ---------------------------
  Future<void> _showRatingDialog() async {
    // Dialog에서 Navigator.pop(context, rating)으로
    // 전달된 별점을 받아옴.
    final rating = await showDialog<double>(
      context: context,
      builder: (context) {
        return const _RatingDialog();
      },
    );

    // Dialog를 취소해서 rating이 null이면
    // 아무것도 변경하지 않음.
    if (rating == null) {
      return;
    }

    // 사용자가 선택한 별점을 화면 상태에 저장
    setState(() {
      _myRating = rating;
    });

    if (!mounted) {
      return;
    }

    // 별점 등록 결과를 Snackbar로 안내
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${rating.toStringAsFixed(1)}점을 등록했습니다.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ---------------------------
  // 즐겨찾기 상태 변경
  // ---------------------------
  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    // 즐겨찾기 추가/삭제 결과를
    // 짧은 메시지로 안내함.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? '즐겨찾기에 추가했습니다.' : '즐겨찾기에서 삭제했습니다.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Route에서 받은 ID를 이용해
    // 공통 Mock Data에서 영화 찾기
    final Movie? movie = findMovieById(widget.movieId);

    // 존재하지 않는 ID라면
    // 간단한 오류 화면 표시
    if (movie == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: const Center(child: Text('영화 정보를 찾을 수 없습니다.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F5),

      // ---------------------------
      // 상단 AppBar
      // ---------------------------
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F5),
        surfaceTintColor: Colors.transparent,

        // 상세 화면에서 이전 화면으로 돌아가기
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.violet),
        ),

        title: const Text(
          'Cinema Archive',
          style: TextStyle(
            color: AppColors.violet,
            fontWeight: FontWeight.w700,
          ),
        ),

        centerTitle: true,

        actions: [
          // 공유 기능은 이번 미션 범위가 아니므로
          // 아이콘 UI만 표시함.
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
        ],
      ),

      // ---------------------------
      // 상세 화면 본문
      // ---------------------------
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------------------
            // 영화 대표 이미지
            // ---------------------------
            Image.asset(
              movie.posterAsset,
              width: double.infinity,
              height: 330,
              fit: BoxFit.cover,
            ),

            // ---------------------------
            // 영화 기본 정보
            // ---------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${movie.year} · ${movie.genre} · 120분',
                    style: TextStyle(color: AppColors.gray, fontSize: 12),
                  ),

                  const SizedBox(height: 14),

                  // ---------------------------
                  // 평균 평점
                  // ---------------------------
                  Row(
                    children: [
                      // 평균 평점은 사용자가 수정할 수 없으므로
                      // RatingBarIndicator 사용
                      RatingBarIndicator(
                        // 과제에서 요구한 Mock 평균 평점
                        rating: 4.5,

                        itemCount: 5,
                        itemSize: 18,

                        itemBuilder: (context, index) {
                          return const Icon(
                            Icons.star,
                            color: AppColors.violet,
                          );
                        },
                      ),

                      const SizedBox(width: 8),

                      const Text(
                        '4.5',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(width: 4),

                      Text(
                        '(1,245)',
                        style: TextStyle(color: AppColors.gray, fontSize: 11),
                      ),
                    ],
                  ),

                  // 사용자가 직접 등록한 별점이 있다면
                  // 화면에 추가로 표시함.
                  if (_myRating != null) ...[
                    const SizedBox(height: 8),

                    Text(
                      '내 평점 ${_myRating!.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: AppColors.violet,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // ---------------------------
                  // 장르 태그
                  // ---------------------------
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MovieTag(label: movie.genre),
                      const _MovieTag(label: '드라마'),
                      const _MovieTag(label: '감동적인'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Divider(height: 1),

            // ---------------------------
            // 시놉시스
            // ---------------------------
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '시놉시스',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),

                  SizedBox(height: 12),

                  Text(
                    '바쁜 현대 사회 속에서 서로의 존재를 잊고 살아가던 '
                    '두 남녀가 우연한 계기로 작은 천문대에서 만나게 됩니다. '
                    '매일 밤 별을 관측하며 서로의 상처를 치유하고, '
                    '잊고 있던 꿈과 사랑을 다시금 깨닫게 되는 따뜻한 이야기입니다.',
                    style: TextStyle(fontSize: 13, height: 1.7),
                  ),

                  SizedBox(height: 18),

                  Text(
                    '과거의 아픔으로 인해 사람에게 마음을 열지 못하던 주인공은 '
                    '별자리처럼 변함없는 모습으로 자신을 기다려주는 상대를 통해 '
                    '서서히 마음의 문을 열게 됩니다. '
                    '하지만 두 사람 앞에 놓인 현실적인 장벽들은 '
                    '그들의 관계를 시험하게 됩니다.',
                    style: TextStyle(fontSize: 13, height: 1.7),
                  ),

                  SizedBox(height: 18),

                  Text(
                    '별이 쏟아지는 밤하늘 아래, 그들이 나눈 조용한 약속들은 '
                    '각자의 평범한 일상 속으로 돌아간 뒤에도 '
                    '오랫동안 서로의 마음을 밝혀주는 빛으로 남게 됩니다.',
                    style: TextStyle(fontSize: 13, height: 1.7),
                  ),
                ],
              ),
            ),

            // 하단 버튼과 내용이 겹치지 않도록
            // 마지막에 여백 추가
            const SizedBox(height: 20),
          ],
        ),
      ),

      // ---------------------------
      // 화면 하단 고정 버튼
      // ---------------------------
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              // 즐겨찾기 버튼
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleFavorite,

                  icon: Icon(
                    _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  ),

                  label: Text(_isFavorite ? '즐겨찾기 해제' : '즐겨찾기'),

                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.violet,

                    side: const BorderSide(color: AppColors.violet),

                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // 평점 남기기 버튼
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showRatingDialog,

                  icon: const Icon(Icons.rate_review_outlined),

                  label: const Text('평점 남기기'),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.violet,
                    foregroundColor: Colors.white,

                    minimumSize: const Size.fromHeight(48),
                  ),
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
// 영화 태그
// ---------------------------
class _MovieTag extends StatelessWidget {
  const _MovieTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),

      decoration: BoxDecoration(
        color: AppColors.lightViolet,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: AppColors.violet),
      ),
    );
  }
}

// ---------------------------
// 평점 입력 Dialog
// ---------------------------
//
// Dialog 내부에서 별점을 관리해야 하므로
// StatefulWidget을 사용함.
class _RatingDialog extends StatefulWidget {
  const _RatingDialog();

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  // 현재 선택한 별점
  double _rating = 3.0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          // Dialog가 화면 전체 높이를 차지하지 않고
          // 필요한 만큼만 사용하도록 함.
          mainAxisSize: MainAxisSize.min,

          children: [
            const Text(
              '영화는 어떠셨나요?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 8),

            const Text('별점을 선택해주세요.', style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 24),

            // 우리가 만든 공통 별점 입력 Widget
            MovieRatingInput(
              rating: _rating,

              onChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),

            const SizedBox(height: 12),

            // 현재 선택한 점수를 숫자로 표시
            Text(
              '${_rating.toStringAsFixed(1)}점',
              style: const TextStyle(
                color: AppColors.violet,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  // 선택한 별점을
                  // Dialog를 호출한 화면으로 전달
                  Navigator.pop(context, _rating);
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violet,
                  foregroundColor: Colors.white,
                ),

                child: const Text('등록하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
