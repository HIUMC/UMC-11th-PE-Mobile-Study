import 'package:dio/dio.dart';

import '../models/rating_dto.dart';

class RatingApiService { // 워크북 서버의 평점 조회만 담당. 화면 상태는 없음
  RatingApiService(this._dio);
  final Dio _dio;

  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    final response = await _dio.get('/v5/members/$memberId/ratings');
    final list = response.data as List<dynamic>; // 공통 Wrapper 없이 배열이 바로 옴
    return list
        .map((item) => RatingDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

String writeMyRatingsErrorMessage(DioException error) { // 실패 원인별로 사용자 문구를 나눔
  final status = error.response?.statusCode; // 서버 응답 자체가 없으면 null
  if (status == 400) return 'memberId 형식을 다시 확인해 주세요.';
  if (status == 404) return '존재하지 않는 회원입니다.';
  return '평점을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.';
}