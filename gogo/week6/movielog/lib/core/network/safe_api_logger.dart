
import 'package:dio/dio.dart';

/// 개인정보를 노출하지 않고 API 요청을 기록하는 로거
class SafeApiLogger extends Interceptor {
  SafeApiLogger(this.write);

  final void Function(String) write;

  String _summary(RequestOptions options) {
    final hasAuth = options.headers.keys.any(
      (key) => key.toLowerCase() == 'authorization',
    );

    final path = options.uri.path;

    String endpoint;

    if (path.startsWith('/v5/members/email/')) {
      endpoint = '/v5/members/email/{email}'; // ⭐ 이메일 조회
    } else if (path.startsWith('/v5/members/nickname/')) {
      endpoint = '/v5/members/nickname/{nickname}'; // ⭐ 닉네임 조회
    } else if (RegExp(r'^/v5/members/\d+/ratings$').hasMatch(path)) {
      endpoint = '/v5/members/{memberId}/ratings'; // ⭐ 평점 조회
    } else {
      endpoint = '/other'; // 알 수 없는 경로의 실제 값은 숨김
    }

    return '${options.method} ${options.uri.host}$endpoint'
        '${hasAuth ? ' Authorization: Bearer ***' : ''}';
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    write('[HTTP] ${_summary(options)}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    write(
      '[HTTP] ${_summary(response.requestOptions)} '
      '${response.statusCode}',
    );
    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    write(
      '[HTTP] ${_summary(err.requestOptions)} '
      '${err.response?.statusCode ?? err.type.name}',
    );
    handler.next(err);
  }
}
