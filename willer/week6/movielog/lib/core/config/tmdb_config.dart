import 'package:flutter_dotenv/flutter_dotenv.dart'; // .env에서 읽어온 값 사용 가능

abstract final class TmdbConfig { // abstract로 객체 생성 금지, final로 상속 금지. Token 꺼내는 창구로만 씀
  static String get accessToken => dotenv.env['TMDB_ACCESS_TOKEN'] ?? ''; // 부를 때마다 .env에서 꺼냄. 키가 없으면 빈 문자열
}