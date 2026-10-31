import 'package:dio/dio.dart'; // Dio, BaseOptions, LogInterceptor 사용 가능
import 'package:flutter/foundation.dart'; // kDebugMode 사용 가능

Dio createMovieLogClient() { // 자체 API(Spring 서버)용 Dio. TMDB Client와 주소, 인증 방식이 달라서 따로 만듦
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080', // 안드로이드 에뮬레이터에서 10.0.2.2는 맥의 localhost를 가리킴
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {'accept': 'application/json'}, // 아직 로그인이 없어서 인증 헤더 없음
    ),
  );

  if (kDebugMode) { // 개발 중에만 요청과 응답을 터미널에 찍음
    dio.interceptors.add(LogInterceptor(requestHeader: false, responseBody: true)); // Dio 기본 로그. 응답 JSON까지 출력
  }

  return dio;
}