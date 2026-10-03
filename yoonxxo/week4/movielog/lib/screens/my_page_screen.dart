import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// 마이페이지 화면
class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F5),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------------------
              // 화면 제목
              // ---------------------------
              const Text(
                '내 프로필',
                style: TextStyle(
                  color: AppColors.violet,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 28),

              // ---------------------------
              // 프로필 영역
              // ---------------------------
              Center(
                child: Column(
                  children: [
                    // 제공된 프로필 이미지 Asset 사용
                    const CircleAvatar(
                      radius: 45,
                      backgroundImage: AssetImage(
                        'assets/images/profile/profile_movielog.jpg',
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      '무비러버',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      '매주 주말엔 영화관으로 출근하는 프로 관람러.\n좋은 영화를 보고 기록하는 것을 좋아합니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, height: 1.5),
                    ),

                    const SizedBox(height: 18),

                    // 프로필 수정 버튼
                    OutlinedButton(
                      // 실제 프로필 수정 기능은
                      // 이번 3주차 미션 범위가 아니므로
                      // 버튼 UI만 구현함.
                      onPressed: () {},

                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.violet,
                        side: const BorderSide(color: AppColors.violet),
                      ),

                      child: const Text('프로필 수정'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ---------------------------
              // 활동 통계
              // ---------------------------
              const Row(
                children: [
                  Expanded(
                    child: _ProfileStatCard(label: '본 영화', value: '342'),
                  ),

                  SizedBox(width: 8),

                  Expanded(
                    child: _ProfileStatCard(label: '평점', value: '4.2'),
                  ),

                  SizedBox(width: 8),

                  Expanded(
                    child: _ProfileStatCard(label: '즐겨찾기', value: '58'),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ---------------------------
              // 선호하는 장르
              // ---------------------------
              const Text(
                '선호하는 장르',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _GenreChip(label: '드라마'),
                  _GenreChip(label: 'SF'),
                  _GenreChip(label: '애니메이션'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------
// 프로필 통계 카드
// ---------------------------
class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),

      decoration: BoxDecoration(
        color: AppColors.lightViolet,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11)),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              color: AppColors.violet,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------
// 선호 장르 Chip
// ---------------------------
class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),

      backgroundColor: AppColors.lightViolet,

      side: BorderSide.none,

      labelStyle: const TextStyle(
        color: AppColors.violet,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
