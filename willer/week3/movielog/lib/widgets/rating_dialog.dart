import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import 'movie_rating_input.dart'; // 같은 widgets 폴더 안이라 ../ 없이 파일 이름만

class RatingDialog extends StatefulWidget { // 별점을 고르는 커스텀 Dialog. 떠 있는 동안 고른 점수를 기억해야 해서 StatefulWidget
  const RatingDialog({super.key});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double rating = 0; // 확인을 누르기 전까지의 임시 점수. 상세 화면에는 아직 반영 안 됨. 0은 아직 안 골랐다는 뜻

  @override
  Widget build(BuildContext context) {
    return Dialog( // 정해진 틀이 없는 빈 상자 Dialog. 안에 원하는 위젯을 자유롭게 배치
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 차지. 없으면 Column이 세로로 끝까지 늘어나서 Dialog가 화면을 덮음
          children: [
            const Text('영화는 어떠셨나요?', style: AppTextStyles.titleMedium),
            const SizedBox(height: 24),
            MovieRatingInput(
              rating: rating, // 현재 임시 점수를 넘겨줌
              onChanged: (value) { // 별을 누르면 새 점수가 value로 들어옴
                setState(() {
                  rating = value; // 점수를 바꾸고 다시 그림. 확인 버튼 상태도 같이 바뀜
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: rating > 0 // 별을 하나라도 골라야 활성화. onPressed가 null이면 Flutter가 자동으로 비활성화
                  ? () => Navigator.pop(context, rating) // Dialog를 닫으면서 점수를 돌려줌. 두 번째 값이 showDialog의 결과가 됨
                  : null,
              child: const Text('확인'),
            ),
          ],
        ),
      ),
    );
  }
}