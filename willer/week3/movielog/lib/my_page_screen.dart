import 'package:flutter/material.dart';

class MyPageScreen extends StatelessWidget { // 마이페이지
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('마이페이지')), // 화면 이름만 띄워서 지금 어느 Route인지 구분
    );
  }
}