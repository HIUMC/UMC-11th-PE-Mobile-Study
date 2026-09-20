import 'package:flutter/material.dart';

import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';
import 'screens/sign_up_screen.dart';
import 'screens/rating_screen.dart';

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
      home: const SignUpScreen(),
    );
  }
}
