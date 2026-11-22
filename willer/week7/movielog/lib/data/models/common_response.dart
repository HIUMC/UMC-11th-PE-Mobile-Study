class CommonResponse<T> { // 공통 응답 상자. isSuccess, code, message, result 네 칸
  const CommonResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    this.result,
  });

  final bool isSuccess;
  final String code; // COMMON201, COMMON409 같은 처리 결과 코드
  final String message; // 사용자에게 바로 보여줄 수 있는 문장
  final T? result; // API마다 담기는 값이 달라서 제네릭. 없거나 실패면 null

  factory CommonResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? value) parseResult, // result를 어떤 객체로 바꿀지는 부르는 쪽이 정함
  ) {
    final rawResult = json['result'];
    return CommonResponse<T>(
      isSuccess: json['isSuccess'] as bool,
      code: json['code'] as String,
      message: json['message'] as String,
      result: rawResult == null ? null : parseResult(rawResult), // null이면 변환 함수를 부르지 않음
    );
  }
}