import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/data/services/week6_services.dart';
import 'package:movielog/view_models/sign_up_view_model.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';
import 'package:movielog/screens/register_screen.dart';
import 'package:movielog/screens/my_ratings_screen.dart';
import 'package:movielog/widgets/movielog_button.dart';
import 'package:movielog/theme/app_theme.dart';
import 'package:movielog/router/app_router.dart';

DioException failure([int? code]) => DioException(
  requestOptions: RequestOptions(),
  response: code == null
      ? null
      : Response(requestOptions: RequestOptions(), statusCode: code),
);

class Checks extends MemberCheckService {
  Checks() : super(Dio());
  final pending = <Completer<bool>>[];
  @override
  Future<bool> checkNickname(String value) {
    final c = Completer<bool>();
    pending.add(c);
    return c.future;
  }

  @override
  Future<bool> checkEmail(String value) => checkNickname(value);
}

class Ratings extends RatingApiService {
  Ratings() : super(Dio());
  List<RatingDto> data = [];
  Object? error;
  Completer<List<RatingDto>>? pending;
  int? requested;
  @override
  Future<List<RatingDto>> fetchMyRatings(int id) async {
    requested = id;
    if (pending != null) return pending!.future;
    if (error != null) throw error!;
    return data;
  }
}

class Movies extends TmdbMovieService {
  Movies() : super(Dio());
  int calls = 0;
  bool fail = false;
  bool missing = false;
  @override
  Future<MovieInfo?> findMovieById(int id) async {
    calls++;
    if (fail) throw failure();
    return missing ? null : const MovieInfo(title: '테스트 영화');
  }
}

RatingDto rating(int id, {String? comment}) => RatingDto(
  ratingId: id,
  movieId: 550,
  score: 5,
  comment: comment,
  createdAt: DateTime(2026, 11, 1),
);

void main() {
  test('v5 service parses bare bodies and encodes path segments', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('nickname')) {
            expect(
              options.path,
              '/v5/members/nickname/${Uri.encodeComponent('고고/a')}',
            );
            handler.resolve(
              Response(requestOptions: options, data: {'available': false}),
            );
          } else {
            handler.resolve(
              Response(
                requestOptions: options,
                data: [
                  {
                    'ratingId': 1,
                    'movieId': 550,
                    'score': 5,
                    'comment': null,
                    'createdAt': '2026-11-01T00:00:00Z',
                  },
                ],
              ),
            );
          }
        },
      ),
    );
    expect(await MemberCheckService(dio).checkNickname(' 고고/a '), isFalse);
    expect(
      (await RatingApiService(dio).fetchMyRatings(1)).single.comment,
      isNull,
    );
  });
  test(
    'independent checks, input invalidation, stale A-B-A and dispose',
    () async {
      final service = Checks();
      final vm = SignUpViewModel(service);
      vm.changed(CheckField.nickname, '고고');
      final old = vm.check(CheckField.nickname);
      expect(vm.nickname.status, CheckStatus.checking);
      vm.changed(CheckField.nickname, '새이름');
      vm.changed(CheckField.nickname, '고고');
      service.pending[0].complete(false);
      await old;
      expect(vm.nickname.status, CheckStatus.idle);
      final next = vm.check(CheckField.nickname);
      service.pending[1].complete(true);
      await next;
      expect(vm.nickname.status, CheckStatus.available);
      vm.changed(CheckField.email, 'a@example.com');
      final email = vm.check(CheckField.email);
      service.pending[2].complete(false);
      await email;
      expect(vm.email.status, CheckStatus.duplicated);
      expect(vm.nickname.status, CheckStatus.available);
      vm.changed(CheckField.email, 'b@example.com');
      final retry = vm.check(CheckField.email);
      service.pending[3].completeError(failure());
      await retry;
      expect(vm.email.status, CheckStatus.error);
      expect(vm.email.errorText, contains('실패'));
      final disposed = vm.check(CheckField.email);
      vm.dispose();
      service.pending[4].complete(true);
      await disposed;
    },
  );
  test(
    'ratings member 1, empty/error, partial failure, caching and retry',
    () async {
      final source = Ratings();
      final movies = Movies();
      final vm = MyRatingsViewModel(source, movies);
      await vm.load();
      expect(source.requested, 1);
      expect(vm.status, MyRatingsLoadStatus.empty);
      source.error = failure(404);
      await vm.load();
      expect(vm.status, MyRatingsLoadStatus.error);
      expect(vm.message, contains('존재하지'));
      source.error = null;
      source.data = [rating(1), rating(2)];
      movies.fail = true;
      await vm.load();
      expect(vm.status, MyRatingsLoadStatus.success);
      expect(vm.ratings.length, 2);
      expect(movies.calls, 1);
      movies.fail = false;
      await vm.load();
      expect(movies.calls, 2);
      expect(vm.ratings.first.movie?.title, '테스트 영화');
      await vm.load();
      expect(movies.calls, 2);
      vm.dispose();
    },
  );
  test('newer ratings request wins and dispose ignores pending load', () async {
    final source = Ratings();
    final vm = MyRatingsViewModel(source, Movies());
    final old = Completer<List<RatingDto>>();
    source.pending = old;
    final first = vm.load();
    source.pending = null;
    await vm.load();
    old.complete([rating(1)]);
    await first;
    expect(vm.status, MyRatingsLoadStatus.empty);
    final later = Completer<List<RatingDto>>();
    source.pending = later;
    final request = vm.load();
    vm.dispose();
    later.complete([rating(1)]);
    await request;
  });
  testWidgets('form shows loading, duplicate, reset and network error', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final checks = Checks();
    final vm = SignUpViewModel(checks);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: vm,
        child: MaterialApp(theme: AppTheme.light, home: const RegisterScreen()),
      ),
    );
    await tester.enterText(find.byKey(const ValueKey('nickname')), '고고');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('nickname-check')));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    checks.pending[0].complete(false);
    await tester.pumpAndSettle();
    expect(find.text('이미 사용 중인 닉네임입니다.'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('nickname')), '다른닉네임');
    await tester.pump();
    expect(find.text('이미 사용 중인 닉네임입니다.'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('nickname-check')));
    checks.pending[1].completeError(failure());
    await tester.pumpAndSettle();
    expect(find.text('중복 확인에 실패했습니다. 다시 시도해 주세요.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('button widths and loading disables clicks', (tester) async {
    int presses = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MovieLogButton(
                  key: const ValueKey('natural'),
                  label: '확인',
                  onPressed: () => presses++,
                ),
                MovieLogButton(
                  key: const ValueKey('full'),
                  label: '전체',
                  width: double.infinity,
                  onPressed: () {},
                ),
                MovieLogButton(
                  key: const ValueKey('fixed'),
                  label: '고정',
                  width: 140,
                  isLoading: true,
                  onPressed: () => presses++,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byKey(const ValueKey('full'))).width, 360);
    expect(tester.getSize(find.byKey(const ValueKey('fixed'))).width, 140);
    expect(
      tester.getSize(find.byKey(const ValueKey('natural'))).width,
      lessThan(140),
    );
    await tester.tap(find.byKey(const ValueKey('fixed')));
    expect(presses, 0);
    await tester.tap(find.byKey(const ValueKey('natural')));
    expect(presses, 1);
  });
  testWidgets('ratings UI loading, empty, error, success and null comment', (
    tester,
  ) async {
    final source = Ratings();
    final vm = MyRatingsViewModel(source, Movies());
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: vm,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MyRatingsScreen(),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await vm.load();
    await tester.pumpAndSettle();
    expect(find.text('등록된 평점이 없습니다.'), findsOneWidget);
    source.error = failure(400);
    await vm.load();
    await tester.pumpAndSettle();
    expect(find.text('memberId 형식을 다시 확인해 주세요.'), findsOneWidget);
    source.error = null;
    source.data = [rating(1)];
    await vm.load();
    await tester.pumpAndSettle();
    expect(find.text('테스트 영화'), findsOneWidget);
    expect(find.text('null'), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('ratings pushes on root navigator and back restores tabs', (
    tester,
  ) async {
    final source = Ratings();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<RatingApiService>.value(value: source),
          Provider<TmdbMovieService>.value(value: Movies()),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: AppRouter.router,
        ),
      ),
    );
    AppRouter.router.go('/my');
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(find.text('내가 등록한 평점'));
    await tester.pumpAndSettle();
    expect(find.byType(MyRatingsScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(MyRatingsScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
