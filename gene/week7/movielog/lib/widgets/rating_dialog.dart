import 'package:flutter/material.dart';

import 'package:movielog/data/models/rating_request.dart';
import 'package:movielog/widgets/movie_rating_input.dart';
import 'package:movielog/widgets/movielog_button.dart';

/// 평점(1~5)과 코멘트를 입력받아 [onSubmit]으로 저장하는 다이얼로그입니다.
/// 저장에 성공하면 true, 취소하면 false를 pop으로 돌려줍니다.
class RatingDialog extends StatefulWidget {
  const RatingDialog({
    super.key,
    this.initialScore = 0,
    this.initialComment,
    required this.onSubmit,
  });

  final int initialScore;
  final String? initialComment;
  final Future<void> Function(int score, String? comment) onSubmit;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late int _score = widget.initialScore;
  late final _commentController = TextEditingController(
    text: widget.initialComment ?? '',
  );
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting,
      child: AlertDialog(
        title: const Text('평점을 남겨주세요'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MovieRatingInput(
              rating: _score.toDouble(),
              enabled: !_isSubmitting,
              onChanged: (value) =>
                  setState(() => _score = validateServerScore(value)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 3,
              maxLength: 500,
              enabled: !_isSubmitting,
              decoration: const InputDecoration(hintText: '코멘트를 남겨보세요 (선택)'),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 8),
              Text(_errorText!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
        actions: [
          MovieLogButton(
            label: '취소',
            onPressed: _isSubmitting
                ? null
                : () => Navigator.pop(context, false),
          ),
          MovieLogButton(
            label: '확인',
            isLoading: _isSubmitting,
            onPressed: _score > 0 && !_isSubmitting ? _onConfirm : null,
          ),
        ],
      ),
    );
  }

  Future<void> _onConfirm() async {
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final trimmed = _commentController.text.trim();
    if (trimmed.length > 500) {
      setState(() {
        _isSubmitting = false;
        _errorText = '코멘트는 500자 이하로 입력해 주세요.';
      });
      return;
    }
    try {
      await widget.onSubmit(_score, trimmed.isEmpty ? null : trimmed);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorText = '저장하지 못했습니다. 잠시 후 다시 시도해 주세요.';
      });
    }
  }
}
