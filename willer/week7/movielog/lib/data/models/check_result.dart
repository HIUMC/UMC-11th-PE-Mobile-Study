class CheckResult { // 중복 확인 응답을 담는 상자
  const CheckResult({required this.available});

  final bool available; // true면 사용 가능

  factory CheckResult.fromJson(Map<String, dynamic> json) { // 공통 Wrapper가 없어서 응답 body를 바로 받음
    return CheckResult(available: json['available'] as bool);
  }
}