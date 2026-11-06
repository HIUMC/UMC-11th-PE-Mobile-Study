import 'package:flutter/material.dart'; // GlobalKey, NavigatorState 사용 가능
import 'package:go_router/go_router.dart'; // GoRouter, GoRoute, StatefulShellRoute 사용 가능
import 'package:provider/provider.dart'; // ChangeNotifierProvider, context.read 사용 가능

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/member_check_service.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import '../home_screen.dart'; // router 폴더 안이라 ../로 lib까지 한 칸 올라가서 찾음
import '../main_screen.dart';
import '../movie_detail_screen.dart';
import '../movie_list_screen.dart';
import '../my_ratings_screen.dart';
import '../profile_screen.dart';
import '../signup_screen.dart';
import '../start_screen.dart';
import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';
import '../view_models/my_ratings_view_model.dart';
import '../view_models/signup_view_model.dart';

class AppRouter { // 앱의 주소록. 어떤 주소일 때 어떤 화면을 보여줄지 한곳에 모아둠. 화면이 늘면 여기 routes에 추가
  AppRouter._(); // private 생성자. 외부에서 AppRouter()로 객체 못 만들게 막음. 라우터를 담는 상자일 뿐이라 객체가 필요 없음

  static final rootNavigatorKey = GlobalKey<NavigatorState>(); // 앱 전체 Navigator를 가리키는 키. 한 번만 만듦

  static final router = GoRouter( // static이라 AppRouter.router로 바로 접근. 실행 중 현재 위치가 계속 바뀌는 객체라 const 불가. build 안에서 만들면 다시 그릴 때마다 위치가 초기화됨
    initialLocation: '/start', // 앱을 켰을 때 처음 갈 주소. 시작 → 회원가입 → 홈 흐름의 출발점
    navigatorKey: rootNavigatorKey, // GoRouter가 쓸 root Navigator로 등록
    routes: [ // 사용할 Route 목록
      GoRoute(
        path: '/start', // 주소 패턴
        builder: (context, state) => const StartScreen(), // 이 주소일 때 그릴 화면. state에는 현재 주소 정보(파라미터 등)가 들어 있음
      ),
      GoRoute(
        path: '/register', // 경로 이름은 /register, 화면은 SignUpScreen 사용
        builder: (context, state) => ChangeNotifierProvider<SignUpViewModel>( // 회원가입 화면 전용 ViewModel. 화면이 사라지면 dispose까지 해줌
          create: (context) => SignUpViewModel(
            context.read<MemberCheckService>(), // 앱 맨 위에 올려둔 공용 Service를 꺼냄
          ),
          child: const SignUpScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack( // 탭마다 Navigator를 따로 두고, 안 보이는 탭도 살려둠. 탭을 바꿔도 화면과 ViewModel이 유지됨
        builder: (context, state, navigationShell) { // child 대신 navigationShell을 받음. 탭 전부와 현재 탭 정보를 들고 있음
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [ // 탭 하나당 Branch 하나. 순서가 NavigationBar의 index 0, 1, 2
          StatefulShellBranch( // 홈 탭
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => ChangeNotifierProvider<MovieHomeViewModel>( // 홈 화면 전용 ViewModel을 만들어 아래로 내려줌. 화면이 사라지면 dispose까지 해줌
                  create: (context) => MovieHomeViewModel(
                    context.read<TmdbMovieService>(), // 앱 맨 위 MultiProvider에 올려둔 공용 Service를 꺼냄
                  )..loadPopular(), // ..는 loadPopular를 부르고 ViewModel 자신을 돌려줌. create는 한 번만 실행돼서 요청도 한 번
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch( // 영화 탭
            routes: [
              GoRoute(
                path: '/movies',
                builder: (context, state) => ChangeNotifierProvider<MovieListViewModel>( // 영화 목록 전용 ViewModel. 홈과 따로 만들어서 상태가 섞이지 않음
                  create: (context) => MovieListViewModel(
                    context.read<TmdbMovieService>(), // 홈과 같은 공용 Service를 씀
                  )..loadInitial(), // 장르 목록과 전체 영화 30개를 처음 한 번 불러옴
                  child: const MovieListScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch( // 마이 탭
            routes: [
              GoRoute(
                path: '/my',
                builder: (context, state) => const ProfileScreen(), // 마이페이지 Figma가 프로필 화면과 같은 구성이라 그대로 재사용
                routes: [ // /my 아래 자식 화면
                  GoRoute(
                    path: 'ratings', // 앞에 /가 없어서 부모 경로에 붙음. 최종 경로는 /my/ratings
                    parentNavigatorKey: rootNavigatorKey, // 탭 Navigator가 아니라 root Navigator 위에 띄워서 하단 탭을 가림
                    builder: (context, state) => ChangeNotifierProvider<MyRatingsViewModel>( // 평점 화면 전용 ViewModel
                      create: (context) => MyRatingsViewModel(
                        context.read<RatingApiService>(),
                        context.read<TmdbMovieService>(), // 평점의 movieId로 영화 정보를 가져올 때 씀
                        sampleMemberId,
                      )..load(),
                      child: const MyRatingsScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/movies/:movieId', // :movieId는 빈칸. /movies/1처럼 실제 값이 채워져서 들어옴. Figma 상세에 하단바가 없어서 Shell 밖에 둠
        builder: (context, state) => MovieDetailScreen( // 주소마다 값이 달라서 const 불가
          movie: state.extra as TmdbMovieDto?, // push할 때 extra로 넘긴 영화. extra 없이 주소로만 들어오면 null
        ),
      ),
    ],
  );
}