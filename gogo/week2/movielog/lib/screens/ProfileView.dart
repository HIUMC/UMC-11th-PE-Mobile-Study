import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold 배경색은 Theme의 surface 컬러를 따라가도록 설정되어 있습니다.
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 프로필'),
        centerTitle: false, // 디자인에 맞춰 좌측 정렬
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            ProfileHeader(),
            SizedBox(height: 32),
            ProfileStats(),
            SizedBox(height: 32),
            FavoriteGenres(),
          ],
        ),
      ),
    );
  }
}

// 1. 프로필 헤더 위젯 (사진, 닉네임, 소개, 수정 버튼)
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // 테두리가 있는 프로필 이미지
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.primary.withOpacity(0.5), width: 2),
          ),
          child: const CircleAvatar(
            radius: 48,
            backgroundImage: AssetImage('assets/images/profile/profile_movielog.jpg'),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '무비러버',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '매주 주말엔 영화관으로 출근하는 프로 관람객. 좋은\n영화를 보고 기록하는 것을 좋아합니다.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            side: BorderSide(color: colorScheme.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            '프로필 수정',
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// 2. 프로필 통계 위젯 (Row 배열)
class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: StatItem(label: '본 영화', value: '342')),
        SizedBox(width: 12),
        Expanded(child: StatItem(label: '평점', value: '4.2')),
        SizedBox(width: 12),
        Expanded(child: StatItem(label: '즐겨찾기', value: '58')),
      ],
    );
  }
}

// 3. 재사용 가능한 통계 개별 아이템
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
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(
          color: colors.primary.withOpacity(0.1), // 옅은 보라색 테두리
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.primary, // 숫자는 Primary Color 적용
            ),
          ),
        ],
      ),
    );
  }
}

// 4. 선호하는 장르 위젯
class FavoriteGenres extends StatelessWidget {
  const FavoriteGenres({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '선호하는 장르',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            GenreChip(label: '드라마'),
            SizedBox(width: 12),
            GenreChip(label: 'SF'),
            SizedBox(width: 12),
            GenreChip(label: '애니메이션'),
          ],
        ),
      ],
    );
  }
}

// 장르 칩 UI 분리
class GenreChip extends StatelessWidget {
  const GenreChip({super.key, required this.label});
  
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.1), // 연한 보라색 배경
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: colors.primary,
        ),
      ),
    );
  }
}
