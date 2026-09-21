import 'package:flutter/material.dart';
import 'screens/ProfileView.dart';
import 'theme/app_theme.dart';

import 'screens/SignupView.dart'; 

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

      // SignUpView -> SignupView 로 대소문자 수정
      home: const SignupView(),
    );
  }
}
