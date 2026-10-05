import '../data/movies.dart';

/// Mock 응답 동작. 실제 API로 교체되면 사라질 테스트용 스위치입니다.
enum MovieLoadMode {
  success('성공'),
  empty('빈 목록'),
  failure('실패'),
  slow('응답 지연(Timeout)');

  const MovieLoadMode(this.label);

  final String label;
}

class MovieLoadException implements Exception {
  const MovieLoadException(this.message);

  final String message;

  @override
  String toString() => 'MovieLoadException: $message';
}

/// 제한 시간 안에 응답이 오지 않았을 때 발생합니다.
class MovieLoadTimeoutException extends MovieLoadException {
  const MovieLoadTimeoutException() : super('영화 목록 응답 시간이 초과되었습니다.');
}

class FakeMovieService {
  const FakeMovieService({
    this.delay = const Duration(seconds: 1),
    this.timeLimit = const Duration(seconds: 3),
  });

  /// 응답까지 걸리는 시간. Loading 화면이 보이도록 800ms 이상으로 둡니다.
  final Duration delay;

  /// 이 시간이 지나도 응답이 없으면 [MovieLoadTimeoutException]으로 완료됩니다.
  final Duration timeLimit;

  // TODO(5주차 유저별 평점 조회 API): FakeMovieService를 실제 API Service로 교체
  Future<List<Movie>> fetchMovies({
    MovieLoadMode mode = MovieLoadMode.success,
  }) {
    return _request(mode).timeout(
      timeLimit,
      onTimeout: () => throw const MovieLoadTimeoutException(),
    );
  }

  Future<List<Movie>> _request(MovieLoadMode mode) async {
    // slow 모드는 제한 시간보다 늦게 응답해 Timeout을 재현합니다.
    final wait = mode == MovieLoadMode.slow
        ? timeLimit + const Duration(seconds: 1)
        : delay;
    await Future<void>.delayed(wait);

    return switch (mode) {
      MovieLoadMode.success || MovieLoadMode.slow => movies,
      MovieLoadMode.empty => const <Movie>[],
      MovieLoadMode.failure =>
        throw const MovieLoadException('영화를 불러오지 못했습니다.'),
    };
  }
}
