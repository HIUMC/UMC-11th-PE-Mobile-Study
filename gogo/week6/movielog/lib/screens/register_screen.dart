import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../view_models/sign_up_view_model.dart';
import '../widgets/movielog_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  bool _agreed = false;
  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Widget _checkedField(SignUpViewModel vm, CheckField kind, String label) {
    final state = vm.field(kind);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                key: ValueKey(kind.name),
                keyboardType: kind == CheckField.email
                    ? TextInputType.emailAddress
                    : TextInputType.text,
                autocorrect: false,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) => vm.changed(kind, value),
                validator: (value) =>
                    SignUpViewModel.validate(kind, value ?? '') ??
                    state.errorText,
                decoration: InputDecoration(
                  hintText: '$label 입력',
                  errorText: state.errorText,
                  errorMaxLines: 3,
                  suffixIcon: state.status == CheckStatus.available
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            MovieLogButton(
              key: ValueKey('${kind.name}-check'),
              label: '중복 확인',
              isLoading: state.status == CheckStatus.checking,
              onPressed: vm.canCheck(kind) ? () => vm.check(kind) : null,
            ),
          ],
        ),
        if (state.status == CheckStatus.available)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '사용할 수 있는 $label입니다.',
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Consumer<SignUpViewModel>(
    builder: (context, vm, _) {
      final canSubmit =
          vm.bothAvailable && _password.text.length >= 8 && _agreed;
      return Scaffold(
        appBar: AppBar(title: const Text('회원가입'), centerTitle: true),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '환영합니다!\n간단한 정보만 입력하고 시작해보세요.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _checkedField(vm, CheckField.nickname, '닉네임'),
                  const SizedBox(height: 24),
                  _checkedField(vm, CheckField.email, '이메일'),
                  const SizedBox(height: 24),
                  const Text('비밀번호'),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: const ValueKey('password'),
                    controller: _password,
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (_) => setState(() {}),
                    validator: (value) => (value?.length ?? 0) >= 8
                        ? null
                        : '비밀번호는 8자 이상이어야 합니다.',
                    decoration: const InputDecoration(hintText: '비밀번호를 입력해주세요'),
                  ),
                  const SizedBox(height: 48),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text('필수 약관에 동의합니다'),
                    value: _agreed,
                    onChanged: (value) =>
                        setState(() => _agreed = value ?? false),
                  ),
                  const SizedBox(height: 16),
                  MovieLogButton(
                    label: '가입하기',
                    width: double.infinity,
                    onPressed: canSubmit
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              context.go('/home');
                            }
                          }
                        : null,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '6주차에서는 계정을 생성하지 않고 홈 화면으로 이동합니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
