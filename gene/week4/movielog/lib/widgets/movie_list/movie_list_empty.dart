import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'scrollable_fill.dart';

class MovieListEmpty extends StatelessWidget {
  const MovieListEmpty({super.key, this.onShowAll});

  /// 장르 필터 때문에 비어 있을 때 '전체 장르 보기' 버튼을 제공합니다.
  final VoidCallback? onShowAll;

  @override
  Widget build(BuildContext context) {
    return ScrollableFill(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.movie_filter_outlined,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 12),
          const Text(
            '조건에 맞는 영화가 없습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 24 / 16,
            ),
          ),
          if (onShowAll != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onShowAll,
              child: const Text('전체 장르 보기'),
            ),
          ],
        ],
      ),
    );
  }
}
