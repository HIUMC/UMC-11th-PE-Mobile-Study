import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // ChangeNotifier 사용 가능

import '../data/models/create_member_request.dart';
import '../data/services/sign_up_service.dart';

enum CheckStatus { idle, checking, available, duplicated, error } // 확인 전, 통신 중, 사용 가능, 중복, 통신 실패

enum SubmitStatus { idle, submitting, success, error } // 제출 전, 제출 중, 성공, 실패. 평점 등록에서도 같이 씀

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel(this._service);
  final SignUpService _service;

  CheckStatus nicknameCheckStatus = CheckStatus.idle;
  String? nicknameErrorText; // 입력창 errorText에 그대로 연결
  String? _duplicatedNickname; // 마지막으로 중복이었던 값
  String _currentNickname = '';
  int _nicknameRequestVersion = 0; // 요청 번호표. 다르면 늦게 온 응답이라 버림

  CheckStatus emailCheckStatus = CheckStatus.idle; // 닉네임과 결과가 섞이지 않게 이메일 상태를 따로 둠
  String? emailErrorText;
  String? _duplicatedEmail;
  String _currentEmail = '';
  int _emailRequestVersion = 0;

  SubmitStatus submitStatus = SubmitStatus.idle;
  int? createdMemberId; // 가입 성공 응답에서 읽은 실제 id
  String? passwordErrorText; // 서버가 비밀번호 형식으로 거부한 경우. 비밀번호 입력창 아래에 표시
  String? snackbarMessage; // 입력창 하나에 붙일 수 없는 실패. 화면이 Snackbar로 한 번 보여줌

  bool _disposed = false; // 화면을 나간 뒤 도착한 응답을 막음

  bool get canCheckNickname =>
      nicknameCheckStatus != CheckStatus.checking &&
      nicknameCheckStatus != CheckStatus.duplicated; // 중복이면 값을 바꾸기 전까지 비활성

  bool get canCheckEmail =>
      emailCheckStatus != CheckStatus.checking &&
      emailCheckStatus != CheckStatus.duplicated;

  void onNicknameChanged(String value) {
    final trimmed = value.trim(); // 공백 차이로 다른 값이 되지 않게 함
    _currentNickname = trimmed;
    _nicknameRequestVersion++; // 기다리던 이전 응답을 무효화
    if (trimmed == _duplicatedNickname) { // 중복이었던 값이면 재요청 없이 바로 에러
      nicknameCheckStatus = CheckStatus.duplicated;
      nicknameErrorText = '이미 사용 중인 닉네임입니다.';
    } else { // 다른 값이면 이전 결과를 지움
      nicknameCheckStatus = CheckStatus.idle;
      nicknameErrorText = null;
    }
    notifyListeners();
  }

  void onEmailChanged(String value) {
    final trimmed = value.trim();
    _currentEmail = trimmed;
    _emailRequestVersion++;
    if (trimmed == _duplicatedEmail) {
      emailCheckStatus = CheckStatus.duplicated;
      emailErrorText = '이미 사용 중인 이메일입니다.';
    } else {
      emailCheckStatus = CheckStatus.idle;
      emailErrorText = null;
    }
    notifyListeners();
  }

  void onPasswordChanged() { // 값을 고치면 서버가 준 비밀번호 오류를 지움
    passwordErrorText = null;
    notifyListeners();
  }

  Future<void> checkNickname(String value) async {
    final requested = value.trim();
    if (requested.isEmpty || requested != _currentNickname || !canCheckNickname) {
      return;
    }

    final version = ++_nicknameRequestVersion; // 이 요청의 번호표
    nicknameCheckStatus = CheckStatus.checking;
    nicknameErrorText = null;
    notifyListeners();

    try {
      final available = await _service.checkNickname(requested);
      if (_disposed || version != _nicknameRequestVersion) return; // 기다리는 사이 입력이 바뀌었거나 화면을 나감
      nicknameCheckStatus = available ? CheckStatus.available : CheckStatus.duplicated;
      nicknameErrorText = available ? null : '이미 사용 중인 닉네임입니다.';
      if (!available) _duplicatedNickname = requested; // 다시 입력할 때 비교하려고 기억
    } on DioException { // 서버 답을 못 받은 경우. 중복 응답과 문구를 나눔
      if (_disposed || version != _nicknameRequestVersion) return;
      nicknameCheckStatus = CheckStatus.error;
      nicknameErrorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }
    notifyListeners();
  }

  Future<void> checkEmail(String value) async {
    final requested = value.trim();
    if (requested.isEmpty || requested != _currentEmail || !canCheckEmail) {
      return;
    }

    final version = ++_emailRequestVersion;
    emailCheckStatus = CheckStatus.checking;
    emailErrorText = null;
    notifyListeners();

    try {
      final available = await _service.checkEmail(requested);
      if (_disposed || version != _emailRequestVersion) return;
      emailCheckStatus = available ? CheckStatus.available : CheckStatus.duplicated;
      emailErrorText = available ? null : '이미 사용 중인 이메일입니다.';
      if (!available) _duplicatedEmail = requested;
    } on DioException {
      if (_disposed || version != _emailRequestVersion) return;
      emailCheckStatus = CheckStatus.error;
      emailErrorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }
    notifyListeners();
  }

  Future<void> submit(CreateMemberRequest request) async {
    if (submitStatus == SubmitStatus.submitting) return; // 연속 탭 방지
    submitStatus = SubmitStatus.submitting;
    createdMemberId = null;
    passwordErrorText = null;
    snackbarMessage = null;
    notifyListeners();

    try {
      final response = await _service.signUp(request);
      if (_disposed) return;
      final id = response.result?.memberId;
      if (id == null) throw StateError('회원가입 결과에 memberId가 없습니다.'); // 201이어도 id가 없으면 가입 완료로 보지 않음
      createdMemberId = id;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      if (_disposed) return;
      submitStatus = SubmitStatus.error;
      final message = writeSignUpErrorMessage(error);
      if (error.response?.statusCode == 400 && message.contains('비밀번호')) { // 비밀번호 형식 오류만 입력창으로
        passwordErrorText = message;
      } else { // 나머지 400과 409 중복은 Snackbar로
        snackbarMessage = message;
      }
    } on StateError {
      if (_disposed) return;
      submitStatus = SubmitStatus.error;
      snackbarMessage = '가입 결과를 확인하지 못했습니다. 새 요청 전에 서버 상태를 확인해 주세요.';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}