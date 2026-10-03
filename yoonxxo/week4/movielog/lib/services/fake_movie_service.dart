import '../data/mock_movies.dart';
import '../models/movie.dart';

// 영화 목록을 불러오는 과정에서 발생할 수 있는 상태를 정의함.
// success: 정상적으로 영화 목록을 불러온 경우
// empty: 영화가 하나도 없는 경우
// failure: 영화 목록을 불러오는 데 실패한 경우
enum MovieLoadMode { success, empty, failure }

// 영화 목록을 불러오는 과정에서 발생한 오류를 표현하는 예외 클래스
class MovieLoadException implements Exception {
  const MovieLoadException(this.message);

  final String message;
}

// 실제 서버 대신 비동기 동작을 흉내 내는 Mock Service
class FakeMovieService {
  const FakeMovieService();

  // 영화 목록을 비동기로 반환함.
  Future<List<Movie>> fetchMovies({
    // 기본값은 성공 상태
    MovieLoadMode mode = MovieLoadMode.success,
  }) async {
    // 실제 네트워크 요청처럼 1초 동안 기다림.
    await Future<void>.delayed(const Duration(seconds: 1));

    // 전달받은 mode에 따라 다른 결과를 반환함.
    return switch (mode) {
      // 성공하면 3주차에서 사용하던 Mock 영화 목록 반환
      MovieLoadMode.success => movies,

      // 빈 결과라면 빈 영화 목록 반환
      MovieLoadMode.empty => const <Movie>[],

      // 실패라면 직접 만든 예외 발생
      MovieLoadMode.failure => throw const MovieLoadException(
        '영화를 불러오지 못했습니다.',
      ),
    };
  }
}
