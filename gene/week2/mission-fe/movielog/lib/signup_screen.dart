import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const _background = Color(0xFFFAF9F5);
  static const _primary = Color(0xFF6750A4);
  static const _disabledButton = Color(0xFFCCC2DC);
  static const _fieldFill = Color(0xFFF5F3F0);
  static const _fieldBorder = Color(0xFFCBC4D2);
  static const _hint = Color(0xFF7A7582);
  static const _textPrimary = Color(0xFF1D1B20);
  static const _textSecondary = Color(0xFF494551);
  static const _error = Color(0xFFB3261E);
  static const _errorFill = Color(0xFFFFDAD6);

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

  bool get _canSubmit =>
      _nicknameController.text.isNotEmpty &&
      _emailController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _nicknameError == null &&
      _emailError == null &&
      _passwordError == null &&
      _agreed;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 64,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textPrimary),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(
            color: _primary,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
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
                        color: _textSecondary,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildField(
                    label: '닉네임',
                    hint: '닉네임을 입력해주세요',
                    controller: _nicknameController,
                    errorText: _nicknameError,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: '이메일',
                    hint: '이메일 주소를 입력해주세요',
                    controller: _emailController,
                    errorText: _emailError,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: '비밀번호',
                    hint: '비밀번호를 입력해주세요',
                    controller: _passwordController,
                    errorText: _passwordError,
                    obscureText: true,
                  ),
                  const SizedBox(height: 146),
                  _buildTermsCheckbox(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                  const SizedBox(height: 24),
                  _buildLoginLink(),
                ],
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
  }) {
    final hasError = errorText != null;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: hasError ? _error : _fieldBorder),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: _textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _hint, fontSize: 16),
            filled: true,
            fillColor: hasError ? _errorFill : _fieldFill,
            suffixIcon: hasError
                ? const Icon(Icons.error_outline, color: _error, size: 20)
                : controller.text.isNotEmpty
                ? const Icon(Icons.check_circle, color: _primary, size: 20)
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 17,
              vertical: 10,
            ),
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(color: hasError ? _error : _primary),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                color: _error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 16 / 12,
              ),
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
              activeColor: _primary,
              checkColor: Colors.white,
              side: const BorderSide(color: _primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            '필수 약관에 동의합니다',
            style: TextStyle(color: _textPrimary, fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _canSubmit ? () => debugPrint('가입하기 버튼을 눌렀습니다.') : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _disabledButton,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('가입하기', style: TextStyle(fontSize: 16, height: 1.5)),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '이미 계정이 있나요? ',
          style: TextStyle(color: _textSecondary, fontSize: 16, height: 1.5),
        ),
        GestureDetector(
          onTap: () => debugPrint('로그인 링크를 눌렀습니다.'),
          child: const Text(
            '로그인',
            style: TextStyle(color: _primary, fontSize: 16, height: 1.5),
          ),
        ),
      ],
    );
  }
}
