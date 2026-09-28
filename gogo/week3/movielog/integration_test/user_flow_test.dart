import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movielog/main.dart' as app;
import 'package:movielog/router/app_router.dart';
import 'package:movielog/data/mock_movies.dart';
import 'package:movielog/widgets/movie_card.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('워크북 전체 흐름과 에뮬레이터 스크린샷', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    for (final movie in mockMovies) {
      await precacheImage(
        AssetImage(movie.posterAsset),
        tester.element(find.byType(MaterialApp)),
      );
    }
    await binding.convertFlutterSurfaceToImage();
    Future<void> capture(String name) async {
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await binding.takeScreenshot(name);
    }

    await capture('01-start');
    await tester.tap(find.text('MovieLog 시작하기'));
    await tester.pumpAndSettle();
    expect(AppRouter.router.canPop(), isFalse);
    await tester.enterText(find.byType(TextField).at(0), '고고');
    await tester.enterText(find.byType(TextField).at(1), 'gogo@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'demo12345');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('가입하기'));
    await capture('02-register');
    await tester.tap(find.text('가입하기'));
    await capture('03-home');
    expect(AppRouter.router.canPop(), isFalse);
    await tester.tap(find.text('영화').last);
    await capture('04-movies');
    await tester.tap(find.byTooltip('장르 필터'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, '드라마'));
    await tester.tap(find.widgetWithText(CheckboxListTile, 'SF'));
    await capture('05-filter');
    await tester.drag(find.text('장르 필터'), const Offset(0, -220));
    await capture('06-filter-expanded');
    await tester.tap(find.text('2개 장르 적용 · 확인'));
    await capture('07-filtered-movies');
    await tester.tap(find.byType(MovieCard).first);
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey("movie-detail-scroll")),
      const Offset(0, -430),
    );
    await capture('08-detail');
    await tester.tap(find.text('즐겨찾기'));
    await capture('09-favorite-added');
    await tester.tap(find.text('즐겨찾기 해제'));
    await capture('10-favorite-removed');
    await tester.tap(find.text('평점 남기기'));
    await capture('11-rating-empty');
    await tester.tap(find.byIcon(Icons.star_rounded).last);
    await capture('12-rating-selected');
    await tester.tap(find.text('평점 초기화 · 다시 선택하기'));
    await capture('13-rating-reset');
    await tester.tap(find.byIcon(Icons.star_rounded).last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '확인'));
    await capture('14-rating-saved');
    await tester.tap(find.text('즐겨찾기'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('뒤로 가기'));
    await capture('15-return-to-list');
    await tester.tap(find.text('마이'));
    await capture('16-my-page');
    await tester.tap(find.text('영화').last);
    await tester.pumpAndSettle();
    expect(
      AppRouter
          .router
          .routeInformationProvider
          .value
          .uri
          .queryParameters['genre'],
      '드라마,SF',
    );
    await tester.tap(find.text('홈'));
    await capture('17-final-home');
    expect(tester.takeException(), isNull);
  });
}
