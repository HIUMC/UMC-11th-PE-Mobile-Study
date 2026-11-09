import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // ChangeNotifier 사용 가능

import '../data/services/member_check_service.dart';

enum CheckStatus { idle, checking, available, duplicated, error } // 확인 전, 통신 중, 사용 가능, 중복, 통신 실패

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel(this._service);
  final MemberCheckService _service;

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

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}