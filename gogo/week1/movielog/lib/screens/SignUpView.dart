import 'package:flutter/material.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();

  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isTermsAgreed = false;

  final _emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _updateState() {
    setState(() {});
  }

  bool get _isFormValid {
    return _nicknameController.text.length >= 2 &&
        _emailRegex.hasMatch(_emailController.text) &&
        _passwordController.text.length >= 8 &&
        _isTermsAgreed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {},
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(
            color: Color(0xFF6B4EFF),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '환영합니다!\n간단한 정보만 입력하고 시작해보세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                ),
                const SizedBox(height: 40),

                // 1. 닉네임 영역
                const SectionLabel(text: '닉네임'),
                CustomInputField(
                  controller: _nicknameController,
                  hintText: '닉네임을 입력해주세요',
                  textInputAction: TextInputAction.next,
                  onChanged: (value) => _updateState(),
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocusNode),
                  isValid: _nicknameController.text.length >= 2,
                  isError: _nicknameController.text.isNotEmpty && _nicknameController.text.length < 2,
                  // 🚨 추가된 실시간 에러 문구
                  errorText: '닉네임은 2자 이상이어야 합니다.',
                  validator: (value) {
                    if (value == null || value.isEmpty) return '닉네임을 입력해주세요.';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 2. 이메일 영역
                const SectionLabel(text: '이메일'),
                CustomInputField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  hintText: '이메일 주소를 입력해주세요',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: (value) => _updateState(),
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
                  isValid: _emailRegex.hasMatch(_emailController.text),
                  isError: _emailController.text.isNotEmpty && !_emailRegex.hasMatch(_emailController.text),
                  // 🚨 추가된 실시간 에러 문구
                  errorText: '올바른 이메일 형식이 아닙니다.',
                  validator: (value) {
                    if (value == null || value.isEmpty) return '이메일을 입력해주세요.';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 3. 비밀번호 영역
                const SectionLabel(text: '비밀번호'),
                CustomInputField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  hintText: '비밀번호를 입력해주세요',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onChanged: (value) => _updateState(),
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                  isValid: _passwordController.text.length >= 8,
                  isError: _passwordController.text.isNotEmpty && _passwordController.text.length < 8,
                  // 🚨 추가된 실시간 에러 문구
                  errorText: '비밀번호는 8자 이상이어야 합니다.',
                  validator: (value) {
                    if (value == null || value.isEmpty) return '비밀번호를 입력해주세요.';
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // 4. 필수 약관 동의
                TermsCheckbox(
                  isAgreed: _isTermsAgreed,
                  onChanged: (value) {
                    setState(() {
                      _isTermsAgreed = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // 5. 가입하기 버튼
                ElevatedButton(
                  onPressed: _isFormValid
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('회원가입이 완료되었습니다!')),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4EFF),
                    disabledBackgroundColor: const Color(0xFFCFC4FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '가입하기',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }
}

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;
  final bool isValid;
  final bool isError;
  final String? errorText; // 🚨 추가됨: 외부에서 에러 문구를 주입받을 수 있도록 추가

  const CustomInputField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    required this.isValid,
    required this.isError,
    this.errorText, // 🚨 추가됨
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black38),
        filled: true,
        fillColor: isError ? const Color(0xFFFFF0F0) : const Color(0xFFF5F5F5),
        suffixIcon: isValid
            ? const Icon(Icons.check_circle, color: Color(0xFF6B4EFF))
            : (isError ? const Icon(Icons.error_outline, color: Color(0xFFD32F2F)) : null),
        
        // 🚨 실시간 에러 문구 표시 로직 추가 (isError가 true일 때만 errorText 표시)
        errorText: isError ? errorText : null,
        // 피그마와 일치하는 빨간색 적용
        errorStyle: const TextStyle(color: Color(0xFFD32F2F), fontSize: 12),
        
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: isError ? const BorderSide(color: Color(0xFFD32F2F)) : const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isError ? const Color(0xFFD32F2F) : const Color(0xFF6B4EFF), width: 1.5),
        ),
      ),
    );
  }
}

class TermsCheckbox extends StatelessWidget {
  final bool isAgreed;
  final ValueChanged<bool?> onChanged;

  const TermsCheckbox({
    super.key,
    required this.isAgreed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: isAgreed,
            onChanged: onChanged,
            activeColor: const Color(0xFF6B4EFF),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: const BorderSide(color: Colors.black38, width: 1.5),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          '필수 약관에 동의합니다',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
        ),
      ],
    );
  }
}
