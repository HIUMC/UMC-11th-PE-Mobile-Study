import 'package:flutter/material.dart'; // TextStyle, FontWeight 사용
import 'app_colors.dart'; // 색상은 AppColors에서 가져다 씀

abstract final class AppTextStyles { // AppColors와 같은 구조. 글꼴 스타일을 모아두는 상자
  static const titleLarge = TextStyle(
    fontSize: 24, // Logical Pixel 단위. 기기 밀도는 Flutter가 알아서 환산
    fontWeight: FontWeight.w700, // w100~w900. w700이 Bold
    color: AppColors.black,
  );

  static const titleMedium = TextStyle( // 회원가입 화면의 "환영합니다!"
    fontSize: 18,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.black,
  );

  static const bodyMedium = TextStyle( // 체크박스 옆 문구
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.black,
    height: 1.5, // 줄 간격 배수. 글자 크기의 1.5배
  );

  static const bodySmall = TextStyle( // 안내 문구, "이미 계정이 있나요?"
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.gray,
  );

  static const label = TextStyle( // 입력창 위에 붙는 "닉네임", "이메일", "비밀번호"
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  static const hint = TextStyle( // 입력창 안 회색 안내 문구
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.gray,
  );

  static const error = TextStyle( // validator가 반환한 오류 메시지
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
  );

  // color를 지정하지 않은 것이 의도적임
  // 버튼 글자색은 ElevatedButtonTheme의 foregroundColor와 disabledForegroundColor가 상태에 따라 정한다.
  // 여기서 색을 박으면 비활성 상태에서도 색이 안 바뀐다.
  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const appBarTitle = TextStyle( // 상단 "회원가입"
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.violet,
  );

  static const linkText = TextStyle( // 하단 "로그인"
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.violet,
  );
}