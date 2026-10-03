import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// 여러 화면에서 공통으로 사용할 AppBar

// StatelessWidget:
// 화면 내부에서 자체적으로 변경되는 상태가 없는 Widget

// PreferredSizeWidget:
// Scaffold의 appBar 자리에 들어가는 Widget은
// "나는 높이가 어느 정도야"라는 정보를 알려줘야 함.
// 그래서 PreferredSizeWidget을 구현함.
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,

    // 이 AppBar를 사용할 때 title은 반드시 전달해야 함.
    required this.title,

    // 아래 값들은 필요한 화면에서만 전달하면 됨.
    this.onBack,
    this.actions,

    // 값을 전달하지 않으면 false가 기본값
    this.centerTitle = false,

    // 별도의 제목 스타일을 전달할 수도 있음
    this.titleStyle,
  });

  // final:
  // 생성된 뒤에는 값이 바뀌지 않는 변수
  final String title;

  // VoidCallback?:
  // 반환값이 없는 함수.
  // ?가 있으므로 null일 수도 있음.
  // 즉, 뒤로가기 기능이 없는 화면에서는 전달하지 않아도 됨.
  final VoidCallback? onBack;

  // AppBar 오른쪽에 들어갈 Widget들의 목록
  // 예: 검색 버튼, 설정 버튼 등
  final List<Widget>? actions;

  // 제목을 가운데 정렬할지 여부
  final bool centerTitle;

  // 화면에 따라 다른 TextStyle을 전달하고 싶을 때 사용
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // AppBar에 표시할 제목
      title: Text(
        title,

        // ?? 연산자:
        // titleStyle이 전달되었다면 그 스타일을 사용하고,
        // null이면 오른쪽의 기본 스타일을 사용함.
        style:
            titleStyle ??
            AppTextStyles.titleLarge.copyWith(
              // 기존 titleLarge 스타일은 유지하면서
              // 글자색만 violet으로 변경
              color: AppColors.violet,
            ),
      ),

      // true면 제목 가운데 정렬
      // false면 기본 정렬 사용
      centerTitle: centerTitle,

      // AppBar 왼쪽 영역
      //
      // onBack이 null이면 뒤로가기 버튼을 표시하지 않음.
      // onBack 함수가 전달된 경우에만 버튼을 표시함.
      leading: onBack == null
          ? null
          : IconButton(
              icon: const Icon(Icons.arrow_back),

              // 버튼을 눌렀을 때 전달받은 onBack 함수 실행
              onPressed: onBack,
            ),

      // AppBar 오른쪽에 표시할 Widget들
      actions: actions,
    );
  }

  // Scaffold에게 이 AppBar의 높이를 알려줌.
  //
  // kToolbarHeight는 Flutter가 제공하는
  // 기본 AppBar 높이 값(56.0)
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
