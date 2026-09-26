import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // context.go 사용 가능

class MainScreen extends StatelessWidget { // 탭 화면들을 담는 공통 액자. Scaffold와 NavigationBar를 한 번만 만들고 body만 바꿔 끼움
  const MainScreen({
    super.key,
    required this.currentIndex, // 필수. 지금 선택된 탭 번호. 주소에서 계산해서 받음
    required this.child, // 필수. ShellRoute가 넘겨준 현재 주소의 화면(홈, 영화 목록, 마이 중 하나)
  });

  final int currentIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child, // 탭마다 바뀌는 부분
      bottomNavigationBar: NavigationBar( // Material 3 하단 탭 바. 예전 BottomNavigationBar는 Material 2 버전
        selectedIndex: currentIndex, // 불이 켜질 탭. 주소 기준이라 화면과 항상 일치
        onDestinationSelected: (index) { // 탭을 눌렀을 때 실행. 누른 탭 번호가 index로 들어옴
          switch (index) { // index 값에 따라 갈 주소를 고름
            case 0:
              context.go('/home'); // 탭 이동은 위에 쌓는 게 아니라 위치를 바꾸는 거라 go. push면 누를 때마다 스택이 계속 쌓임
              break;
            case 1:
              context.go('/movies');
              break;
            case 2:
              context.go('/my');
              break;
          }
        },
        destinations: const [ // 탭 목록. 순서가 index 0, 1, 2
          NavigationDestination(
            icon: Icon(Icons.home_outlined), // 선택 안 됐을 때 아이콘
            selectedIcon: Icon(Icons.home), // 선택됐을 때 아이콘. 속이 채워진 버전
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie),
            label: '영화',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '마이',
          ),
        ],
      ),
    );
  }
}