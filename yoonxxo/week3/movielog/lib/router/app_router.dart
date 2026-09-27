import 'package:go_router/go_router.dart';

import '../screens/start_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/home_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/my_page_screen.dart';
import '../screens/main_screen.dart';
import '../screens/movie_detail_screen.dart';

class AppRouter {
  // AppRouter 객체를 따로 만들지 못하도록 함
  AppRouter._();

  // 앱 전체에서 하나의 Router 사용
  static final router = GoRouter(
    // 앱을 실행하면 가장 먼저 /start로 이동
    initialLocation: '/start',

    routes: [
      // ---------------------------
      // 시작 화면
      // ---------------------------
      //
      // 시작 화면에서는 하단 NavigationBar가 필요하지 않기 때문에
      // ShellRoute 밖에 선언함.
      GoRoute(path: '/start', builder: (context, state) => const StartScreen()),

      // ---------------------------
      // 회원가입 화면
      // ---------------------------
      //
      // 회원가입 화면 역시
      // NavigationBar가 필요하지 않기 때문에
      // ShellRoute 밖에 선언함.
      GoRoute(
        path: '/register',
        builder: (context, state) => const SignUpScreen(),
      ),

      // ---------------------------
      // 영화 상세 화면
      // ---------------------------
      //
      // 상세 화면에는 홈/영화/마이 NavigationBar를
      // 표시하지 않기 때문에 ShellRoute 밖에 선언함.
      //
      // 영화 ID는 Path Parameter로 전달받음.
      //
      // 예:
      // /movies/1
      // /movies/2
      GoRoute(
        path: '/movies/:movieId',

        builder: (context, state) {
          // URL의 :movieId 부분 읽기
          final movieId = int.tryParse(state.pathParameters['movieId'] ?? '');

          return MovieDetailScreen(
            // 잘못된 값이 들어오면 -1을 전달하고
            // 상세 화면에서 영화 없음 처리
            movieId: movieId ?? -1,
          );
        },
      ),

      // ---------------------------
      // 홈 / 영화 / 마이 공통 영역
      // ---------------------------
      //
      // ShellRoute 안의 화면들은
      // MainScreen의 NavigationBar를 공통으로 사용함.
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(
            // 현재 URL을 이용해서
            // 어떤 NavigationBar 항목을 선택할지 결정
            currentIndex: _indexFromLocation(state.uri.path),

            // 현재 Route 화면을 MainScreen body에 전달
            child: child,
          );
        },

        routes: [
          // 홈 화면
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),

          // 영화 목록 화면
          GoRoute(
            path: '/movies',
            builder: (context, state) => const MovieListScreen(),
          ),

          // 마이페이지
          GoRoute(
            path: '/my',
            builder: (context, state) => const MyPageScreen(),
          ),
        ],
      ),
    ],
  );

  // ---------------------------
  // 현재 Route에 맞는 탭 번호 계산
  // ---------------------------
  //
  // NavigationBar는
  //
  // 0 = 홈
  // 1 = 영화
  // 2 = 마이
  //
  // 순서로 구성되어 있음.
  static int _indexFromLocation(String path) {
    // /movies 또는
    // 나중에 만들 /movies/1 같은 상세 주소라면
    // 영화 탭에 해당함.
    if (path.startsWith('/movies')) {
      return 1;
    }

    // /my로 시작하면 마이 탭
    if (path.startsWith('/my')) {
      return 2;
    }

    // 그 외에는 홈 탭
    return 0;
  }
}
