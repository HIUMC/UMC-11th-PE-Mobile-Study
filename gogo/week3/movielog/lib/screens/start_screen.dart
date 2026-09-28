import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 24, 26, 22),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'MovieLog',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 126,
                height: 126,
                decoration: const BoxDecoration(
                  color: AppColors.primaryTint,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/logos/movielog_logo.svg',
                  width: 76,
                  height: 76,
                  semanticsLabel: 'MovieLog 로고',
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '영화의 순간을\n기록하세요',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: AppColors.textSecondary, height: 1.55),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () => context.pushReplacement('/register'),
                  child: const Text('MovieLog 시작하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
