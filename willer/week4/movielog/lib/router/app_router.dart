import 'package:go_router/go_router.dart'; // GoRouter, GoRoute, StatefulShellRoute 사용 가능

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
      StatefulShellRoute.indexedStack( // 탭마다 Navigator를 따로 두고, 안 보이는 탭도 살려둠. 탭을 바꿔도 선택 장르와 스크롤이 유지됨
        builder: (context, state, navigationShell) { // child 대신 navigationShell을 받음. 탭 전부와 현재 탭 정보를 들고 있음
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [ // 탭 하나당 Branch 하나. 순서가 NavigationBar의 index 0, 1, 2
          StatefulShellBranch( // 홈 탭
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch( // 영화 탭
            routes: [
              GoRoute(
                path: '/movies',
                builder: (context, state) => const MovieListScreen(), // 선택 장르는 주소가 아니라 화면 State와 로컬 저장소가 기억
              ),
            ],
          ),
          StatefulShellBranch( // 마이 탭
            routes: [
              GoRoute(
                path: '/my',
                builder: (context, state) => const ProfileScreen(), // 마이페이지 Figma가 1주차 프로필 화면과 같은 구성이라 그대로 재사용
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/movies/:movieId', // :movieId는 빈칸. /movies/1처럼 실제 값이 채워져서 들어옴. Figma 상세에 하단바가 없어서 Shell 밖에 둠
        builder: (context, state) => MovieDetailScreen( // 주소마다 값이 달라서 const 불가
          movieId: state.pathParameters['movieId']!, // 빈칸 이름(:movieId)과 같은 키로 꺼냄. 이 Route에 들어왔으면 값이 항상 있어서 !로 null이 아님을 보장
        ),
      ),
    ],
  );
}