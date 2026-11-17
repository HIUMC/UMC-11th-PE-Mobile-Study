import 'package:dio/dio.dart';
import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/data/models/rating_request.dart';

class RatingApiService {
  RatingApiService(this._dio);
  final Dio _dio;

  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    final response = await _dio.get('/v5/members/$memberId/ratings');
    final list = response.data as List<dynamic>;
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
    // 201을 성공으로 처리합니다. result의 숫자/null 계약은 확인 전 파싱하지 않습니다.
    if (response.statusCode != 201) {
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
      data: {'score': score, 'comment': comment},
    );
  }

  Future<void> deleteRating({
    required int memberId,
    required int ratingId,
  }) async {
    final response = await _dio.delete(
      '/v6/members/$memberId/ratings/$ratingId',
    );
    if (response.statusCode != 204) {
      throw StateError('예상하지 못한 삭제 응답: ${response.statusCode}');
    }
  }
}

String writeMyRatingsErrorMessage(DioException error) {
  final status = error.response?.statusCode;
  if (status == 400) return 'memberId 형식을 다시 확인해 주세요.';
  if (status == 404) return '존재하지 않는 회원입니다.';
  return '평점을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.';
}

/// 평점 등록·수정·삭제 실패 메시지. 서버가 보낸 message가 있으면 그대로 씁니다.
String writeErrorMessage(DioException error) {
  final data = error.response?.data;
  if (data is Map<String, dynamic> && data['message'] is String) {
    return data['message'] as String;
  }
  return switch (error.response?.statusCode) {
    400 => '입력값을 다시 확인해 주세요.',
    404 => '이미 삭제되었거나 존재하지 않는 평점입니다.',
    _ => '평점을 저장하지 못했습니다. 잠시 후 다시 시도해 주세요.',
  };
}

/// 서버 상태와 화면 목록이 어긋났을 수 있는 에러인지 판단합니다.
/// 404(이미 삭제됨), 409(충돌)이면 목록을 다시 불러와 맞춥니다.
bool shouldRefreshAfterRatingError(DioException error) {
  final status = error.response?.statusCode;
  return status == 404 || status == 409;
}
