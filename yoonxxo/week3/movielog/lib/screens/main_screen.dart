import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

// 홈, 영화, 마이 화면에서 공통으로 사용하는 화면
//
// 각 화면마다 NavigationBar를 따로 만들지 않고
// MainScreen에서 한 번만 관리함.
class MainScreen extends StatelessWidget {
  const MainScreen({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  // 현재 선택된 NavigationBar의 위치
  final int currentIndex;

  // 현재 Route에 해당하는 실제 화면
  //
  // HomeScreen, MovieListScreen, MyPageScreen 중
  // 하나가 child로 들어옴.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 현재 선택된 탭의 화면을 표시
      body: child,

      // ---------------------------
      // 공통 NavigationBar
      // ---------------------------
      bottomNavigationBar: NavigationBar(
        // 현재 Route에 맞는 탭을 선택 상태로 표시
        selectedIndex: currentIndex,

        // Figma의 하단바와 비슷하게
        // 너무 높지 않도록 설정
        height: 64,

        indicatorColor: AppColors.lightViolet,

        // 사용자가 탭을 눌렀을 때
        // 해당 Route로 이동함.
        onDestinationSelected: (index) {
          switch (index) {
            // 홈
            case 0:
              context.go('/home');
              break;

            // 영화
            case 1:
              context.go('/movies');
              break;

            // 마이
            case 2:
              context.go('/my');
              break;
          }
        },

        destinations: const [
          // 홈 탭
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.violet),
            label: '홈',
          ),

          // 영화 탭
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie, color: AppColors.violet),
            label: '영화',
          ),

          // 마이 탭
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.violet),
            label: '마이',
          ),
        ],
      ),
    );
  }
}
