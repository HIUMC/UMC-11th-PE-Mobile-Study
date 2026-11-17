import 'package:dio/dio.dart';

/// 화면에 보여줄 오류 문구. 내부 Exception 내용은 노출하지 않습니다.
String tmdbErrorMessage(Object error, {required String fallback}) {
  return switch (error) {
    DioException(
      type: DioExceptionType.connectionTimeout ||
          DioExceptionType.sendTimeout ||
          DioExceptionType.receiveTimeout,
    ) =>
      '응답이 너무 오래 걸리고 있어요.\n네트워크 상태를 확인한 뒤 다시 시도해 주세요.',
    DioException(type: DioExceptionType.connectionError) =>
      '인터넷에 연결할 수 없어요.\n연결 상태를 확인해 주세요.',
    DioException(response: Response(statusCode: 401)) =>
      'TMDB 인증에 실패했어요.\nAPI 토큰을 확인해 주세요.',
    _ => fallback,
  };
}
