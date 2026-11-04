import 'package:dio/dio.dart';

import '../models/rating_dto.dart';

class MemberApiService { // 자체 API의 회원, 평점 요청만 담당. 화면 상태는 없음
  MemberApiService(this._dio);
  final Dio _dio;

  Future<bool> isNicknameAvailable(String nickname) async { // 사용 가능하면 true
    final response = await _dio.get(
      '/members/nickname/${Uri.encodeComponent(nickname)}', // 한글 닉네임도 주소에 넣을 수 있게 인코딩
    );
    return (response.data as Map<String, dynamic>)['available'] as bool; // {"available": true}에서 값만 꺼냄
  }

  Future<bool> isEmailAvailable(String email) async {
    final response = await _dio.get(
      '/members/email/${Uri.encodeComponent(email)}',
    );
    return (response.data as Map<String, dynamic>)['available'] as bool;
  }

  Future<List<RatingDto>> fetchRatings(int memberId) async { // 회원의 평점 목록. 서버가 최신순으로 줌
    final response = await _dio.get('/members/$memberId/ratings');
    return (response.data as List<dynamic>) // 응답이 JSON 배열이라 List로 받음
        .map((json) => RatingDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}