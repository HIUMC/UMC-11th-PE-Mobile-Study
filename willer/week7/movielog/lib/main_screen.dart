import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // StatefulNavigationShell 사용 가능

class MainScreen extends StatelessWidget { // 탭 화면들을 담는 공통 액자. Scaffold와 NavigationBar를 한 번만 만듦
  const MainScreen({super.key, required this.navigationShell}); // 필수. StatefulShellRoute가 넘겨주는 탭 묶음

  final StatefulNavigationShell navigationShell; // 탭(Branch)들을 전부 들고 있는 위젯. 현재 탭 번호와 탭 이동 기능도 가짐

  void _onDestinationSelected(int index) { // 탭을 눌렀을 때 실행. 앞의 _는 이 파일 밖에서 접근 불가
    navigationShell.goBranch( // go 대신 goBranch. 주소가 아니라 몇 번째 탭인지로 이동. 그 탭이 마지막으로 있던 위치로 돌아감
      index,
      initialLocation: index == navigationShell.currentIndex, // 지금 보고 있는 탭을 한 번 더 누르면 그 탭의 처음 위치로 초기화. 다른 탭이면 마지막 위치 유지
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell, // 탭마다 따로 살아 있는 화면들. 선택된 탭만 보이고 나머지는 숨겨진 채로 상태 유지
      bottomNavigationBar: NavigationBar( // Material 3 하단 탭 바. 예전 BottomNavigationBar는 Material 2 버전
        selectedIndex: navigationShell.currentIndex, // 불이 켜질 탭. 주소를 직접 계산하지 않아도 navigationShell이 알고 있음
        onDestinationSelected: _onDestinationSelected, // 괄호 없이 함수 자체를 넘김
        destinations: const [ // 탭 목록. 순서가 index 0, 1, 2이고 router의 branches 순서와 같아야 함
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