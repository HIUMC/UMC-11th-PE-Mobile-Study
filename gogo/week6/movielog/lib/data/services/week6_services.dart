import 'package:dio/dio.dart';

import '../models/rating_dto.dart';

class MemberCheckService {
  MemberCheckService(this.dio);
  final Dio dio;
  Future<bool> checkNickname(String value) => _check('nickname', value);
  Future<bool> checkEmail(String value) => _check('email', value);
  Future<bool> _check(String field, String value) async {
    final response = await dio.get<dynamic>(
      '/v5/members/$field/${Uri.encodeComponent(value.trim())}',
    );
    return (response.data as Map<String, dynamic>)['available'] as bool;
  }
}

class RatingApiService {
  RatingApiService(this.dio);
  final Dio dio;
  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    final response = await dio.get<dynamic>('/v5/members/$memberId/ratings');
    return (response.data as List)
        .map((item) => RatingDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

class TmdbMovieService {
  TmdbMovieService(this.dio);
  final Dio dio;
  Future<MovieInfo?> findMovieById(int id) async {
    try {
      final response = await dio.get<dynamic>(
        '/movie/$id',
        queryParameters: {'language': 'ko-KR'},
      );
      return MovieInfo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}

String ratingsErrorMessage(Object error) {
  if (error is DioException) {
    if (error.response?.statusCode == 400) return 'memberId 형식을 다시 확인해 주세요.';
    if (error.response?.statusCode == 404) return '존재하지 않는 회원입니다.';
    return '평점을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.';
  }
  return '평점 응답을 읽지 못했습니다. 다시 시도해 주세요.';
}
