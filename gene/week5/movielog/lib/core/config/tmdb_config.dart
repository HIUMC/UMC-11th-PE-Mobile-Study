import 'package:flutter_dotenv/flutter_dotenv.dart';

/// TMDB 설정값이 없거나 읽을 수 없을 때 발생합니다.
class TmdbConfigException implements Exception {
  const TmdbConfigException(this.message);

  final String message;

  @override
  String toString() => 'TmdbConfigException: $message';
}

abstract final class TmdbConfig {
  static const accessTokenKey = 'TMDB_ACCESS_TOKEN';

  /// `.env`의 TMDB Read Access Token.
  ///
  /// `.env`를 아직 불러오지 않았거나 값이 비어 있으면 [TmdbConfigException]을 던집니다.
  static String get accessToken {
    if (!dotenv.isInitialized) {
      throw const TmdbConfigException(
        '.env가 로드되지 않았습니다. main()에서 dotenv.load()를 먼저 호출하세요.',
      );
    }

    final token = dotenv.maybeGet(accessTokenKey)?.trim() ?? '';
    if (token.isEmpty) {
      throw const TmdbConfigException(
        '$accessTokenKey 값이 .env에 없습니다. .env 파일을 확인하세요.',
      );
    }
    return token;
  }

  /// 예외 없이 토큰이 준비됐는지만 확인할 때 사용합니다.
  static bool get hasAccessToken {
    try {
      accessToken;
      return true;
    } on TmdbConfigException {
      return false;
    }
  }

  /// 앱 시작 시 호출해 누락을 빨리 발견합니다.
  static void validate() => accessToken;
}
