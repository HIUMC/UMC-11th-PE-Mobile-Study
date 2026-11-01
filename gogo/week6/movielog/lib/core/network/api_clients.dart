import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'safe_api_logger.dart';

Dio _client(BaseOptions options) {
  final dio = Dio(options);
  if (kDebugMode) dio.interceptors.add(SafeApiLogger(debugPrint));
  return dio;
}

Dio createMovieLogClient() => _client(
  BaseOptions(
    baseUrl: 'https://workbook.devnoco.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ),
);

// flutter run --dart-define-from-file=.env
// .env stays out of Git. The value is compiled into the local client build.
Dio createTmdbClient() {
  const token = String.fromEnvironment('TMDB_ACCESS_TOKEN');
  return _client(
    BaseOptions(
      baseUrl: 'https://api.themoviedb.org/3',
      headers: token.isEmpty ? {} : {'Authorization': 'Bearer ${token.trim()}'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}
