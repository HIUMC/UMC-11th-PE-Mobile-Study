import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// 프로필 화면 상단의
// 프로필 이미지 + 닉네임 + 소개글을 담당하는 Widget
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Column:
    // 자식 Widget들을 위에서 아래 방향으로 배치함.
    return Column(
      // Column 내부 Widget들을 가로 방향 가운데 정렬
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        // 원형 프로필 이미지 영역

        // 프로필 사진 바깥쪽 테두리를 만들기 위해
        // CircleAvatar를 Container로 한 번 감쌈
        Container(
          // 원형 테두리와 실제 이미지 사이의 작은 여백
          padding: const EdgeInsets.all(2),

          decoration: BoxDecoration(
            // Container 자체를 원형으로 만듦
            shape: BoxShape.circle,

            // Figma의 프로필 사진처럼 보라색 테두리 적용
            border: Border.all(color: AppColors.violet, width: 1.5),
          ),

          // ClipOval:
          // 사각형 이미지를 원 모양으로 잘라줌
          child: ClipOval(
            child: Image.asset(
              // 실제 프로필 이미지 경로
              'assets/images/profile/profile_movielog.jpg',

              // Figma의 프로필 이미지 크기
              width: 112,
              height: 112,

              // 원 영역을 이미지로 꽉 채움
              // 일부 영역이 조금 잘릴 수 있음
              fit: BoxFit.cover,
            ),
          ),
        ),

        // 프로필 사진과 닉네임 사이의 세로 간격
        const SizedBox(height: 16),

        // 닉네임
        const Text('무비러버', style: AppTextStyles.titleLarge),

        // 닉네임과 소개글 사이 간격
        const SizedBox(height: 8),

        // 소개글
        const Text(
          '매주 주말엔 영화관으로 출근하는 프로 관람객. '
          '좋은 영화를 보고 기록하는 것을 좋아합니다.',

          // 글을 가운데 정렬
          textAlign: TextAlign.center,

          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}
