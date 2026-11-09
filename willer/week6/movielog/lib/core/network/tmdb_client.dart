import 'package:dio/dio.dart'; // Dio, BaseOptions 사용 가능
import 'package:flutter/foundation.dart'; // kDebugMode 사용 가능

import '../config/tmdb_config.dart';
import 'tmdb_logging_interceptor.dart';

Dio createTmdbClient() { // TMDB 설정을 넣은 Dio 객체를 만들어 돌려줌. 자체 API용 Client와 분리
  final dio = Dio(
    BaseOptions( // 모든 요청에 자동으로 붙는 기본 설정
      baseUrl: 'https://api.themoviedb.org/3', // Service에서는 뒷주소만 적으면 됨
      connectTimeout: const Duration(seconds: 10), // 연결까지 최대 10초
      receiveTimeout: const Duration(seconds: 10), // 응답 받기까지 최대 10초
      headers: {
        'Authorization': 'Bearer ${TmdbConfig.accessToken}', // TMDB Token을 Bearer 형식으로 실어 보냄
        'accept': 'application/json', // 응답은 JSON으로
      },
    ),
  );

  if (kDebugMode) { // 개발 중일 때만 로그 검문소를 세움. release 빌드에서는 로그 없음
    dio.interceptors.add(TmdbLoggingInterceptor());
  }

  return dio;
}