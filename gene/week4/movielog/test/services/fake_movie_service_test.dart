import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/movies.dart';
import 'package:movielog/services/fake_movie_service.dart';

void main() {
  const service = FakeMovieService(
    delay: Duration(milliseconds: 10),
    timeLimit: Duration(milliseconds: 50),
  );

  group('FakeMovieService.fetchMovies', () {
    test('success 모드는 Mock 영화 목록을 반환한다', () async {
      final result = await service.fetchMovies();

      expect(result, movies);
    });

    test('empty 모드는 빈 목록을 반환한다', () async {
      final result = await service.fetchMovies(mode: MovieLoadMode.empty);

      expect(result, isEmpty);
    });

    test('failure 모드는 MovieLoadException으로 완료된다', () async {
      await expectLater(
        service.fetchMovies(mode: MovieLoadMode.failure),
        throwsA(
          isA<MovieLoadException>().having(
            (e) => e,
            'not timeout',
            isNot(isA<MovieLoadTimeoutException>()),
          ),
        ),
      );
    });

    test('slow 모드는 제한 시간이 지나면 Timeout 오류로 완료된다', () async {
      await expectLater(
        service.fetchMovies(mode: MovieLoadMode.slow),
        throwsA(isA<MovieLoadTimeoutException>()),
      );
    });

    test('기본 설정은 최소 800ms 이상 지연된 뒤 완료된다', () {
      fakeAsync((async) {
        List<Movie>? result;
        const FakeMovieService().fetchMovies().then((value) => result = value);

        async.elapse(const Duration(milliseconds: 800));
        expect(result, isNull);

        async.elapse(const Duration(milliseconds: 200));
        expect(result, movies);
      });
    });
  });
}
