import 'package:flutter/material.dart';

import 'movie_rating_input.dart';

/// 선택은 Dialog 안에서만 바뀌며, 확인했을 때만 호출 화면에 반환함.
class RatingDialog extends StatefulWidget {
  const RatingDialog({
    super.key,
    required this.movieTitle,
    this.initialRating = 0,
  });

  final String movieTitle;
  final double initialRating;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late double _rating = widget.initialRating;
  int _resetVersion = 0;

  void _reset() => setState(() {
    _rating = 0;
    // [복습 · Key] 키가 달라지면 자식 State 재생성 → RatingBar 내부 선택도 초기화.
    _resetVersion++;
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('영화는 어떠셨나요?', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(widget.movieTitle, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FittedBox(
              child: MovieRatingInput(
                key: ValueKey(_resetVersion),
                rating: _rating,
                onChanged: (value) => setState(() => _rating = value),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _rating == 0
                  ? '별점을 선택해주세요'
                  : '${_rating.toStringAsFixed(1)} / 5.0',
            ),
            TextButton.icon(
              onPressed: _rating == 0 ? null : _reset,
              icon: const Icon(Icons.refresh),
              label: const Text('평점 초기화 · 다시 선택하기'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: _rating >= 0.5
                        ? () => Navigator.pop(context, _rating)
                        : null,
                    child: const Text('확인'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
