import 'package:flutter/material.dart';
import 'screens/ProfileView.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,

      // 지금은 프로필 화면 확인용
      home: const ProfileView(),
    );
  }
}