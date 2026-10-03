import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common_app_bar.dart';

// 영화 평점을 입력하는 화면
//
// 사용자가 별점을 선택하면 화면의 상태가 바뀌기 때문에
// StatefulWidget을 사용함.
class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  // 사용자가 현재 선택한 평점
  //
  // 처음에는 아무 별점도 선택하지 않았으므로 0.0
  double _rating = 0.0;

  // 평점을 하나라도 선택했는지 확인
  //
  // true  → 저장 버튼 활성화
  // false → 저장 버튼 비활성화
  bool get _canSave => _rating > 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1주차에 만든 공통 AppBar 재사용
      appBar: CommonAppBar(
        title: '영화 평점',
        centerTitle: true,

        // 뒤로가기 버튼
        onBack: () {
          Navigator.of(context).maybePop();
        },
      ),

      body: SafeArea(
        child: Padding(
          // 화면 좌우 여백
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            // 내용을 가로 방향으로 화면 너비에 맞춤
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              const SizedBox(height: 80),

              // 화면 안내 문구
              const Text(
                '영화는 어떠셨나요?',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLarge,
              ),

              const SizedBox(height: 12),

              Text(
                '별점을 선택해주세요.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray),
              ),

              const SizedBox(height: 40),

              // -----------------------------
              // 별점 입력 Widget
              // -----------------------------
              Center(
                child: RatingBar.builder(
                  // 처음 화면의 평점
                  initialRating: _rating,

                  // 별점 개수
                  itemCount: 5,

                  // 별 하나의 크기
                  itemSize: 44,

                  // 0.5점 단위 선택 가능
                  allowHalfRating: true,

                  // 별 사이의 여백
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4),

                  // 선택된 별의 색
                  unratedColor: AppColors.lightViolet,

                  // 별 모양
                  itemBuilder: (context, index) {
                    return const Icon(Icons.star, color: AppColors.violet);
                  },

                  // 사용자가 별점을 선택했을 때 호출됨
                  onRatingUpdate: (rating) {
                    setState(() {
                      // 선택한 평점을 State에 저장
                      _rating = rating;
                    });
                  },
                ),
              ),

              const SizedBox(height: 32),

              // -----------------------------
              // 현재 선택한 평점 표시
              // -----------------------------
              Text(
                // toStringAsFixed(1):
                // 4 → 4.0처럼 소수점 한 자리까지 표시
                '선택한 평점: ${_rating.toStringAsFixed(1)}',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  color: _canSave ? AppColors.violet : AppColors.gray,
                ),
              ),

              const SizedBox(height: 40),

              // -----------------------------
              // 평점 저장 버튼
              // -----------------------------
              ElevatedButton(
                // 별점을 선택했을 때만 버튼 활성화
                //
                // _canSave가 false이면 onPressed가 null이 되어
                // Flutter가 자동으로 버튼을 비활성화함.
                onPressed: _canSave
                    ? () {
                        // 이번 주차에서는 실제 API나 DB 저장은 하지 않음.
                        //
                        // 선택한 평점이 _rating에 저장되어 있는 상태까지만
                        // 구현하면 됨.

                        // 화면 아래에 간단한 안내 메시지 표시
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${_rating.toStringAsFixed(1)}점이 선택되었습니다.',
                            ),
                          ),
                        );
                      }
                    : null,

                style: ElevatedButton.styleFrom(
                  // 활성 상태
                  backgroundColor: AppColors.violet,
                  foregroundColor: AppColors.white,

                  // 비활성 상태
                  disabledBackgroundColor: AppColors.lightViolet,
                  disabledForegroundColor: AppColors.white,

                  // 버튼 높이
                  minimumSize: const Size.fromHeight(52),

                  // 둥근 모서리
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                child: const Text(
                  '평점 저장',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
