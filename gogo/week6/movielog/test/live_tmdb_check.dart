// Opt-in network check; not part of the default *_test.dart suite.
// flutter test test/live_tmdb_check.dart --dart-define-from-file=.env
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/network/api_clients.dart';
import 'package:movielog/data/services/week6_services.dart';

void main() {
  test('direct TMDB HTTPS returns movie title and poster', () async {
    const configured = String.fromEnvironment('TMDB_ACCESS_TOKEN');
    if (configured.isEmpty) {
      fail('Pass --dart-define-from-file=.env to this opt-in test.');
    }
    final dio = createTmdbClient();
    try {
      final movie = await TmdbMovieService(dio).findMovieById(550);
      expect(movie?.title.isNotEmpty, isTrue);
      expect(movie?.posterPath?.isNotEmpty, isTrue);
    } on DioException catch (error) {
      // Never print an exception that might contain request credentials.
      fail('TMDB request failed: ${error.response?.statusCode ?? error.type.name}');
    } finally {
      dio.close();
    }
  });
}
