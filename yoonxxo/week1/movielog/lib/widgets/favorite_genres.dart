import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// 프로필 화면의 "선호하는 장르" 영역을 담당하는 Widget
class FavoriteGenres extends StatelessWidget {
  const FavoriteGenres({super.key});

  @override
  Widget build(BuildContext context) {
    // Column:
    // 제목과 장르 Chip들을 위 → 아래 방향으로 배치
    return Column(
      // Column의 자식들을 왼쪽부터 시작하도록 정렬
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // 영역 제목
        const Text('선호하는 장르', style: AppTextStyles.titleMedium),

        // 제목과 Chip 사이 세로 간격
        const SizedBox(height: 12),

        // 장르 Chip들을 가로 방향으로 배치
        Row(
          children: [
            // 첫 번째 장르
            _GenreChip(label: '드라마'),

            // Chip 사이 가로 간격
            const SizedBox(width: 8),

            // 두 번째 장르
            _GenreChip(label: 'SF'),

            const SizedBox(width: 8),

            // 세 번째 장르
            _GenreChip(label: '애니메이션'),
          ],
        ),
      ],
    );
  }
}

// 장르 하나를 나타내는 작은 Widget
//
// 앞에 _가 붙은 클래스는
// 이 파일 안에서만 사용하겠다는 의미 (private class).
// 다른 Dart 파일에서는 직접 사용할 수 없음.
class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label});

  // Chip 안에 들어갈 장르 이름
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      // Chip 안에 표시될 글자
      label: Text(
        label,

        // 기존 bodySmall 스타일을 가져오고
        // 글자 색과 굵기만 변경
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.violet,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Chip 배경색
      //
      // 아직 AppColors에 연한 보라색이 없기 때문에
      // 잠시 violet에 opacity를 적용해서 사용
      backgroundColor: AppColors.lightViolet,

      // 기본 Chip 테두리를 없앰
      side: BorderSide.none,

      // Chip 모서리를 둥글게 만듦
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      // Chip 내부의 좌우 여백
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
