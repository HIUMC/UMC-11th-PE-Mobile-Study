import 'package:flutter/material.dart'; // ThemeData, ColorScheme 등 Material 위젯 전반
import 'package:flutter/services.dart'; // SystemUiOverlayStyle — 상태바·내비게이션바 색 제어
import 'app_text_styles.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  // 입력창과 버튼의 모서리 둥글기를 한 곳에서 관리하려고 상수로 뺐다.
  // 값을 바꾸면 테두리 4종과 버튼이 함께 바뀐다.
  static const _radius = 14.0; // 앞의 _는 이 파일 밖에서 접근 불가라는 뜻

  // 테두리 4종을 만드는 함수. 색과 두께만 다르고 나머지는 같아서 함수로 분리했다.
  static OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder( // 사방을 감싸는 테두리. 밑줄만 있는 UnderlineInputBorder와 대비됨
      borderRadius: BorderRadius.circular(_radius), // 네 모서리를 같은 값으로 둥글게
      borderSide: BorderSide(color: color, width: width), // 선의 색과 굵기
    );
  }

  static final ThemeData light = ThemeData( // 앱 전체에 적용할 테마 묶음
    useMaterial3: true, // Material 3 디자인 시스템 사용
    fontFamily: 'Manrope', // pubspec.yaml에 등록한 폰트. 앱 전체 기본 글꼴
    scaffoldBackgroundColor: AppColors.warmWhite, // 모든 Scaffold의 기본 배경색
    colorScheme: ColorScheme.fromSeed( // 씨앗 색 하나로 조화로운 색 세트를 자동 생성
      seedColor: AppColors.violet,
      surface: AppColors.warmWhite,
      error: AppColors.error, // Material 기본 빨강 대신 우리 에러색을 쓰게 함
    ),
    textTheme: const TextTheme( // Theme.of(context).textTheme으로 꺼내 쓸 수 있는 글꼴 세트
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
    ),
    appBarTheme: const AppBarTheme( // 모든 AppBar의 기본 스타일
      backgroundColor: AppColors.warmWhite,
      foregroundColor: AppColors.black, // 뒤로가기 아이콘 색
      centerTitle: false, // 제목 왼쪽 정렬이 기본. 회원가입 화면에서는 true로 덮어씀
      elevation: 0, // 그림자 없음
      scrolledUnderElevation: 0, // 스크롤해서 내용이 앱바 아래로 지나갈 때도 그림자 없음
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent, // Material 3가 자동으로 입히는 색조를 끔
      systemOverlayStyle: SystemUiOverlayStyle( // 폰 상단 시계·배터리 영역과 하단 바
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // 안드로이드: 시계 아이콘을 어둡게
        statusBarBrightness: Brightness.light, // iOS: 배경이 밝다고 알림
        systemNavigationBarColor: AppColors.warmWhite,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
    // 입력창 스타일을 여기 한 번만 정의하면 세 입력창이 모두 따른다.
    // 각 TextFormField에서 따로 지정할 필요가 없다.
    inputDecorationTheme: InputDecorationTheme(
      filled: true, // 입력창 안을 색으로 채움. false면 투명
      fillColor: AppColors.fieldFill,
      contentPadding: const EdgeInsets.symmetric( // 입력창 안쪽 여백
        horizontal: 16, // 좌우
        vertical: 18, // 위아래. 값이 클수록 입력창이 두꺼워짐
      ),
      hintStyle: AppTextStyles.hint,
      errorStyle: AppTextStyles.error, // validator가 반환한 문자열에 적용
      enabledBorder: _border(AppColors.fieldBorder, 1), // 평소
      focusedBorder: _border(AppColors.violet, 2), // 커서가 들어온 상태
      errorBorder: _border(AppColors.error, 1), // 검증 실패
      focusedErrorBorder: _border(AppColors.error, 2), // 검증 실패 + 커서 들어온 상태
    ),
    elevatedButtonTheme: ElevatedButtonThemeData( // 모든 ElevatedButton의 기본 스타일
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.violet, // 활성 상태 배경
        foregroundColor: AppColors.white, // 활성 상태 글자
        disabledBackgroundColor: AppColors.violetLight, // onPressed가 null일 때 배경
        disabledForegroundColor: AppColors.white, // onPressed가 null일 때 글자
        elevation: 0, // 그림자 없음. 피그마가 평면 디자인
        padding: const EdgeInsets.symmetric(vertical: 18), // 버튼 높이를 결정
        shape: RoundedRectangleBorder( // 기본 알약 모양 대신 각진 둥근 사각형
          borderRadius: BorderRadius.circular(_radius), // 입력창과 같은 둥글기
        ),
        textStyle: AppTextStyles.button,
      ),
    ),
    checkboxTheme: CheckboxThemeData( // 모든 Checkbox의 기본 스타일
      // WidgetStateProperty는 "상태에 따라 다른 값을 주는 것"이다.
      // 체크된 상태면 보라색, 아니면 투명(테두리만 보임).
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) { // 체크된 상태인지 확인
          return AppColors.violet;
        }
        return Colors.transparent;
      }),
      checkColor: const WidgetStatePropertyAll(AppColors.white), // 체크 표시(V) 색. 상태와 무관하게 항상 흰색
      side: const BorderSide(color: AppColors.gray, width: 1.5), // 체크 안 됐을 때 테두리
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6), // 입력창보다 덜 둥글게
      ),
    ),
  );
}