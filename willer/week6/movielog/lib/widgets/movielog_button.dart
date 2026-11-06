import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MovieLogButton extends StatelessWidget { // 상태를 표시만 하는 공용 버튼. 상태를 바꾸는 건 ViewModel 몫
  const MovieLogButton({
    super.key,
    required this.label,
    required this.onPressed, // null이면 비활성
    this.isLoading = false,
    this.width, // null이면 내용 크기, double.infinity면 최대 너비, 숫자면 고정
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;

  bool get _disabled => isLoading || onPressed == null; // 통신 중이면 onPressed가 있어도 비활성

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 44,
      child: ElevatedButton(
        onPressed: _disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.violet,
          disabledBackgroundColor: isLoading ? AppColors.gray : AppColors.violetLight, // 통신 중은 회색, 조건 미충족은 연보라
          foregroundColor: AppColors.white,
          disabledForegroundColor: AppColors.white,
          minimumSize: const Size(96, 44), // 인디케이터로 바뀌어도 너비가 줄지 않게 함
          padding: const EdgeInsets.symmetric(horizontal: 16), // 테마의 세로 여백을 쓰면 44 높이에서 글자가 잘림
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading // 글자와 인디케이터 중 하나만 그림
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}