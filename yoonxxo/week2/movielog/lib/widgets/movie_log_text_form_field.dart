import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';

// MovieLog에서 공통으로 사용할 입력창 Widget
//
// 닉네임 / 이메일 / 비밀번호 입력창은
// 모양은 거의 같고,
// Controller, Validator, hintText 같은 값만 다르기 때문에
// 하나의 공통 Widget으로 만들어 재사용함.
class MovieLogTextFormField extends StatelessWidget {
  const MovieLogTextFormField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.focusNode,
    required this.validator,
    required this.textInputAction,
    required this.onChanged,
    required this.hasError,

    // 현재 입력값이 정상인지 전달받음
    required this.isValid,

    // 아래 값들은 입력창마다 필요할 수도 있고
    // 필요하지 않을 수도 있으므로 선택값으로 둠.
    this.keyboardType,
    this.obscureText = false,
    this.onFieldSubmitted,
  });

  // 입력창 위에 표시되는 제목
  // 예: 닉네임, 이메일, 비밀번호
  final String label;

  // 입력창 안의 안내 문구
  final String hintText;

  // 입력값을 관리하는 Controller
  final TextEditingController controller;

  // 입력창의 Focus를 관리
  final FocusNode focusNode;

  // 입력값을 검사하는 함수
  //
  // String?을 입력받고,
  // 오류가 있다면 String 에러 메시지를 반환
  // 정상이라면 null 반환
  final String? Function(String?) validator;

  // 키보드 오른쪽 아래 버튼의 종류
  // 예: next, done
  final TextInputAction textInputAction;

  // 입력 내용이 변경됐을 때 실행할 함수
  final ValueChanged<String> onChanged;

  // 이메일처럼 특별한 키보드가 필요할 때 사용
  final TextInputType? keyboardType;

  // true면 입력 문자를 가림
  // 비밀번호 입력창에서 사용
  final bool obscureText;

  // 키보드의 next / done 버튼을 눌렀을 때 실행
  final ValueChanged<String>? onFieldSubmitted;

  // true이면 오류 상태 디자인 사용
  final bool hasError;

  // true이면 입력값이 정상임
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    return Column(
      // 제목과 입력창을 왼쪽에 맞춤
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // 입력창 제목
        Text(label, style: AppTextStyles.bodyMedium),

        const SizedBox(height: 8),

        // 실제 입력창
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: validator,

          keyboardType: keyboardType,
          textInputAction: textInputAction,

          // 비밀번호일 경우 true
          obscureText: obscureText,

          // 입력 후 자동으로 Validation 결과 표시
          autovalidateMode: AutovalidateMode.onUserInteraction,

          decoration: InputDecoration(
            // 입력 전 안내 문구
            hintText: hintText,

            // 기본 TextFormField보다 세로 여백을 줄여
            // 더 낮은 입력창으로 만듦.
            isDense: true,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),

            // 배경색 사용 여부
            filled: true,

            // Validation 오류이면 연한 빨간 배경,
            // 아니면 기본 배경색 사용
            fillColor: hasError
                ? AppColors.errorContainer
                : AppColors.warmWhite,

            // -------------------------
            // 오른쪽 상태 아이콘
            // -------------------------
            suffixIcon: hasError
                // 오류가 있는 경우 빨간 느낌표 아이콘
                ? const Icon(Icons.error_outline, color: AppColors.error)
                // 오류는 없고 정상 입력이면
                // 보라색 체크 아이콘
                : isValid
                ? const Icon(Icons.check_circle, color: AppColors.violet)
                // 아직 입력하지 않은 상태라면
                // 아무 아이콘도 표시하지 않음
                : null,

            // -------------------------
            // 기본 상태 테두리
            // -------------------------
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.gray, width: 1),
            ),

            // -------------------------
            // 입력 중일 때 테두리
            // -------------------------
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.violet, width: 1.5),
            ),

            // -------------------------
            // Validation 오류 상태
            // -------------------------
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),

            // 오류가 있으면서 현재 입력 중일 때
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),

            // 오류 메시지 스타일
            errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
          ),

          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
        ),
      ],
    );
  }
}
