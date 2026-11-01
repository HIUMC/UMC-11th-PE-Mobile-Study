import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/tmdb_config.dart';
import 'tmdb_logging_interceptor.dart';

/// TMDB API 호출에 사용할 Dio Client를 만듭니다.
///
/// 토큰이 없으면 [TmdbConfigException]을 던집니다.
Dio createTmdbClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.themoviedb.org/3',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        'Authorization': 'Bearer ${TmdbConfig.accessToken}',
        'Accept': 'application/json',
      },
      queryParameters: {'language': 'ko-KR'},
    ),
  );

  // 로그는 개발 중 확인 용도이므로 디버그 빌드에서만 등록합니다.
  if (kDebugMode) {
    dio.interceptors.add(TmdbLoggingInterceptor());
  }

  return dio;
}
