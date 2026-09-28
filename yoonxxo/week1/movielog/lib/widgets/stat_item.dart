import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// 통계 카드 하나를 담당하는 Widget
class StatItem extends StatelessWidget {
  const StatItem({
    super.key,

    // 카드 위쪽에 표시될 이름
    // 예: 본 영화, 평점, 즐겨찾기
    required this.label,

    // 카드 아래쪽에 표시될 값
    // 예: 342, 4.2, 58
    required this.value,
  });

  // final:
  // Widget이 생성된 이후 값이 바뀌지 않도록 함.
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      // 카드 안쪽 여백
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

      // 카드의 모양을 설정하는 부분
      decoration: BoxDecoration(
        // 카드 배경색
        color: AppColors.lightGray,

        // 카드 테두리
        border: Border.all(color: AppColors.lightViolet, width: 1),

        // 카드 모서리를 둥글게
        borderRadius: BorderRadius.circular(12),
      ),

      // 카드 내부의 글자들을 위에서 아래로 배치
      child: Column(
        // 카드 안의 내용을 가운데 정렬
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          // 통계 항목 이름
          Text(label, style: AppTextStyles.bodySmall),

          // 이름과 값 사이 간격
          const SizedBox(height: 8),

          // 통계 값
          Text(
            value,

            // 기존 titleLarge 스타일에서
            // 색상만 보라색으로 변경
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.violet),
          ),
        ],
      ),
    );
  }
}
