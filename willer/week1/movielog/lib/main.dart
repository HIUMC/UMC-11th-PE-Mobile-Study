import 'package:flutter/material.dart'; //MaterialApp, Scaffold, Text, AppBar 사용 가능

import 'profile_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MovieLogApp()); //MovieLogApp 위젯이 트리의 루트가 됨
}

class MovieLogApp extends StatelessWidget {  //StatelessWidget을 상속받음. 한 번 그려지면 바뀌지 않음
  const MovieLogApp({super.key});  // {}로 감싸서 Named Parameter. super.key는 부모 클래스(StatelessWidget)의 key를 상속받음

  @override // 부모 클래스의 메서드를 덮어쓴다는 표시
  Widget build(BuildContext context) { // BuildContext context는 이 위젯이 트리의 어디에 있는지를 담은 객체
    return MaterialApp( // Material Design 앱의 최상위 위젯, 라우팅, 테마, 로케일 같은 앱 전역 설정을 담당. 앱에 하나만 존재
      debugShowCheckedModeBanner: false, // 오른쪽 위에 빨간 DEBUG 띠 숨김
      title: 'MovieLog', // 앱을 식별하는 제목. 화면에 직접 보이진 않음
      theme: AppTheme.light, // 앱 전체에 적용할 ThemeData. 여기 연결하면 하위 모든 화면이 이 설정을 따름
      home: const ProfileScreen(), // 앱을 실행했을 때 처음 보여줄 화면
    );
  }
}