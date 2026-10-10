import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/movies.dart';
import 'package:movielog/movies_screen.dart';
import 'package:movielog/services/fake_movie_service.dart';
import 'package:movielog/services/movie_list_preference.dart';
import 'package:movielog/widgets/movie_list/movie_card.dart';
import 'package:movielog/widgets/movie_list/movie_list_empty.dart';
import 'package:movielog/widgets/movie_list/movie_list_error.dart';
import 'package:movielog/widgets/movie_list/movie_list_loading.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

const _delay = Duration(seconds: 1);
const _service = FakeMovieService(delay: _delay);

/// 첫 요청은 실패하고 이후 요청은 성공하는 Service.
class _FlakyMovieService extends FakeMovieService {
  _FlakyMovieService() : super(delay: _delay);

  int calls = 0;

  @override
  Future<List<Movie>> fetchMovies({
    MovieLoadMode mode = MovieLoadMode.success,
  }) {
    calls++;
    return super.fetchMovies(
      mode: calls == 1 ? MovieLoadMode.failure : MovieLoadMode.success,
    );
  }
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  FakeMovieService service = _service,
  MovieLoadMode mode = MovieLoadMode.success,
}) async {
  // 카드가 한 화면에 모두 들어오도록 넉넉한 크기로 렌더링합니다.
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: MoviesScreen(movieService: service, initialLoadMode: mode),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('Loading 후 Success 상태로 영화 Grid를 표시한다', (tester) async {
    await _pumpScreen(tester);

    expect(find.byType(MovieListLoading), findsOneWidget);
    expect(find.byType(MovieCard), findsNothing);

    await tester.pump(_delay);
    await tester.pumpAndSettle();

    expect(find.byType(MovieListLoading), findsNothing);
    expect(find.byType(MovieCard), findsNWidgets(movies.length));
  });

  testWidgets('빈 목록이면 Empty 상태를 표시한다', (tester) async {
    await _pumpScreen(tester, mode: MovieLoadMode.empty);
    await tester.pump(_delay);
    await tester.pumpAndSettle();

    expect(find.byType(MovieListEmpty), findsOneWidget);
    expect(find.byType(MovieCard), findsNothing);
  });

  testWidgets('실패하면 내부 오류 없이 Error 상태를 표시한다', (tester) async {
    await _pumpScreen(tester, mode: MovieLoadMode.failure);
    await tester.pump(_delay);
    await tester.pumpAndSettle();

    expect(find.byType(MovieListError), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
    expect(find.textContaining('Exception'), findsNothing);
  });

  testWidgets('Timeout이면 지연 안내 문구를 표시한다', (tester) async {
    await _pumpScreen(tester, mode: MovieLoadMode.slow);
    await tester.pump(_service.timeLimit);
    await tester.pumpAndSettle();

    expect(find.byType(MovieListError), findsOneWidget);
    expect(find.textContaining('너무 오래 걸리고'), findsOneWidget);

    // 타이머가 남지 않도록 지연된 원본 요청까지 흘려보냅니다.
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('다시 시도하면 새 요청을 보내 Loading부터 다시 시작한다', (tester) async {
    final service = _FlakyMovieService();
    await _pumpScreen(tester, service: service);
    await tester.pump(_delay);
    await tester.pumpAndSettle();
    expect(find.byType(MovieListError), findsOneWidget);

    await tester.tap(find.text('다시 시도'));
    await tester.pump();
    expect(find.byType(MovieListLoading), findsOneWidget);
    expect(service.calls, 2);

    await tester.pump(_delay);
    await tester.pumpAndSettle();
    expect(find.byType(MovieCard), findsNWidgets(movies.length));
  });

  testWidgets('장르 Chip을 누르면 목록이 갱신되고 선택값이 저장된다', (tester) async {
    await _pumpScreen(tester);
    await tester.pump(_delay);
    await tester.pumpAndSettle();

    await tester.tap(find.text('SF'));
    await tester.pumpAndSettle();

    expect(find.byType(MovieCard), findsOneWidget);
    expect(find.text('우주의 끝에서'), findsOneWidget);
    expect(await MovieListPreference().readGenre(), 'SF');
  });

  testWidgets('저장된 장르와 정렬 방식을 복원한다', (tester) async {
    final preference = MovieListPreference();
    await preference.saveGenre('애니메이션');
    await preference.saveSortOrder(MovieSortOrder.title);

    await _pumpScreen(tester);
    await tester.pump(_delay);
    await tester.pumpAndSettle();

    expect(find.byType(MovieCard), findsOneWidget);
    expect(find.text('기억의 숲'), findsOneWidget);
    expect(find.byTooltip('정렬: 제목순'), findsOneWidget);
  });

  testWidgets('당겨서 새로고침하면 새 요청을 보낸다', (tester) async {
    final service = _FlakyMovieService();
    await _pumpScreen(tester, service: service);
    await tester.pump(_delay);
    await tester.pumpAndSettle();
    expect(find.byType(MovieListError), findsOneWidget);

    // 새로고침 임계값(화면 높이 비례)을 넘도록 충분히 당깁니다.
    await tester.timedDrag(
      find.byType(MovieListError),
      const Offset(0, 1000),
      const Duration(milliseconds: 300),
    );
    await tester.pump(const Duration(milliseconds: 500)); // 인디케이터 고정 → onRefresh
    expect(service.calls, 2);

    await tester.pump(_delay);
    await tester.pumpAndSettle();
    expect(find.byType(MovieCard), findsNWidgets(movies.length));
  });
}
