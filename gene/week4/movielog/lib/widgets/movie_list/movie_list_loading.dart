import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'movie_grid.dart';

/// 영화 카드 모양의 Skeleton Grid.
class MovieListLoading extends StatefulWidget {
  const MovieListLoading({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  State<MovieListLoading> createState() => _MovieListLoadingState();
}

class _MovieListLoadingState extends State<MovieListLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween<double>(
    begin: 0.45,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '영화 목록을 불러오는 중',
      child: FadeTransition(
        opacity: _opacity,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: movieGridPadding,
          gridDelegate: movieGridDelegate,
          itemCount: widget.itemCount,
          itemBuilder: (context, index) => const MovieCardSkeleton(),
        ),
      ),
    );
  }
}

class MovieCardSkeleton extends StatelessWidget {
  const MovieCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _SkeletonLine(widthFactor: 0.8),
        const SizedBox(height: 8),
        const _SkeletonLine(widthFactor: 0.5),
      ],
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 16,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
