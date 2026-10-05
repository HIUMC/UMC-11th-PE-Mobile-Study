import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/movies.dart';
import 'package:movielog/services/movie_list_preference.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late MovieListPreference preference;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    preference = MovieListPreference();
  });

  test('저장된 값이 없으면 기본값(전체, 최신순)을 반환한다', () async {
    expect(await preference.readGenre(), '전체');
    expect(await preference.readSortOrder(), MovieSortOrder.latest);
  });

  test('장르와 정렬 방식을 저장하고 다시 읽는다', () async {
    await preference.saveGenre('SF');
    await preference.saveSortOrder(MovieSortOrder.rating);

    // 앱 재실행처럼 새 인스턴스로 읽어도 값이 유지된다.
    final reopened = MovieListPreference();
    expect(await reopened.readGenre(), 'SF');
    expect(await reopened.readSortOrder(), MovieSortOrder.rating);
  });

  test('clear 후에는 기본값으로 돌아간다', () async {
    await preference.saveGenre('SF');
    await preference.saveSortOrder(MovieSortOrder.title);
    await preference.clear();

    expect(await preference.readGenre(), '전체');
    expect(await preference.readSortOrder(), MovieSortOrder.latest);
  });

  group('MovieSortOrder.apply', () {
    test('최신순은 개봉 연도 내림차순이다', () {
      final years = MovieSortOrder.latest.apply(movies).map((m) => m.year);
      expect(years, orderedEquals([...years]..sort((a, b) => b - a)));
    });

    test('평점순은 평점 내림차순이다', () {
      final sorted = MovieSortOrder.rating.apply(movies);
      expect(sorted.first.title, '기억의 숲');
      expect(sorted.last.title, '밤의 그림자');
    });

    test('제목순은 가나다순이다', () {
      final sorted = MovieSortOrder.title.apply(movies);
      expect(sorted.first.title, '기억의 숲');
      expect(sorted.last.title, '우주의 끝에서');
    });
  });
}
