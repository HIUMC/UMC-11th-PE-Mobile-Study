import 'package:dio/dio.dart';

Dio createMovieLogClient() { // 워크북 서버용 Dio. TMDB Client와 주소, 헤더가 달라서 따로 만듦
  return Dio(
    BaseOptions(
      baseUrl: 'https://workbook.devnoco.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}