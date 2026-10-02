import '../data/movies.dart'; // Movie 클래스와 Mock 영화 목록

enum MovieLoadMode { success, empty, failure } // 가짜 서비스가 어떤 결과를 낼지 고르는 스위치. 성공·빈 목록·실패

class MovieLoadException implements Exception { // 영화 로드 실패를 나타내는 우리만의 예외. implements Exception으로 예외 취급
  const MovieLoadException(this.message);

  final String message; // 개발자 확인용 메시지. 화면에 그대로 띄우지 않음
}

class FakeMovieService { // 실제 API 대신 쓰는 가짜 서비스. 화면은 이 안이 가짜인지 몰라도 됨
  const FakeMovieService(); // 필드가 없어서 const 가능

  Future<List<Movie>> fetchMovies({ // 지금 목록을 주는 게 아니라 나중에 목록 또는 오류를 주겠다는 약속(Future)을 반환
    MovieLoadMode mode = MovieLoadMode.success, // 안 넘기면 성공
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1)); // 서버 응답을 기다리는 것처럼 1초 지연. 800ms 이상 Loading 조건 충족

    return switch (mode) { // mode 값에 따라 결과를 하나 골라 반환
      MovieLoadMode.success => movies, // 기존 Mock 목록
      MovieLoadMode.empty => const <Movie>[], // 빈 목록. 오류가 아니라 정상 결과
      MovieLoadMode.failure =>
        throw const MovieLoadException('영화를 불러오지 못했습니다.'), // Future가 값이 아니라 오류로 완료됨
    };
  }
}