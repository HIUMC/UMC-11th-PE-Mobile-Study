import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../data/models/rating_request.dart';
import '../data/services/rating_api_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'movie_rating_input.dart'; // 같은 widgets 폴더 안이라 ../ 없이 파일 이름만
import 'movielog_button.dart';

class RatingDialog extends StatefulWidget { // 별점과 코멘트를 받아 저장까지 하는 커스텀 Dialog. 등록과 수정에서 같이 씀
  const RatingDialog({
    super.key,
    this.initialScore = 0, // 0이면 아직 안 고른 상태. 수정할 때는 기존 점수
    this.initialComment, // 수정할 때 기존 코멘트. null이면 빈 칸
    required this.onSubmit, // 실제 저장 로직은 부르는 화면이 정함
  });

  final int initialScore;
  final String? initialComment;
  final Future<void> Function(int score, String? comment) onSubmit; // 예외 없이 끝나면 저장 성공

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late int _score = widget.initialScore; // late라서 처음 읽을 때 한 번만 초기값을 넣음
  late final _commentController = TextEditingController(text: widget.initialComment ?? ''); // build 안에서 만들면 다시 그릴 때마다 입력이 초기화됨
  bool _isSubmitting = false; // 저장 중이면 입력, 버튼, 닫기를 막음
  String? _errorText; // 저장 실패 문구. 입력값은 그대로 둠

  @override
  void dispose() {
    _commentController.dispose(); // Dialog를 여러 번 열고 닫아도 Controller가 쌓이지 않게 정리
    super.dispose();
  }

  Future<void> _onConfirm() async {
    final trimmed = _commentController.text.trim();
    if (trimmed.length > 500) { // maxLength로 막지만 붙여넣기 같은 경우를 한 번 더 확인
      setState(() => _errorText = '코멘트는 500자 이하로 입력해 주세요.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await widget.onSubmit(_score, trimmed.isEmpty ? null : trimmed); // 빈 코멘트는 null로 보냄
      if (!mounted) return;
      Navigator.pop(context, true); // 저장까지 끝났을 때만 true
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false; // 되돌리지 않으면 버튼이 계속 로딩 상태로 남음
        _errorText = switch (error) { // 서버 message를 그대로 보여서 400, 403, 404, 409를 구분
          DioException dioError => writeErrorMessage(dioError),
          StateError(:final message) => message,
          _ => '저장하지 못했습니다. 잠시 후 다시 시도해 주세요.',
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope( // 저장 중에는 뒤로가기로 못 닫음. 바깥 탭은 showDialog의 barrierDismissible로 막음
      canPop: !_isSubmitting,
      child: Dialog( // 정해진 틀이 없는 빈 상자 Dialog. 안에 원하는 위젯을 자유롭게 배치
        backgroundColor: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 차지. 없으면 Column이 세로로 끝까지 늘어나서 Dialog가 화면을 덮음
            crossAxisAlignment: CrossAxisAlignment.stretch, // 코멘트 입력창과 버튼 줄이 가로로 꽉 차게
            children: [
              const Text(
                '평점을 남겨주세요',
                style: AppTextStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Center( // 별 묶음은 내용 크기만큼만 차지하고 가운데로
                child: MovieRatingInput(
                  rating: _score.toDouble(), // RatingBar는 double을 받음
                  enabled: !_isSubmitting,
                  onChanged: (value) => setState(() => _score = validateServerScore(value)), // 1.0 같은 값을 정수로 바꿔 저장
                ),
              ),
              const SizedBox(height: 28),
              Text(
                '코멘트 (선택, 최대 500자)',
                style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                enabled: !_isSubmitting,
                maxLines: 4,
                maxLength: 500, // 500자를 넘으면 더 입력되지 않음
                decoration: InputDecoration(
                  hintText: '이 영화의 인상적인 장면은...',
                  hintStyle: AppTextStyles.bodySmall,
                  counterText: '', // 입력창 아래 글자 수 표시를 숨김
                  fillColor: AppColors.violetFaint,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.violetLight, width: 1.5),
                  ),
                ),
              ),
              if (_errorText != null) ...[ // 실패했을 때만 문구와 간격을 넣음
                const SizedBox(height: 8),
                Text(_errorText!, style: AppTextStyles.error),
              ],
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded( // 두 버튼이 가로를 반씩 나눔
                    child: SizedBox(
                      height: 44, // 옆의 확인 버튼과 높이를 맞춤
                      child: TextButton(
                        onPressed: _isSubmitting ? null : () => Navigator.pop(context, false), // 취소는 onSubmit을 부르지 않아서 요청도 없음
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.violetSoft,
                          foregroundColor: AppColors.violet,
                          shape: const StadiumBorder(), // 양 끝이 둥근 알약 모양
                          textStyle: AppTextStyles.button,
                        ),
                        child: const Text('취소'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MovieLogButton(
                      label: '확인',
                      width: double.infinity, // Expanded가 정한 너비를 꽉 채움
                      borderRadius: 22, // 높이 44의 절반이라 알약 모양
                      isLoading: _isSubmitting, // 저장 중이면 회색 버튼과 인디케이터
                      onPressed: _score > 0 ? _onConfirm : null, // 별점을 골라야만 활성화. 코멘트만 있으면 비활성
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}