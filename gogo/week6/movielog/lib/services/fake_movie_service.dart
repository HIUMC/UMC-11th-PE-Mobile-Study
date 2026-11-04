import '../data/mock_movies.dart';
import '../models/movie.dart';

enum MovieResponse { success, empty, failure, slow }

// === [학습 · Mock Service] 서버 없이 지연·성공·실패를 재현하는 조회 경계 ===
// Future<List<Movie>>: 나중에 영화 목록 또는 오류 하나를 전달하는 비동기 결과.
class FakeMovieService {
  const FakeMovieService({this.delay = const Duration(seconds: 1)});
  final Duration delay;

  // TODO(5주차 유저별 평점 조회 API): 실제 API 호출로 이 메서드를 교체 예정.
  Future<List<Movie>> fetchMovies({
    MovieResponse mode = MovieResponse.success,
  }) async {
    // [async/await] UI 스레드를 막지 않고 대기. 기본 1초 동안 로딩 화면 확인 가능.
    await Future<void>.delayed(
      mode == MovieResponse.slow ? const Duration(seconds: 5) : delay,
    );
    if (mode == MovieResponse.failure) throw StateError('Mock request failed');
    return mode == MovieResponse.empty ? [] : List.of(mockMovies);
  }
}
