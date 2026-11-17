import 'package:dio/dio.dart';
import 'package:movielog/data/models/check_result.dart';
import 'package:movielog/data/models/common_response.dart';
import 'package:movielog/data/models/create_member_request.dart';
import 'package:movielog/data/models/sign_up_models.dart';

class SignUpService {
  SignUpService(this._dio);
  final Dio _dio;

  Future<bool> checkNickname(String nickname) async {
    final encoded = Uri.encodeComponent(nickname.trim());
    final response = await _dio.get('/v5/members/nickname/$encoded');
    return CheckResult.fromJson(response.data as Map<String, dynamic>)
        .available;
  }

  Future<bool> checkEmail(String email) async {
    final encoded = Uri.encodeComponent(email.trim());
    final response = await _dio.get('/v5/members/email/$encoded');
    return CheckResult.fromJson(response.data as Map<String, dynamic>)
        .available;
  }

  Future<CommonResponse<SignUpResult>> signUp(
    CreateMemberRequest request,
  ) async {
    final response = await _dio.post('/v6/members', data: request.toJson());

    return CommonResponse<SignUpResult>.fromJson(
      response.data as Map<String, dynamic>,
      (value) => SignUpResult.fromJson(value as Map<String, dynamic>),
    );
  }
}

/// 회원가입 실패 메시지. 서버가 보낸 message가 있으면 그대로 씁니다.
String writeSignUpErrorMessage(DioException error) {
  final data = error.response?.data;
  if (data is Map<String, dynamic> && data['message'] is String) {
    return data['message'] as String;
  }
  return switch (error.response?.statusCode) {
    400 => '입력값을 다시 확인해 주세요.',
    409 => '이미 가입된 닉네임 또는 이메일입니다.',
    _ => '회원가입에 실패했습니다. 잠시 후 다시 시도해 주세요.',
  };
}

/// 400 응답이 비밀번호 형식 오류인지 판단합니다.
/// 응답의 code·message·result(필드별 오류) 중 어디든 password/비밀번호가
/// 언급되면 비밀번호 오류로 봅니다.
bool isPasswordFormatError(DioException error) {
  if (error.response?.statusCode != 400) return false;
  final data = error.response?.data;
  if (data is! Map<String, dynamic>) return false;
  final text = [data['code'], data['message'], data['result']]
      .whereType<Object>()
      .join(' ')
      .toLowerCase();
  return text.contains('password') || text.contains('비밀번호');
}
