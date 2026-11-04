import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/services/week6_services.dart';

enum CheckStatus { idle, checking, available, duplicated, error }

enum CheckField { nickname, email }

class FieldCheck {
  String value = '';
  CheckStatus status = CheckStatus.idle;
  String? errorText;
  int version = 0;
}

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel(this.service);
  final MemberCheckService service;
  final nickname = FieldCheck();
  final email = FieldCheck();
  bool _disposed = false;
  FieldCheck field(CheckField kind) =>
      kind == CheckField.nickname ? nickname : email;
  static String? validate(CheckField kind, String value) {
    final text = value.trim();
    if (kind == CheckField.nickname) {
      return text.length < 2 ? '닉네임은 두 글자 이상 입력해 주세요.' : null;
    }
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)
        ? null
        : '올바른 이메일을 입력해 주세요.';
  }

  bool canCheck(CheckField kind) =>
      validate(kind, field(kind).value) == null &&
      field(kind).status != CheckStatus.checking;
  bool get bothAvailable =>
      nickname.status == CheckStatus.available &&
      email.status == CheckStatus.available;

  void changed(CheckField kind, String value) {
    final state = field(kind);
    state.value = value.trim();
    state.version++;
    state.status = CheckStatus.idle;
    state.errorText = null;
    if (!_disposed) notifyListeners();
  }

  Future<void> check(CheckField kind) async {
    if (_disposed || !canCheck(kind)) return;
    final state = field(kind);
    final requested = state.value;
    final version = ++state.version;
    bool current() =>
        !_disposed && state.version == version && state.value == requested;
    state.status = CheckStatus.checking;
    state.errorText = null;
    notifyListeners();
    try {
      final available = await (kind == CheckField.nickname
          ? service.checkNickname(requested)
          : service.checkEmail(requested));
      if (!current()) return;
      state.status = available ? CheckStatus.available : CheckStatus.duplicated;
      state.errorText = available
          ? null
          : '이미 사용 중인 ${kind == CheckField.nickname ? '닉네임' : '이메일'}입니다.';
    } on DioException {
      if (!current()) return;
      state.status = CheckStatus.error;
      state.errorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    } catch (_) {
      if (!current()) return;
      state.status = CheckStatus.error;
      state.errorText = '중복 확인 응답을 읽지 못했습니다.';
    }
    if (current()) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    nickname.version++;
    email.version++;
    super.dispose();
  }
}
