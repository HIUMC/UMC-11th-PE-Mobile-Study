import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/screens/movie_list_screen.dart';
import 'package:movielog/services/fake_movie_service.dart';
import 'package:movielog/services/movie_preferences.dart';
import 'package:movielog/widgets/movie_states.dart';
import 'package:movielog/widgets/movie_grid.dart';

// [학습 · 테스트 대역] 디스크 대신 메모리에 기록해 저장·복원 흐름을 빠르게 검증.
// 실제 기기 저장소 동작은 integration_test에서 확인.
class MemoryPreferences extends MoviePreferences {
  String genre = '전체', sort = '기본순';
  @override
  Future<String> readGenre() async => genre;
  @override
  Future<String> readSort() async => sort;
  @override
  Future<void> saveGenre(String value) async {
    genre = value;
  }

  @override
  Future<void> saveSort(String value) async {
    sort = value;
  }
}

class CountingService extends FakeMovieService {
  int calls = 0;
  @override
  Future<List<Never>> fetchMovies({
    MovieResponse mode = MovieResponse.success,
  }) async {
    calls++;
    return [];
  }
}

void main() {
  test('mock service success, empty, failure', () async {
    const service = FakeMovieService(delay: Duration.zero);
    expect(await service.fetchMovies(), isNotEmpty);
    expect(await service.fetchMovies(mode: MovieResponse.empty), isEmpty);
    await expectLater(
      service.fetchMovies(mode: MovieResponse.failure),
      throwsStateError,
    );
  });

  testWidgets('loading → success, empty, error → retry, timeout', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: MovieListScreen(preferences: MemoryPreferences())),
    );
    expect(find.byType(MovieLoading), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.byType(MovieGrid), findsOneWidget);
    Future<void> mode(String text) async {
      await tester.tap(find.byTooltip('실습 상태'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(text));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    await mode('빈 결과');
    expect(find.byType(MovieEmpty), findsOneWidget);
    await mode('오류 (1회)');
    expect(find.byType(MovieError), findsOneWidget);
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.byType(MovieGrid), findsOneWidget);
    await mode('시간 초과 (1회)');
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(find.text('응답이 늦어지고 있어요'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('genre saves, restores and does not refetch', (tester) async {
    final preferences = MemoryPreferences();
    final service = CountingService();
    await tester.pumpWidget(
      MaterialApp(
        home: MovieListScreen(preferences: preferences, service: service),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('SF'));
    await tester.pumpAndSettle();
    expect(preferences.genre, 'SF');
    expect(service.calls, 1);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      MaterialApp(
        home: MovieListScreen(preferences: preferences, service: service),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'SF')).selected,
      isTrue,
    );
  });
}
