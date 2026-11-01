import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/network/api_clients.dart';
import 'package:movielog/core/network/safe_api_logger.dart';

void main() {
  test('clients use separate HTTPS upstreams', () {
    final workbook = createMovieLogClient();
    final tmdb = createTmdbClient();
    expect(workbook.options.baseUrl, 'https://workbook.devnoco.com');
    expect(tmdb.options.baseUrl, 'https://api.themoviedb.org/3');
    expect(workbook.options.headers.containsKey('Authorization'), isFalse);
    workbook.close();
    tmdb.close();
  });

  test(
    'request, response and error logs mask credentials and private data',
    () async {
      final logs = <String>[];
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://api.themoviedb.org/3',
          headers: {'Authorization': 'Bearer fake-test-secret'},
        ),
      );
      dio.interceptors.add(SafeApiLogger(logs.add));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.headers['Authorization'], 'Bearer fake-test-secret');
            if (options.path == '/failure') {
              handler.reject(
                DioException(
                  requestOptions: options,
                  error: 'fake-test-secret',
                  response: Response(requestOptions: options, statusCode: 401),
                ),
              );
            } else {
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: 'private-body',
                  statusCode: 200,
                ),
                true,
              );
            }
          },
        ),
      );
      await dio.get<dynamic>('/movie/550?private=value');
      await expectLater(
        dio.get<dynamic>('/failure'),
        throwsA(isA<DioException>()),
      );
      final output = logs.join('\n');
      expect(output, contains('Authorization: Bearer ***'));
      expect(output, contains('200'));
      expect(output, contains('401'));
      expect(output, isNot(contains('fake-test-secret')));
      expect(output, isNot(contains('private')));
      dio.close();
    },
  );
}
