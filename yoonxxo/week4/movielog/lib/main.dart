import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      //화면 이동과 시작 화면을 GoRouter에게 맡김
      routerConfig: AppRouter.router,
    );
  }
}
