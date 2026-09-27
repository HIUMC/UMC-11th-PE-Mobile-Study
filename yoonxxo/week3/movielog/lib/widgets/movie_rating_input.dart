import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// ---------------------------
// 영화 별점 입력 Widget
// ---------------------------
//
// 사용자가 0.5점 단위로
// 영화 별점을 선택할 수 있도록 함.
//
// 실제 별점 값은 이 Widget이 직접 관리하지 않고
// 부모 Widget으로부터 전달받음.
class MovieRatingInput extends StatelessWidget {
  const MovieRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  // 현재 선택된 별점
  final double rating;

  // 별점이 변경되었을 때
  // 새로운 값을 부모에게 전달하는 함수
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      // 처음 표시할 별점
      initialRating: rating,

      // 최소 0.5점
      minRating: 0.5,

      // 0.5점 단위 선택 허용
      allowHalfRating: true,

      // 별 5개
      itemCount: 5,

      itemSize: 38,

      // 각 별의 모양
      itemBuilder: (context, index) {
        return const Icon(Icons.star, color: Colors.amber);
      },

      // 사용자가 별점을 바꾸면
      // 부모 Widget으로 새로운 값 전달
      onRatingUpdate: onChanged,
    );
  }
}
