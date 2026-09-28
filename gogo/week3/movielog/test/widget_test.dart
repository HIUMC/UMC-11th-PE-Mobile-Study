import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/main.dart';
import 'package:movielog/router/app_router.dart';
import 'package:movielog/widgets/movie_card.dart';
import 'package:movielog/widgets/movie_rating_input.dart';
import 'package:movielog/widgets/rating_dialog.dart';
import 'package:movielog/data/movie_store.dart';

void main() {
  testWidgets('시작 → 입력 검증 → 홈, 이전 화면으로 돌아가지 않는다', (tester) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    AppRouter.router.go('/start');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('MovieLog 시작하기'));
    await tester.pumpAndSettle();
    expect(AppRouter.router.canPop(), isFalse);
    expect(find.byType(BackButton), findsNothing);
    ElevatedButton submit() =>
        tester.widget(find.widgetWithText(ElevatedButton, '가입하기'));
    expect(submit().onPressed, isNull);
    await tester.enterText(find.byType(TextField).at(0), '고고');
    await tester.enterText(
      find.byType(TextField).at(1),
      'gogo@example.com trailing',
    );
    await tester.enterText(find.byType(TextField).at(2), 'demo12345');
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(submit().onPressed, isNull);
    await tester.enterText(find.byType(TextField).at(1), 'gogo@example.com');
    await tester.pumpAndSettle();
    expect(submit().onPressed, isNotNull);
    await tester.ensureVisible(find.text('가입하기'));
    await tester.tap(find.text('가입하기'));
    await tester.pumpAndSettle();
    expect(AppRouter.router.routeInformationProvider.value.uri.path, '/home');
    expect(AppRouter.router.canPop(), isFalse);
  });

  testWidgets('필터 적용/취소, 상세 왕복, 평점 초기화와 즐겨찾기', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    AppRouter.router.go('/movies');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('장르 필터'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'SF'));
    await tester.pump();
    expect(AppRouter.router.routeInformationProvider.value.uri.query, isEmpty);
    await tester.tap(find.text('1개 장르 적용 · 확인'));
    await tester.pumpAndSettle();
    expect(
      AppRouter
          .router
          .routeInformationProvider
          .value
          .uri
          .queryParameters['genre'],
      'SF',
    );
    expect(find.byType(MovieCard), findsOneWidget);
    await tester.tap(find.byTooltip('장르 필터'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, '드라마'));
    await tester.pump();
    Navigator.of(tester.element(find.text('장르 필터'))).pop();
    await tester.pumpAndSettle();
    expect(find.byType(MovieCard), findsOneWidget);
    await tester.tap(find.byType(MovieCard));
    await tester.pumpAndSettle();
    expect(find.text('평점 남기기'), findsOneWidget);
    await tester.tap(find.text('즐겨찾기'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    expect(find.text('즐겨찾기에 추가했어요.'), findsOneWidget);
    await tester.tap(find.text('평점 남기기'));
    await tester.pumpAndSettle();
    FilledButton save() =>
        tester.widget(find.widgetWithText(FilledButton, '확인'));
    expect(save().onPressed, isNull);
    tester
        .widget<MovieRatingInput>(find.byType(MovieRatingInput))
        .onChanged(4.5);
    await tester.pump();
    expect(find.text('4.5 / 5.0'), findsOneWidget);
    expect(save().onPressed, isNotNull);
    await tester.tap(find.text('평점 초기화 · 다시 선택하기'));
    await tester.pump();
    expect(save().onPressed, isNull);
    expect(
      tester.widget<MovieRatingInput>(find.byType(MovieRatingInput)).rating,
      0,
    );
    tester
        .widget<MovieRatingInput>(find.byType(MovieRatingInput))
        .onChanged(3.5);
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '확인'));
    await tester.pumpAndSettle();
    expect(MovieStore.instance.ratingFor(2), 3.5);
    expect(find.byType(RatingDialog), findsNothing);
    await tester.tap(find.byTooltip('뒤로 가기'));
    await tester.pumpAndSettle();
    expect(find.byType(MovieCard), findsOneWidget);
    await tester.tap(find.text('마이'));
    await tester.pumpAndSettle();
    expect(find.text('마이페이지'), findsOneWidget);
    await tester.tap(find.text('영화').last);
    await tester.pumpAndSettle();
    expect(find.byType(MovieCard), findsOneWidget);
    await tester.tap(find.byTooltip('장르 필터'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('초기화'));
    await tester.pump();
    await tester.tap(find.text('전체 영화 보기 · 확인'));
    await tester.pumpAndSettle();
    expect(AppRouter.router.routeInformationProvider.value.uri.query, isEmpty);
    expect(find.byType(MovieCard).evaluate().length, greaterThan(1));
    AppRouter.router.go('/movies/not-a-number');
    await tester.pumpAndSettle();
    expect(find.text('요청하신 영화 정보가 없습니다.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
