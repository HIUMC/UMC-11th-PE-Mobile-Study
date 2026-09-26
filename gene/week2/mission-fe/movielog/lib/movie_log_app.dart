import 'package:flutter/material.dart';
import 'package:movielog/signup_screen.dart';

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const SignupScreen(), // 첫 실행 화면 지정
    );
  }
}

