import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_style.dart';
import 'package:movielog/widgets/app_bottom_nav_bar.dart';
import 'package:movielog/widgets/common_app_bar.dart';
import 'package:movielog/widgets/stat_item.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: '내 프로필'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 3,
                  ),
                ),
                child: const ClipOval(
                  child: Image(
                    image: AssetImage(
                      'assets/images/profile/profile_movielog.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('무비러버', style: AppTextStyles.titleLarge),
              const SizedBox(height: 12),
              Text(
                '매주 주말엔 영화관으로 출근하는 프로 관람객. 좋은 영화를 보고 기록하는 것을 좋아합니다.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                child: const Text(
                  '프로필 수정',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Expanded(
                    child: StatItem(label: '본 영화', value: '342'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: StatItem(label: '평점', value: '4.2'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: StatItem(label: '즐겨찾기', value: '58'),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('선호하는 장르', style: AppTextStyles.titleMedium),
              ),
              const SizedBox(height: 12),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _GenreChip(label: '드라마'),
                  _GenreChip(label: 'SF'),
                  _GenreChip(label: '애니메이션'),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(current: NavTab.my),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
