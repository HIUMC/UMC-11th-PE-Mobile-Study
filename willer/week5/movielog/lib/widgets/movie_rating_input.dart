import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // RatingBar 사용 가능

class MovieRatingInput extends StatelessWidget { // 별점을 입력받는 위젯. 별을 그리기만 하고 점수는 부모가 들고 있음
  const MovieRatingInput({
    super.key,
    required this.rating, // 필수. 지금 몇 점인지 부모가 알려줌
    required this.onChanged, // 필수. 점수가 바뀌면 부모에게 알릴 함수
  });

  final double rating;
  final ValueChanged<double> onChanged; // void Function(double)의 별칭. 바뀐 점수를 들고 부모에게 알림

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder( // 사용자가 직접 별점을 고르는 위젯
      initialRating: rating, // 처음 그릴 때의 점수. 처음 한 번만 쓰이고 이후 별 모양은 위젯이 내부에서 따로 기억함
      minRating: 0.5, // 고를 수 있는 최소 점수. 0점은 선택 불가
      allowHalfRating: true, // 별 반 개 단위 허용. 0.5, 1.0, 1.5 ... 5.0
      itemCount: 5, // 별 5개
      itemSize: 40, // 별 하나 크기
      itemBuilder: (context, index) { // index번째 별을 어떻게 그릴지
        return const Icon(
          Icons.star,
          color: Colors.amber,
        );
      },
      onRatingUpdate: onChanged, // 별을 누를 때마다 새 점수로 실행됨. 받은 함수를 그대로 연결해서 부모에게 전달
    );
  }
}