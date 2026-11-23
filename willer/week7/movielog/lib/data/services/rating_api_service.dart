import 'package:dio/dio.dart';

import '../models/common_response.dart';
import '../models/rating_dto.dart';
import '../models/rating_request.dart';

class RatingApiService { // 워크북 서버의 평점 조회, 등록, 수정, 삭제를 담당. 화면 상태는 없음
  RatingApiService(this._dio);
  final Dio _dio;

  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    final response = await _dio.get('/v6/members/$memberId/ratings');
    final list = response.data as List<dynamic>; // 공통 Wrapper 없이 배열이 바로 옴
    return list
        .map((item) => RatingDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createRating({
    required int memberId,
    required CreateRatingRequest request,
  }) async {
    final response = await _dio.post(
      '/v6/members/$memberId/ratings',
      data: request.toJson(),
    );
    if (response.statusCode != 201) { // result가 숫자인지 null인지 확정되지 않아 파싱하지 않고 상태 코드만 봄
      throw StateError('예상하지 못한 등록 응답: ${response.statusCode}');
    }
  }

  Future<void> updateRating({
    required int memberId,
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    await _dio.patch(
      '/v6/members/$memberId/ratings/$ratingId',
      data: {'score': score, 'comment': comment}, // comment를 빼면 기존 후기가 null로 덮여서 항상 같이 보냄
    );
  }

  Future<void> deleteRating({
    required int memberId,
    required int ratingId,
  }) async {
    final response = await _dio.delete('/v6/members/$memberId/ratings/$ratingId');
    if (response.statusCode != 204) { // 204는 body가 없어서 data를 읽지 않음
      throw StateError('예상하지 못한 삭제 응답: ${response.statusCode}');
    }
  }
}

String writeMyRatingsErrorMessage(DioException error) { // 실패 원인별로 사용자 문구를 나눔
  final status = error.response?.statusCode; // 서버 응답 자체가 없으면 null
  if (status == 400) return 'memberId 형식을 다시 확인해 주세요.';
  if (status == 404) return '존재하지 않는 회원입니다.';
  return '평점을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.';
}

String writeErrorMessage(DioException error) { // 쓰기 실패 응답의 서버 message를 그대로 꺼냄
  final data = error.response?.data;
  final common = data is Map<String, dynamic>
      ? CommonResponse<Object?>.fromJson(data, (value) => value)
      : null;
  return common?.message ?? '요청에 실패했습니다. 잠시 후 다시 시도해 주세요.';
}

bool shouldRefreshAfterRatingError(DioException error) { // 문구가 아니라 다음 행동(재조회 여부)만 code로 정함
  final data = error.response?.data;
  final code = data is Map<String, dynamic> ? data['code'] as String? : null;
  return code == 'COMMON403' || code == 'COMMON404'; // 화면 목록이 서버와 어긋났다는 뜻이라 다시 조회. 400, 409는 값만 고치면 됨
}