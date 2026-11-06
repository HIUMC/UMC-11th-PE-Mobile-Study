import 'package:dio/dio.dart';

import '../models/check_result.dart';

class MemberCheckService { // 닉네임, 이메일 중복 확인 요청만 담당. 화면 상태는 없음
  MemberCheckService(this._dio);
  final Dio _dio;

  Future<bool> checkNickname(String nickname) async {
    final encoded = Uri.encodeComponent(nickname.trim()); // 한글, 특수문자도 주소에 넣을 수 있게 인코딩
    final response = await _dio.get('/v5/members/nickname/$encoded');
    return CheckResult.fromJson(response.data as Map<String, dynamic>).available;
  }

  Future<bool> checkEmail(String email) async {
    final encoded = Uri.encodeComponent(email.trim());
    final response = await _dio.get('/v5/members/email/$encoded');
    return CheckResult.fromJson(response.data as Map<String, dynamic>).available;
  }
}