import 'package:flutter/material.dart';

import 'profile_screen.dart';
import 'theme/app_theme.dart';

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
      theme: AppTheme.light,
      home: const ProfileScreen(),
    );
  }
}