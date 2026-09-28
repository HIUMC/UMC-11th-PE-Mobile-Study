import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemUiOverlayStyle 때문에 필요. 상태바나 시스템 UI를 다루는 건 플랫폼과 통신하는 영역이라 services에 들어있음
import 'app_text_styles.dart';

import 'app_colors.dart';

abstract final class AppTheme { // 여긴 const가 아니라 final. 아래의 ColorScheme.fromSeed(..)가 실행 시점에 색 팔레트를 계산하는 함수 호출이라 컴파일 시점에 값이 확정되지 않음
  static final ThemeData light = ThemeData(
    useMaterial3: true, // Material Design 3 사용
    fontFamily: 'Manrope',
    scaffoldBackgroundColor: AppColors.warmWhite, // 모든 Scaffold의 기본 배경색
    colorScheme: ColorScheme.fromSeed( // 색 하나(seed)를 주면 그것과 조화를 이루는 팔레트 수십 개를 자동 생성한다. primary, onPrimary,
      seedColor: AppColors.violet,   // secondary, surface, onSurface, error등이 만들어 짐.
      surface: AppColors.warmWhite,  // Chip이나 버튼 같은 기본 위젯이 아무 설정없이도 보라 계열로 나오게됨.
    ),
    textTheme: const TextTheme(
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
    ),
    appBarTheme: const AppBarTheme( // 모든 AppBar에 공통 적용할 스타일. 한 번 쓰면 화면이 몇개든 전부 적용됨.
      backgroundColor: AppColors.warmWhite, // AppBar 배경색
      foregroundColor: AppColors.black, // 그 안의 글자와 아이콘 색
      centerTitle: false, // 제목을 왼쪽 정렬
      elevation: 0, // 여기포함 밑에 4줄은 Material 3의 AppBar 그림자, 색조를 전부 끄는 역할
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle( // AppBar보다 위, 시스템 영역(시계,배터리 있는 상태바와 안드로이드 하단 바)을 다룸
        statusBarColor: Colors.transparent,   // 배경이 거의 흰색이라 어둡게
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.warmWhite,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
  );
}