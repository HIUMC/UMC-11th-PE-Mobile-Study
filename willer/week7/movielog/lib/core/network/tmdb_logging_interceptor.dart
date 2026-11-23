import 'package:dio/dio.dart'; // Interceptor, RequestOptions, Response, DioException 사용 가능
import 'package:flutter/foundation.dart'; // debugPrint 사용 가능

class TmdbLoggingInterceptor extends Interceptor { // Dio Client를 지나가는 모든 요청과 응답이 거치는 검문소
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) { // 요청이 나가기 직전에 Dio가 부름
    final maskedHeaders = Map<String, dynamic>.from(options.headers); // 로그용 Header 복사본. 원본은 그대로 TMDB로 감
    if (maskedHeaders.containsKey('Authorization')) {
      maskedHeaders['Authorization'] = 'Bearer ***'; // 복사본의 Token만 가림. 원본을 가리면 401
    }
    debugPrint('[TMDB 요청] ${options.method} ${options.uri}'); // 요청 방식과 Query까지 붙은 전체 주소
    debugPrint('[TMDB 요청 Header] $maskedHeaders');
    if (options.queryParameters.isNotEmpty) {
      debugPrint('[TMDB 요청 Query] ${options.queryParameters}'); // with_genres가 붙었는지 여기서 확인
    }
    handler.next(options); // 검사 끝, 다음 단계로 통과. 빼먹으면 요청이 안 나감
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) { // 응답이 돌아왔을 때
    debugPrint('[TMDB 응답] ${response.statusCode} ${response.requestOptions.uri}');
    debugPrint('[TMDB 응답 Body] ${response.data}');
    handler.next(response); // 응답을 그대로 Service로 넘김
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) { // 요청이 실패했을 때
    debugPrint('[TMDB 오류] ${err.requestOptions.uri}');
    debugPrint('[TMDB 오류 내용] ${err.message}');
    handler.next(err); // 실패를 숨기지 않고 넘김. ViewModel의 on DioException이 잡음
  }
}