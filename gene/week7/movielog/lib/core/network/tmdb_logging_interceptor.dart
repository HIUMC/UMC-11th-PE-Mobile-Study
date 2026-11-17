import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// TMDB Client를 거치는 모든 요청·응답·오류를 콘솔에 기록합니다.
///
/// 기록만 담당하고, 화면 표시나 저장은 하지 않습니다.
class TmdbLoggingInterceptor extends Interceptor {
  static const _sensitiveHeaders = {'authorization'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[TMDB 요청] ${options.method} ${options.uri}');
    debugPrint('[TMDB 요청 Header] ${_maskHeaders(options.headers)}');
    if (options.queryParameters.isNotEmpty) {
      debugPrint('[TMDB 요청 Query] ${options.queryParameters}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '[TMDB 응답] ${response.statusCode} ${response.requestOptions.uri}',
    );
    debugPrint('[TMDB 응답 Body] ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = err.requestOptions;
    debugPrint('[TMDB 오류] ${request.method} ${request.uri}');
    debugPrint('[TMDB 오류 Header] ${_maskHeaders(request.headers)}');
    debugPrint('[TMDB 오류 내용] ${err.type.name}: ${err.message}');

    // 서버가 응답한 경우(401, 404 등) status와 응답 모양도 남깁니다.
    final response = err.response;
    if (response != null) {
      debugPrint('[TMDB 오류 응답] ${response.statusCode} ${response.data}');
    }
    handler.next(err);
  }

  /// 헤더 이름의 대소문자와 상관없이 민감한 값을 가립니다.
  Map<String, dynamic> _maskHeaders(Map<String, dynamic> headers) {
    return {
      for (final MapEntry(:key, :value) in headers.entries)
        key: _sensitiveHeaders.contains(key.toLowerCase())
            ? 'Bearer ***'
            : value,
    };
  }
}
