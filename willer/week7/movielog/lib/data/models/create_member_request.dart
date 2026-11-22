class CreateMemberRequest { // 회원가입 요청 body를 담는 상자
  const CreateMemberRequest({
    required this.email,
    required this.password,
    required this.nickname,
  });

  final String email;
  final String password;
  final String nickname;

  Map<String, dynamic> toJson() => { // Dart 객체를 요청 JSON으로 바꿈
        'email': email.trim(),
        'password': password, // 공백도 비밀번호의 일부라 trim하지 않음
        'nickname': nickname.trim(),
      };
}