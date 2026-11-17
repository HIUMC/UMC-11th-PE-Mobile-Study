import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:movielog/data/models/create_member_request.dart';
import 'package:movielog/data/services/sign_up_service.dart';

enum CheckStatus { idle, checking, available, duplicated, error }

enum SubmitStatus { idle, submitting, success, error }

/// 닉네임·이메일처럼 "입력 → 서버 중복 확인" 흐름을 가진 한 칸의 상태입니다.
class DuplicateCheckState {
  DuplicateCheckState(this.duplicatedMessage);

  final String duplicatedMessage;
  CheckStatus status = CheckStatus.idle;
  String? errorText;
  String? _duplicatedValue;
  String _currentValue = '';
  int _requestVersion = 0;

  bool get canCheck =>
      status != CheckStatus.checking && status != CheckStatus.duplicated;

  bool get isAvailable => status == CheckStatus.available;

  void _onChanged(String value) {
    final trimmed = value.trim();
    _currentValue = trimmed;
    _requestVersion++; // 이전 요청의 응답을 무효화합니다.
    if (_duplicatedValue != null && trimmed == _duplicatedValue) {
      status = CheckStatus.duplicated;
      errorText = duplicatedMessage;
    } else {
      status = CheckStatus.idle;
      errorText = null;
    }
  }
}

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel(this._service);
  final SignUpService _service;

  final nickname = DuplicateCheckState('이미 사용 중인 닉네임입니다.');
  final email = DuplicateCheckState('이미 사용 중인 이메일입니다.');

  SubmitStatus submitStatus = SubmitStatus.idle;
  int? createdMemberId;
  String? passwordErrorText;
  String? snackbarMessage;
  bool _disposed = false;

  bool get isSubmitting => submitStatus == SubmitStatus.submitting;

  void onNicknameChanged(String value) {
    nickname._onChanged(value);
    _notify();
  }

  void onEmailChanged(String value) {
    email._onChanged(value);
    _notify();
  }

  /// 비밀번호를 고치면 서버가 보냈던 비밀번호 오류를 지웁니다.
  void onPasswordChanged() {
    if (passwordErrorText == null) return;
    passwordErrorText = null;
    _notify();
  }

  Future<void> checkNickname(String value) =>
      _check(nickname, value, _service.checkNickname);

  Future<void> checkEmail(String value) =>
      _check(email, value, _service.checkEmail);

  Future<void> _check(
    DuplicateCheckState state,
    String value,
    Future<bool> Function(String) request,
  ) async {
    final requested = value.trim();
    if (requested.isEmpty ||
        requested != state._currentValue ||
        !state.canCheck ||
        isSubmitting) {
      return;
    }

    final version = ++state._requestVersion;
    state.status = CheckStatus.checking;
    state.errorText = null;
    _notify();

    bool isStale() =>
        _disposed ||
        version != state._requestVersion ||
        state._currentValue != requested;

    try {
      final available = await request(requested);
      if (isStale()) return;
      state.status = available ? CheckStatus.available : CheckStatus.duplicated;
      state.errorText = available ? null : state.duplicatedMessage;
      if (!available) state._duplicatedValue = requested;
    } on DioException {
      if (isStale()) return;
      state.status = CheckStatus.error;
      state.errorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }
    _notify();
  }

  /// 회원가입을 요청합니다. 이미 제출 중이면 아무것도 하지 않습니다.
  /// 성공하면 [createdMemberId]에 result.memberId가 담깁니다.
  Future<void> submit(CreateMemberRequest request) async {
    if (isSubmitting) return;
    submitStatus = SubmitStatus.submitting;
    createdMemberId = null;
    passwordErrorText = null;
    snackbarMessage = null;
    _notify();

    try {
      final response = await _service.signUp(request);
      if (_disposed) return;
      final result = response.result;
      if (result == null) {
        submitStatus = SubmitStatus.error;
        snackbarMessage = response.message;
      } else {
        createdMemberId = result.memberId;
        submitStatus = SubmitStatus.success;
      }
    } on DioException catch (error) {
      if (_disposed) return;
      submitStatus = SubmitStatus.error;
      final message = writeSignUpErrorMessage(error);
      if (error.response?.statusCode == 400 && isPasswordFormatError(error)) {
        // 400 중 비밀번호 형식 오류만 입력칸 아래에 보여줍니다.
        passwordErrorText = message;
      } else {
        // 그 외 400, 409(중복), 나머지 오류는 Snackbar로 보여줍니다.
        snackbarMessage = message;
      }
    }
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    nickname._requestVersion++;
    email._requestVersion++;
    super.dispose();
  }
}
