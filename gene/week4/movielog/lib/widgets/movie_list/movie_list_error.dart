import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'scrollable_fill.dart';

class MovieListError extends StatelessWidget {
  const MovieListError({
    super.key,
    required this.onRetry,
    this.message = '영화를 불러오지 못했습니다.',
  });

  final VoidCallback onRetry;

  /// 사용자에게 보여줄 안내 문구. 내부 Exception 내용은 넣지 않습니다.
  final String message;

  @override
  Widget build(BuildContext context) {
    return ScrollableFill(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Manrope',
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 24 / 16,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
