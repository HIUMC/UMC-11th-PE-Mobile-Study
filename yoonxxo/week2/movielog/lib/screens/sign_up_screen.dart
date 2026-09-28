import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/movie_log_text_form_field.dart';

// 회원가입 화면
//
// 1주차 ProfileScreen은 화면 상태가 바뀌지 않았기 때문에
// StatelessWidget을 사용했지만,
// 회원가입 화면은 입력값, 체크박스 상태 등이 계속 바뀌기 때문에
// StatefulWidget을 사용함.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

// 실제로 변경되는 상태를 관리하는 클래스
class _SignUpScreenState extends State<SignUpScreen> {
  // Form 전체의 상태에 접근하기 위한 Key
  //
  // 나중에
  // _formKey.currentState?.validate()
  // 를 호출하면 Form 안의 TextFormField들을 한꺼번에 검사할 수 있음.
  final _formKey = GlobalKey<FormState>();

  // ---------------------------
  // TextEditingController
  // ---------------------------
  //
  // 각 입력창에 사용자가 입력한 값을 관리함.
  //
  // _nicknameController.text
  // 를 사용하면 현재 닉네임 입력값을 가져올 수 있음.
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ---------------------------
  // FocusNode
  // ---------------------------
  //
  // 어떤 입력창에 커서(Focus)가 있는지 관리함.
  //
  // 나중에 닉네임 입력 후 키보드의 "다음"을 누르면
  // 이메일 입력창으로 Focus를 옮기는 데 사용할 예정.
  final _nicknameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  // 필수 약관 동의 여부
  //
  // 아직 화면에는 Checkbox를 만들지 않지만,
  // 다음 단계에서 사용하기 위해 상태값을 미리 선언해 둠.
  bool _agreedToTerms = false;

  @override
  void dispose() {
    // Controller와 FocusNode는 화면이 사라질 때 반드시 정리해야 함.
    //
    // 그렇지 않으면 사용하지 않는 객체가 메모리에 남을 수 있음.
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    _nicknameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    // 부모 State의 dispose도 마지막에 호출
    super.dispose();
  }

  // ---------------------------
  // 각 입력창의 오류 상태
  // ---------------------------

  // 닉네임이 입력되어 있고,
  // 2글자 미만이면 오류 상태
  bool get _hasNicknameError {
    final nickname = _nicknameController.text.trim();

    return nickname.isNotEmpty && nickname.length < 2;
  }

  // 닉네임이 2자 이상이면 정상
  bool get _isNicknameValid {
    final nickname = _nicknameController.text.trim();

    return nickname.length >= 2;
  }

  // 이메일 형식이 맞으면 정상
  bool get _isEmailValid {
    final email = _emailController.text.trim();

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    return emailRegex.hasMatch(email);
  }

  // 이메일이 입력되어 있지만
  // 이메일 형식이 아니라면 오류 상태
  bool get _hasEmailError {
    final email = _emailController.text.trim();

    // 아직 아무것도 입력하지 않았다면
    // 오류 배경을 보여주지 않음
    if (email.isEmpty) {
      return false;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    return !emailRegex.hasMatch(email);
  }

  // 비밀번호가 입력되어 있지만
  // 8글자 미만이면 오류 상태
  bool get _hasPasswordError {
    final password = _passwordController.text;

    return password.isNotEmpty && password.length < 8;
  }

  // 비밀번호가 8자 이상이면 정상
  bool get _isPasswordValid {
    final password = _passwordController.text;

    return password.length >= 8;
  }

  // 현재 입력값들이 모두 가입 조건을 만족하는지 계산
  bool get _canSubmit {
    // 세 입력창이 모두 유효하고
    // 필수 약관까지 체크했을 때만 true
    return _isNicknameValid &&
        _isEmailValid &&
        _isPasswordValid &&
        _agreedToTerms;
  }

  @override
  Widget build(BuildContext context) {
    // 키보드가 현재 올라와 있는지 확인
    //
    // 키보드가 닫혀 있으면 bottom 값은 보통 0
    // 키보드가 올라오면 키보드 높이만큼 값이 생김
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      // 1주차에 만든 공용 AppBar 재사용
      appBar: CommonAppBar(
        title: '회원가입',

        // Figma처럼 제목을 가운데 정렬
        centerTitle: true,

        // 뒤로가기 버튼
        //
        // onBack에 함수가 들어갔기 때문에
        // CommonAppBar 내부에서 뒤로가기 아이콘이 표시됨.
        onBack: () {
          Navigator.of(context).maybePop();
        },
      ),

      // 상태바, 노치, 하단 시스템 영역 등에
      // 화면 내용이 가려지지 않도록 보호
      body: SafeArea(
        // 회원가입 Form은 키보드가 올라오면
        // 화면 높이가 부족해질 수 있으므로 스크롤 가능하게 만듦.
        child: SingleChildScrollView(
          // 사용자가 화면을 드래그하면 키보드를 닫음.
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

          // 화면 전체 좌우/상하 여백
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),

          // 여러 TextFormField를 하나의 Form으로 묶음
          child: Form(
            key: _formKey,

            child: Column(
              // Column 내부 Widget을 가로 방향으로 늘림.
              //
              // 따라서 TextFormField가 화면 너비를 사용할 수 있음.
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                // ---------------------------
                // 상단 안내 문구
                // ---------------------------

                const SizedBox(height: 16),

                const Text(
                  '환영합니다!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),

                const SizedBox(height: 4),

                Text(
                  '간단한 정보만 입력하고 시작해보세요.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray,
                  ),
                ),

                const SizedBox(height: 40),

                const SizedBox(height: 8),

                // ---------------------------
                // 닉네임 입력창
                // ---------------------------
                MovieLogTextFormField(
                  label: '닉네임',
                  hintText: '닉네임을 입력해주세요',

                  controller: _nicknameController,
                  focusNode: _nicknameFocusNode,

                  // 닉네임의 현재 오류 상태 전달
                  hasError: _hasNicknameError,
                  // 현재 정상 입력 상태
                  isValid: _isNicknameValid,

                  // 키보드 버튼을 "다음"으로 표시
                  textInputAction: TextInputAction.next,

                  // 닉네임 Validator
                  validator: (value) {
                    final nickname = value?.trim() ?? '';

                    if (nickname.isEmpty) {
                      return '닉네임을 입력해주세요.';
                    }

                    if (nickname.length < 2) {
                      return '닉네임은 2자 이상이어야 합니다.';
                    }

                    // null이면 검증 성공
                    return null;
                  },

                  // 입력할 때마다 화면을 다시 그림
                  //
                  // 나중에 가입 버튼 활성화 여부도
                  // 바로 갱신하기 위해 필요함.
                  onChanged: (_) {
                    setState(() {});
                  },

                  // 다음 버튼 → 이메일 입력창으로 이동
                  onFieldSubmitted: (_) {
                    _emailFocusNode.requestFocus();
                  },
                ),
                // 닉네임 입력창과 이메일 영역 사이의 간격
                const SizedBox(height: 16),

                MovieLogTextFormField(
                  label: '이메일',
                  hintText: '이메일 주소를 입력해주세요',

                  controller: _emailController,
                  focusNode: _emailFocusNode,

                  // 이메일 오류 상태 전달
                  hasError: _hasEmailError,

                  isValid: _isEmailValid,

                  // 이메일 입력에 맞는 키보드 사용
                  keyboardType: TextInputType.emailAddress,

                  textInputAction: TextInputAction.next,

                  // 이메일 형식 검사
                  validator: (value) {
                    final email = value?.trim() ?? '';

                    if (email.isEmpty) {
                      return '이메일을 입력해주세요.';
                    }

                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

                    if (!emailRegex.hasMatch(email)) {
                      return '올바른 이메일 형식이 아닙니다.';
                    }

                    return null;
                  },

                  onChanged: (_) {
                    setState(() {});
                  },

                  // 다음 → 비밀번호 입력창
                  onFieldSubmitted: (_) {
                    _passwordFocusNode.requestFocus();
                  },
                ),

                // 이메일 입력창과 비밀번호 영역 사이 간격
                const SizedBox(height: 16),

                MovieLogTextFormField(
                  label: '비밀번호',
                  hintText: '비밀번호를 입력해주세요',

                  controller: _passwordController,
                  focusNode: _passwordFocusNode,

                  // 비밀번호 오류 상태 전달
                  hasError: _hasPasswordError,

                  isValid: _isPasswordValid,

                  // 입력한 비밀번호를 •••• 형태로 가림
                  obscureText: true,

                  // 마지막 입력창이므로 키보드에 완료 표시
                  textInputAction: TextInputAction.done,

                  validator: (value) {
                    final password = value ?? '';

                    if (password.isEmpty) {
                      return '비밀번호를 입력해주세요.';
                    }

                    if (password.length < 8) {
                      return '비밀번호는 8자 이상이어야 합니다.';
                    }

                    return null;
                  },

                  onChanged: (_) {
                    setState(() {});
                  },

                  // 완료를 누르면 키보드 닫기
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).unfocus();
                  },
                ),

                // 키보드가 닫혀 있으면 넉넉하게 띄우고,
                // 키보드가 올라오면 공간을 줄여 스크롤 부담을 줄임.
                SizedBox(height: isKeyboardOpen ? 24 : 120),

                // ---------------------------
                // 필수 약관 동의
                // ---------------------------
                Row(
                  children: [
                    // 체크박스
                    Checkbox(
                      // 현재 체크 상태
                      value: _agreedToTerms,

                      // 사용자가 체크 상태를 바꿨을 때 실행
                      onChanged: (value) {
                        setState(() {
                          // value가 null일 수도 있으므로
                          // null이면 false 사용
                          _agreedToTerms = value ?? false;
                        });
                      },

                      // 체크됐을 때 메인 보라색 사용
                      activeColor: AppColors.violet,
                    ),

                    // Checkbox 오른쪽의 설명 글
                    const Expanded(
                      child: Text(
                        '필수 약관에 동의합니다',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ---------------------------
                // 가입하기 버튼
                // ---------------------------
                ElevatedButton(
                  // _canSubmit이 true일 때만 버튼을 누를 수 있음
                  //
                  // false라면 onPressed가 null이 되기 때문에
                  // Flutter에서 버튼을 비활성 상태로 처리함.
                  onPressed: _canSubmit
                      ? () {
                          // Form 안의 모든 TextFormField Validator를
                          // 다시 한 번 실행함.
                          final isValid =
                              _formKey.currentState?.validate() ?? false;

                          // 하나라도 검증 실패하면 여기서 종료
                          if (!isValid) {
                            return;
                          }

                          // 모든 입력값이 정상이라면
                          // 입력창 Focus를 제거하고 키보드 닫기
                          FocusScope.of(context).unfocus();
                        }
                      : null,

                  style: ElevatedButton.styleFrom(
                    // 활성 상태의 배경색
                    backgroundColor: AppColors.violet,

                    // 비활성 상태의 배경색
                    disabledBackgroundColor: AppColors.lightViolet,

                    // 활성 상태 글자색
                    foregroundColor: AppColors.white,

                    // 비활성 상태에서도 글자는 흰색
                    disabledForegroundColor: AppColors.white,

                    // 버튼을 가로로 꽉 채우고 높이를 일정하게 만듦
                    minimumSize: const Size.fromHeight(52),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  child: const Text(
                    '가입하기',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 24),

                // ---------------------------
                // 로그인 안내
                // ---------------------------
                Row(
                  // Row 안의 내용을 화면 가운데 배치
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Text(
                      '이미 계정이 있나요? ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.gray,
                      ),
                    ),

                    // 아직 실제 로그인 화면 이동은 구현하지 않으므로
                    // Text만 표시
                    Text(
                      '로그인',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.violet,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
