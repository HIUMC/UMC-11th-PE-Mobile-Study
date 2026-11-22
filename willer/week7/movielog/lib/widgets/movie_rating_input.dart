import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // RatingBar 사용 가능

import '../theme/app_colors.dart';

class MovieRatingInput extends StatelessWidget { // 별점을 입력받는 위젯. 별을 그리기만 하고 점수는 부모가 들고 있음
  const MovieRatingInput({
    super.key,
    required this.rating, // 필수. 지금 몇 점인지 부모가 알려줌
    required this.onChanged, // 필수. 점수가 바뀌면 부모에게 알릴 함수
    this.enabled = true, // 저장 중에는 false로 넘겨서 별을 못 누르게 함
  });

  final double rating;
  final ValueChanged<double> onChanged; // void Function(double)의 별칭. 바뀐 점수를 들고 부모에게 알림
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return RatingBar( // 채운 별과 빈 별 모양을 따로 정할 수 있는 위젯
      initialRating: rating, // 처음 그릴 때의 점수. 처음 한 번만 쓰이고 이후 별 모양은 위젯이 내부에서 따로 기억함
      minRating: 1, // 서버 점수가 1~5라 최소 1점
      allowHalfRating: false, // 서버가 정수만 받아서 별 한 개 단위로만 고름
      ignoreGestures: !enabled, // true면 탭을 무시함
      itemCount: 5, // 별 5개
      itemSize: 44, // 별 하나 크기
      ratingWidget: RatingWidget(
        full: const Icon(Icons.star_rounded, color: AppColors.violet), // 고른 별
        half: const Icon(Icons.star_half_rounded, color: AppColors.violet), // 반 별을 막아서 쓰이지 않지만 필수 인자
        empty: const Icon(Icons.star_border_rounded, color: AppColors.violet), // 안 고른 별은 테두리만
      ),
      onRatingUpdate: onChanged, // 별을 누를 때마다 새 점수로 실행됨. 받은 함수를 그대로 연결해서 부모에게 전달
    );
  }
}