import 'package:flutter/material.dart'; //MaterialApp, Scaffold, Text, AppBar 사용 가능
import 'package:flutter_dotenv/flutter_dotenv.dart'; // .env 읽기
import 'package:provider/provider.dart'; // MultiProvider, Provider 사용 가능

import 'core/network/movielog_client.dart';
import 'core/network/tmdb_client.dart';
import 'data/services/member_api_service.dart';
import 'data/services/tmdb_movie_service.dart';
import 'router/app_router.dart'; // 화면 주소록. 첫 화면과 화면 이동을 여기서 관리
import 'theme/app_theme.dart';

Future<void> main() async { // .env를 기다려야 해서 async
  WidgetsFlutterBinding.ensureInitialized(); // runApp 전에 파일 읽기 같은 Flutter 기능을 쓰려면 먼저 엔진 준비
  await dotenv.load(fileName: '.env'); // 다 읽을 때까지 기다림. 안 기다리면 Token이 빈 값이라 401
  runApp(const MovieLogApp()); //MovieLogApp 위젯이 트리의 루트가 됨
}

class MovieLogApp extends StatelessWidget {  //StatelessWidget을 상속받음. 한 번 그려지면 바뀌지 않음
  const MovieLogApp({super.key});

  @override // 부모 클래스의 메서드를 덮어쓴다는 표시
  Widget build(BuildContext context) {
    return MultiProvider( // 여러 화면이 같이 쓰는 객체를 앱 맨 위에 올려둠. 어느 Route에서든 찾을 수 있음
      providers: [
        Provider<TmdbMovieService>( // 상태가 없는 Service라 일반 Provider
          create: (_) => TmdbMovieService(createTmdbClient()), // Dio Client를 만들어 Service에 넣음. 앱 전체에서 하나만 씀
        ),
        Provider<MemberApiService>( // 자체 API용 Service. 회원가입과 마이 화면에서 꺼내 씀
          create: (_) => MemberApiService(createMovieLogClient()), // TMDB와 다른 Dio Client를 넣음
        ),
      ],
      child: MaterialApp.router( // MaterialApp 대신 사용. 첫 화면과 화면 이동을 GoRouter가 관리
        debugShowCheckedModeBanner: false, // 오른쪽 위에 빨간 DEBUG 띠 숨김
        title: 'MovieLog', // 앱을 식별하는 제목. 화면에 직접 보이진 않음
        theme: AppTheme.light, // 앱 전체에 적용할 ThemeData
        routerConfig: AppRouter.router, // 첫 화면은 AppRouter의 initialLocation이 정함
      ),
    );
  }
}