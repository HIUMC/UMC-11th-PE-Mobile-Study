import 'package:flutter/material.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.movie_outlined,
              size: 72,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 16),
            const Text(
              '영화의 순간을 기록하세요',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              '보고 싶은 영화부터 나만의 평점까지 한곳에서 관리해요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                debugPrint('시작하기 버튼을 눌렀습니다.');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: const Text('시작하기'),
            )
          ],
        ),
        
      ),
    );
  }
}