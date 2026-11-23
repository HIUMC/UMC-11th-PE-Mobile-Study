import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

Dio createMovieLogClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://workbook.devnoco.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  // 디버그 실행에서만 회원·평점 서버 요청과 응답을 콘솔에 남깁니다.
  if (kDebugMode) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint(
            '[MovieLog 요청] ${options.method} ${options.uri} '
            '${_maskPassword(options.data)}',
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            '[MovieLog 응답] ${response.statusCode} '
            '${response.requestOptions.uri} ${response.data}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint(
            '[MovieLog 오류] ${error.response?.statusCode} '
            '${error.requestOptions.uri} ${error.response?.data ?? error.message}',
          );
          handler.next(error);
        },
      ),
    );
  }
  return dio;
}

/// 회원가입 요청의 비밀번호가 로그에 남지 않게 가립니다.
Object? _maskPassword(Object? data) {
  if (data is Map && data.containsKey('password')) {
    return {...data, 'password': '***'};
  }
  return data;
}
