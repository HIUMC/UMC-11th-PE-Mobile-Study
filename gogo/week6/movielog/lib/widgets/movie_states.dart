import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// [도전 · Skeleton] 실제 카드와 비슷한 자리 표시자로 로딩 중 레이아웃 안내.
// Semantics는 시각적 모양을 읽기 어려운 사용자에게 로딩 상태 전달.
class MovieLoading extends StatelessWidget {
  const MovieLoading({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    label: '영화를 불러오는 중',
    liveRegion: true,
    child: GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 20,
        childAspectRatio: .58,
      ),
      itemBuilder: (_, index) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: .69,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(height: 16, width: 120, color: AppColors.cardSurface),
          const SizedBox(height: 8),
          Container(height: 12, width: 80, color: AppColors.cardSurface),
        ],
      ),
    ),
  );
}

// [학습 · Empty ≠ Error] 조회 성공 후 결과가 0개인 상태. 오류와 별도 안내 필요.
class MovieEmpty extends StatelessWidget {
  const MovieEmpty({super.key, required this.onReset});
  final VoidCallback onReset;
  @override
  Widget build(BuildContext context) => _Message(
    icon: Icons.movie_filter_outlined,
    title: '조건에 맞는 영화가 없어요',
    subtitle: '검색어나 장르를 바꾸거나 새로고침해 주세요.',
    action: TextButton(onPressed: onReset, child: const Text('전체 영화 보기')),
  );
}

class MovieError extends StatelessWidget {
  const MovieError({super.key, required this.onRetry, this.timedOut = false});
  final VoidCallback onRetry;
  final bool timedOut;
  @override
  Widget build(BuildContext context) => _Message(
    icon: Icons.cloud_off_rounded,
    title: timedOut ? '응답이 늦어지고 있어요' : '영화를 불러오지 못했어요',
    subtitle: '잠시 후 다시 시도해 주세요.',
    action: FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
  );
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
  });
  final IconData icon;
  final String title, subtitle;
  final Widget action;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) => ListView(
      // 짧은 안내 화면도 아래로 당길 수 있게 설정 → 빈 결과·오류에서도 새로고침 가능.
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: bounds.maxHeight,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: AppColors.hint),
                const SizedBox(height: 16),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(subtitle, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                action,
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
