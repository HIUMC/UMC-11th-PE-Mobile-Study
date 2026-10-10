import 'package:flutter/material.dart'; //MaterialApp, Scaffold, Text, AppBar 사용 가능

import 'router/app_router.dart'; // 화면 주소록. 첫 화면과 화면 이동을 여기서 관리
import 'theme/app_theme.dart';

void main() {
  runApp(const MovieLogApp()); //MovieLogApp 위젯이 트리의 루트가 됨
}

class MovieLogApp extends StatelessWidget {  //StatelessWidget을 상속받음. 한 번 그려지면 바뀌지 않음
  const MovieLogApp({super.key});  // {}로 감싸서 Named Parameter. super.key는 부모 클래스(StatelessWidget)의 key를 상속받음

  @override // 부모 클래스의 메서드를 덮어쓴다는 표시
  Widget build(BuildContext context) { // BuildContext context는 이 위젯이 트리의 어디에 있는지를 담은 객체
    return MaterialApp.router( // MaterialApp 대신 사용. 첫 화면과 화면 이동을 GoRouter가 관리. MaterialApp과 같이 쓰지 않고 최상위에 하나만 둠
      debugShowCheckedModeBanner: false, // 오른쪽 위에 빨간 DEBUG 띠 숨김
      title: 'MovieLog', // 앱을 식별하는 제목. 화면에 직접 보이진 않음
      theme: AppTheme.light, // 앱 전체에 적용할 ThemeData. 라우터를 바꿔도 테마 연결은 그대로
      routerConfig: AppRouter.router, // 기존 home 자리. 첫 화면은 AppRouter의 initialLocation이 정함
    );
  }
}