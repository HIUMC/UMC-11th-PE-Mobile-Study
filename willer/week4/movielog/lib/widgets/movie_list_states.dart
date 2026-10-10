import 'package:flutter/material.dart';

class MovieListLoading extends StatelessWidget { // 기다리는 중 화면. 빈 화면 대신 진행 표시
  const MovieListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class MovieListEmpty extends StatelessWidget { // 요청은 성공했지만 보여줄 영화가 0개인 화면
  const MovieListEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('조건에 맞는 영화가 없습니다.'),
    );
  }
}

class MovieListError extends StatelessWidget { // 요청 실패 화면. 내부 오류 대신 안내 문구와 재시도 버튼만 보여줌
  const MovieListError({
    super.key,
    required this.onRetry, // 필수. 버튼을 눌렀을 때 할 일은 부모가 정함
  });

  final VoidCallback onRetry; // 값을 받지도 돌려주지도 않는 함수 타입

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // 내용 크기만큼만 차지해서 화면 가운데에 모임
        children: [
          const Icon(Icons.error_outline),
          const SizedBox(height: 12),
          const Text('영화를 불러오지 못했습니다.'), // Exception 메시지를 그대로 쓰지 않고 고정 문구
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}