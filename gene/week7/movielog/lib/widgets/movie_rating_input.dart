import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:movielog/theme/app_colors.dart';

/// 서버 평점 규칙(1~5 정수)에 맞춰 별을 한 개 단위로만 고르는 입력 위젯입니다.
class MovieRatingInput extends StatelessWidget {
  const MovieRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
    this.enabled = true,
  });

  final double rating;
  final ValueChanged<double> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: rating,
      minRating: 1,
      allowHalfRating: false,
      glow: false,
      itemSize: 40,
      itemPadding: const EdgeInsets.symmetric(horizontal: 2),
      unratedColor: AppColors.surfaceVariant,
      ignoreGestures: !enabled,
      itemBuilder: (context, _) =>
          const Icon(Icons.star_rounded, color: AppColors.primary),
      onRatingUpdate: onChanged,
    );
  }
}
