import 'package:dio/dio.dart';

import '../models/check_result.dart';
import '../models/common_response.dart';
import '../models/create_member_request.dart';
import '../models/sign_up_models.dart';

class SignUpService { // 닉네임, 이메일 중복 확인과 회원가입 요청을 담당. 화면 상태는 없음
  SignUpService(this._dio);
  final Dio _dio;

  Future<bool> checkNickname(String nickname) async {
    final encoded = Uri.encodeComponent(nickname.trim()); // 한글, 특수문자도 주소에 넣을 수 있게 인코딩
    final response = await _dio.get('/v6/members/nickname/$encoded');
    return CheckResult.fromJson(response.data as Map<String, dynamic>).available;
  }

  Future<bool> checkEmail(String email) async {
    final encoded = Uri.encodeComponent(email.trim());
    final response = await _dio.get('/v6/members/email/$encoded');
    return CheckResult.fromJson(response.data as Map<String, dynamic>).available;
  }

  Future<CommonResponse<SignUpResult>> signUp(CreateMemberRequest request) async {
    final response = await _dio.post(
      '/v6/members',
      data: request.toJson(), // 요청 body
    );
    return CommonResponse<SignUpResult>.fromJson( // 공통 응답을 한 번 풀고 result만 SignUpResult로 바꿈
      response.data as Map<String, dynamic>,
      (value) => SignUpResult.fromJson(value as Map<String, dynamic>),
    );
  }
}

String writeSignUpErrorMessage(DioException error) { // 실패 응답의 서버 message를 그대로 꺼냄
  final data = error.response?.data;
  final common = data is Map<String, dynamic> // 서버 응답이 없거나 JSON이 아니면 null
      ? CommonResponse<Object?>.fromJson(data, (value) => value)
      : null;
  return common?.message ?? '회원가입에 실패했습니다. 잠시 후 다시 시도해 주세요.';
}