import 'package:go_router/go_router.dart'; // GoRouter, GoRoute, ShellRoute 사용 가능

import '../home_screen.dart'; // router 폴더 안이라 ../로 lib까지 한 칸 올라가서 찾음
import '../main_screen.dart';
import '../movie_detail_screen.dart';
import '../movie_list_screen.dart';
import '../profile_screen.dart';
import '../signup_screen.dart';
import '../start_screen.dart';

class AppRouter { // 앱의 주소록. 어떤 주소일 때 어떤 화면을 보여줄지 한곳에 모아둠. 화면이 늘면 여기 routes에 추가
  AppRouter._(); // private 생성자. 외부에서 AppRouter()로 객체 못 만들게 막음. 라우터를 담는 상자일 뿐이라 객체가 필요 없음

  static final router = GoRouter( // static이라 AppRouter.router로 바로 접근. 실행 중 현재 위치가 계속 바뀌는 객체라 const 불가. build 안에서 만들면 다시 그릴 때마다 위치가 초기화됨
    initialLocation: '/start', // 앱을 켰을 때 처음 갈 주소. MaterialApp의 home 역할. 시작 → 회원가입 → 홈 흐름의 출발점
    routes: [ // 사용할 Route 목록
      GoRoute(
        path: '/start', // 주소 패턴
        builder: (context, state) => const StartScreen(), // 이 주소일 때 그릴 화면. state에는 현재 주소 정보(파라미터 등)가 들어 있음
      ),
      GoRoute(
        path: '/register', // 경로 이름은 워크북대로, 화면은 SignUpScreen 사용
        builder: (context, state) => const SignUpScreen(),
      ),
      ShellRoute( // 안쪽 routes들을 공통 액자(MainScreen)로 감쌈. 탭을 바꿔도 NavigationBar는 그대로고 child만 바뀜
        builder: (context, state, child) { // GoRoute와 달리 child를 하나 더 받음. 현재 주소에 해당하는 안쪽 화면
          return MainScreen(
            currentIndex: indexFromLocation(state.uri.path), // 현재 주소로 선택된 탭 번호를 계산
            child: child,
          );
        },
        routes: [ // 이 주소들은 액자 안에 그려짐. 하단바가 보임
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/movies',
            builder: (context, state) => const MovieListScreen(),
          ),
          GoRoute(
            path: '/my',
            builder: (context, state) => const ProfileScreen(), // 마이페이지 Figma가 1주차 프로필 화면과 같은 구성이라 그대로 재사용
          ),
        ],
      ),
      GoRoute(
        path: '/movies/:movieId', // :movieId는 빈칸. /movies/1처럼 실제 값이 채워져서 들어옴. Figma 상세에 하단바가 없어서 ShellRoute 밖에 둠
        builder: (context, state) => MovieDetailScreen( // 주소마다 값이 달라서 const 불가
          movieId: state.pathParameters['movieId']!, // 빈칸 이름(:movieId)과 같은 키로 꺼냄. 이 Route에 들어왔으면 값이 항상 있어서 !로 null이 아님을 보장
        ),
      ),
    ],
  );

  static int indexFromLocation(String path) { // 주소를 보고 몇 번째 탭인지 계산. 탭 바를 안 누르고 이동해도(전체보기 등) 불이 맞게 켜짐
    if (path.startsWith('/movies')) return 1; // ==가 아니라 startsWith. /movies로 시작하면 영화 탭
    if (path.startsWith('/my')) return 2;

    return 0; // 나머지는 홈 탭
  }
}