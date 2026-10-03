import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movielog/main.dart' as app;
import 'package:movielog/router/app_router.dart';
import 'package:movielog/services/movie_preferences.dart';
import 'package:movielog/data/mock_movies.dart';
import 'package:movielog/widgets/movie_states.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Week 4 states and persisted preferences', (tester) async {
    final preferences = MoviePreferences();
    await preferences.saveGenre('전체');
    await preferences.saveSort('기본순');
    app.main();
    await tester.pumpAndSettle();
    for (final movie in mockMovies) {
      await precacheImage(
        AssetImage(movie.posterAsset),
        tester.element(find.byType(MaterialApp)),
      );
    }
    await binding.convertFlutterSurfaceToImage();
    AppRouter.router.go('/movies');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(MovieLoading), findsOneWidget);
    await binding.takeScreenshot('01-loading');
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await binding.takeScreenshot('02-success');
    Future<void> mode(String text) async {
      await tester.tap(find.byTooltip('실습 상태'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(text));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    await mode('빈 결과');
    expect(find.byType(MovieEmpty), findsOneWidget);
    await binding.takeScreenshot('03-empty');
    await mode('오류 (1회)');
    expect(find.byType(MovieError), findsOneWidget);
    await binding.takeScreenshot('04-error');
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await binding.takeScreenshot('05-retry-success');
    await tester.tap(find.text('SF'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('평점순').last);
    await tester.pumpAndSettle();
    expect(await MoviePreferences().readGenre(), 'SF');
    expect(await MoviePreferences().readSort(), '평점순');
    // 화면을 완전히 제거하고 다시 생성하여 디스크에 저장된 설정을 복원함.
    AppRouter.router.go('/start');
    await tester.pumpAndSettle();
    AppRouter.router.go('/movies');
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(
      tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'SF')).selected,
      isTrue,
    );
    expect(find.text('평점순'), findsOneWidget);
    await binding.takeScreenshot('06-restored');
  });
}
