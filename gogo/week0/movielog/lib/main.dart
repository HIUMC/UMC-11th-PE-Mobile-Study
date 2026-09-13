import 'package:flutter/material.dart';

//급한대로 GPT..

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MovieLogStartScreen(),
    );
  }
}

class MovieLogStartScreen extends StatelessWidget {
  const MovieLogStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // 상단 텍스트
              const Text(
                'FLUTTER 0주차',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const Spacer(),
              // 중앙 아이콘
              const Icon(
                Icons.movie_outlined,
                size: 70,
                color: Color(0xFF553893), // 디자인과 유사한 보라색 지정
              ),
              const SizedBox(height: 24),
              // 메인 타이틀
              const Text(
                '영화의 순간을\n기록하세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              // 서브 타이틀 설명
              const Text(
                '보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              // 시작하기 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {}, // 화면 이동 기능 없음 (요구사항)
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF553893),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '시작하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
