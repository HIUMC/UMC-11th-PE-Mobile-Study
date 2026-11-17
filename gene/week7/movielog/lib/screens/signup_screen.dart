import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:movielog/data/models/create_member_request.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/view_models/learning_member_session.dart';
import 'package:movielog/view_models/sign_up_view_models.dart';
import 'package:movielog/widgets/movielog_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreed = true;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  // 입력값이 있는데 조건을 만족하지 못하면 에러 문구, 아니면 null
  String? get _nicknameError {
    final text = _nicknameController.text;
    if (text.isEmpty || text.length >= 2) return null;
    return '닉네임은 2자 이상이어야 합니다.';
  }

  String? get _emailError {
    final text = _emailController.text;
    if (text.isEmpty || _emailRegex.hasMatch(text)) return null;
    return '올바른 이메일 형식이 아닙니다.';
  }

  String? get _passwordError {
    final text = _passwordController.text;
    if (text.isEmpty || text.length >= 8) return null;
    return '비밀번호는 8자 이상이어야 합니다.';
  }

  /// 형식 검사를 통과한 닉네임·이메일만 서버에 중복 확인을 요청합니다.
  bool get _isNicknameValid =>
      _nicknameController.text.isNotEmpty && _nicknameError == null;

  bool get _isEmailValid =>
      _emailController.text.isNotEmpty && _emailError == null;

  bool _canSubmit(SignUpViewModel viewModel) =>
      !viewModel.isSubmitting &&
      viewModel.nickname.isAvailable &&
      viewModel.email.isAvailable &&
      _nicknameController.text.isNotEmpty &&
      _emailController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _nicknameError == null &&
      _emailError == null &&
      _passwordError == null &&
      _agreed;

  Future<void> _onSubmitPressed() async {
    final viewModel = context.read<SignUpViewModel>();
    if (!_canSubmit(viewModel)) return;

    await viewModel.submit(
      CreateMemberRequest(
        email: _emailController.text,
        password: _passwordController.text,
        nickname: _nicknameController.text,
      ),
    );
    if (!mounted) return;

    final memberId = viewModel.createdMemberId;
    if (viewModel.submitStatus == SubmitStatus.success && memberId != null) {
      debugPrint('[회원가입 성공] memberId: $memberId');
      context.read<LearningMemberSession>().setMemberId(memberId);
      context.go('/movies');
      return;
    }
    if (viewModel.snackbarMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(viewModel.snackbarMessage!)));
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignUpViewModel>();

    return PopScope(
      // 가입 요청 중에는 뒤로가기로 화면을 벗어나지 못하게 막습니다.
      canPop: !viewModel.isSubmitting,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 64,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: const Text(
            '회원가입',
            style: TextStyle(
              fontFamily: 'Manrope',
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.w500,
              height: 28 / 22,
              letterSpacing: 0,
            ),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 448,
                    minHeight: constraints.maxHeight - 48,
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          '환영합니다!\n간단한 정보만 입력하고 시작해보세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildCheckField(
                        viewModel: viewModel,
                        state: viewModel.nickname,
                        label: '닉네임',
                        hint: '닉네임을 입력해주세요',
                        controller: _nicknameController,
                        formatError: _nicknameError,
                        isFormatValid: _isNicknameValid,
                        onChanged: viewModel.onNicknameChanged,
                        onCheck: viewModel.checkNickname,
                      ),
                      const SizedBox(height: 16),
                      _buildCheckField(
                        viewModel: viewModel,
                        state: viewModel.email,
                        label: '이메일',
                        hint: '이메일 주소를 입력해주세요',
                        controller: _emailController,
                        formatError: _emailError,
                        isFormatValid: _isEmailValid,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: viewModel.onEmailChanged,
                        onCheck: viewModel.checkEmail,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: '비밀번호',
                        hint: '비밀번호를 입력해주세요',
                        controller: _passwordController,
                        // 형식 오류가 먼저, 그다음 서버가 보낸 비밀번호 오류를 보여줍니다.
                        errorText:
                            _passwordError ?? viewModel.passwordErrorText,
                        obscureText: true,
                        onChanged: (_) => viewModel.onPasswordChanged(),
                      ),
                      const SizedBox(height: 146),
                      _buildTermsCheckbox(),
                      const SizedBox(height: 24),
                      _buildSubmitButton(viewModel),
                      const SizedBox(height: 24),
                      _buildLoginLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? errorText,
    TextInputType? keyboardType,
    bool obscureText = false,
    ValueChanged<String>? onChanged,
  }) {
    final hasError = errorText != null;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: hasError ? AppColors.error : AppColors.fieldBorder,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: (value) {
            setState(() {});
            onChanged?.call(value);
          },
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.hint, fontSize: 16),
            filled: true,
            fillColor: hasError
                ? AppColors.errorContainer
                : AppColors.fieldFill,
            suffixIcon: hasError
                ? const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 20,
                  )
                : controller.text.isNotEmpty
                ? const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 20,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 17,
              vertical: 10,
            ),
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 16 / 12,
              ),
            ),
          ),
      ],
    );
  }

  /// 입력칸 + "중복 확인" 버튼 한 줄입니다. 닉네임·이메일에 함께 씁니다.
  Widget _buildCheckField({
    required SignUpViewModel viewModel,
    required DuplicateCheckState state,
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? formatError,
    required bool isFormatValid,
    required ValueChanged<String> onChanged,
    required Future<void> Function(String) onCheck,
    TextInputType? keyboardType,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildField(
            label: label,
            hint: hint,
            controller: controller,
            // 형식 오류가 먼저, 그다음 서버 중복 확인 결과를 보여줍니다.
            errorText: formatError ?? state.errorText,
            keyboardType: keyboardType,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          // 라벨(24) + 간격(4)만큼 내려 입력창과 높이를 맞춥니다.
          padding: const EdgeInsets.only(top: 28),
          child: MovieLogButton(
            label: state.isAvailable ? '확인 완료' : '중복 확인',
            isLoading: state.status == CheckStatus.checking,
            onPressed:
                state.canCheck &&
                    !state.isAvailable &&
                    isFormatValid &&
                    !viewModel.isSubmitting
                ? () => onCheck(controller.text)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _agreed = !_agreed),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            height: 26,
            child: Checkbox(
              value: _agreed,
              onChanged: (value) => setState(() => _agreed = value ?? false),
              activeColor: AppColors.primary,
              checkColor: AppColors.white,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            '필수 약관에 동의합니다',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(SignUpViewModel viewModel) {
    return MovieLogButton(
      label: '가입하기',
      width: double.infinity,
      isLoading: viewModel.isSubmitting,
      onPressed: _canSubmit(viewModel) ? _onSubmitPressed : null,
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '이미 계정이 있나요? ',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        GestureDetector(
          onTap: () => debugPrint('로그인 링크를 눌렀습니다.'),
          child: const Text(
            '로그인',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
