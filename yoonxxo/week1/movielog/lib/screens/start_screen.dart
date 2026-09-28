import 'package:flutter/material.dart';
// SVG 이미지를 사용하기 위한 패키지
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MovieLogApp());
}

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: ThemeData(useMaterial3: true),
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF4F378A);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              const Text(
                'FLUTTER 0주차',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 44),

              // 기존 Flutter 기본 영화 아이콘 대신
              // MovieLog의 실제 SVG 로고를 표시
              SvgPicture.asset(
                'assets/logos/movielog_logo.svg',

                // 기존 Icon과 비슷한 크기
                width: 72,
                height: 72,

                // 접근성용 설명
                semanticsLabel: 'MovieLog 로고',
              ),

              const SizedBox(height: 56),

              const Text(
                '영화의 순간을\n기록하세요',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                '보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  debugPrint('시작하기 버튼을 눌렀습니다.');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '시작하기',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
