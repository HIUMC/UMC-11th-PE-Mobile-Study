import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '내 프로필'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 16),
                ProfileHeader(),
                SizedBox(height: 24),
                ProfileStats(),
                SizedBox(height: 32),
                FavoriteGenres(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
    this.centerTitle = false,
    this.titleStyle,
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool centerTitle;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: titleStyle ??
            AppTextStyles.titleLarge.copyWith(color: AppColors.violet),
      ),
      centerTitle: centerTitle,
      leading: onBack == null
          ? null
          : IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipOval(
          child: Image.asset(
            'assets/images/profile/profile_movielog.jpg',
            width: 112,
            height: 112,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/star.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.violet,
                BlendMode.srcIn,
              ),
              semanticsLabel: '별 아이콘',
            ),
            const SizedBox(width: 8),
            const Text('무비러버', style: AppTextStyles.titleLarge),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '매주 주말엔 영화관으로 출근하는 프로 관람객. 좋은 영화를 보고 기록하는 것을 좋아합니다.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 16),
        const EditProfileButton(),
      ],
    );
  }
}

class EditProfileButton extends StatelessWidget {
  const EditProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        debugPrint('프로필 수정 버튼을 눌렀습니다.');
      },
      style: TextButton.styleFrom(
        foregroundColor: AppColors.violet,
        backgroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: const BorderSide(color: AppColors.violet),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text('프로필 수정'),
    );
  }
}

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Expanded(child: StatItem(label: '본 영화', value: '342')),
        Expanded(child: StatItem(label: '평점', value: '4.2')),
        Expanded(child: StatItem(label: '즐겨찾기', value: '58')),
      ],
    );
  }
}

class StatItem extends StatelessWidget {
  const StatItem({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.gray.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.violet),
          ),
        ],
      ),
    );
  }
}

class FavoriteGenres extends StatelessWidget {
  const FavoriteGenres({super.key});

  static const genres = <String>['드라마', 'SF', '애니메이션'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('선호하는 장르', style: AppTextStyles.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: genres
              .map(
                (genre) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text(genre),
                    labelStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.violet,
                    ),
                    backgroundColor: AppColors.violet.withValues(alpha: 0.12),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}