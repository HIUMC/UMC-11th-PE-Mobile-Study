class SignUpResult { // 회원가입 성공 응답의 result에 들어가는 값
  const SignUpResult({
    required this.memberId,
    required this.email,
    required this.nickname,
  });

  final int memberId; // 이후 평점 요청 path에 쓰는 학습용 회원 id
  final String email;
  final String nickname;

  factory SignUpResult.fromJson(Map<String, dynamic> json) { // 서버 응답을 Dart 객체로 바꿈
    return SignUpResult(
      memberId: (json['memberId'] as num).toInt(),
      email: json['email'] as String,
      nickname: json['nickname'] as String,
    );
  }
}