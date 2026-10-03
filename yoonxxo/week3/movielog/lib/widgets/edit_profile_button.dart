import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// 프로필 수정 버튼만 담당하는 Widget
class EditProfileButton extends StatelessWidget {
  const EditProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    // TextButton:
    // 기본적으로 배경 강조가 적은 버튼.
    // style을 직접 지정해서 Figma처럼 테두리 버튼으로 꾸밀 수 있음.
    return TextButton(
      // 1주차에서는 실제 화면 이동 기능을 구현하지 않으므로
      // 빈 함수만 전달함.
      //
      // onPressed가 null이면 버튼 자체가 비활성화되기 때문에
      // () {} 형태로 넣어주는 것.
      onPressed: () {},

      // TextButton의 디자인 설정
      style: TextButton.styleFrom(
        // 버튼의 글자색
        foregroundColor: AppColors.violet,

        // 버튼 안쪽 여백
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),

        // 버튼의 보라색 테두리
        side: const BorderSide(color: AppColors.violet, width: 1),

        // 버튼 모서리를 둥글게 만듦
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // 버튼 안에 표시할 글자
      child: Text(
        '프로필 수정',

        // 기존 bodyMedium 스타일을 가져오되
        // 색상과 굵기만 버튼에 맞게 변경
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.violet,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
