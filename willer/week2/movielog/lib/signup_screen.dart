import 'package:flutter/material.dart'; // Scaffold, TextFormField, Checkbox 등 Material 위젯 사용

import 'theme/app_colors.dart'; // 상태 아이콘(체크/오류) 색 지정에 사용
import 'theme/app_text_styles.dart'; // 라벨, 안내 문구, 링크 텍스트 스타일

// 사용자가 입력할 때마다 화면이 바뀌어야 하므로 StatefulWidget을 쓴다.
// 1주차 프로필 화면은 값이 고정이라 StatelessWidget이었다.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key}); // const는 이 위젯이 만들어질 때 바뀔 게 없다는 뜻. Flutter가 재사용해서 성능이 좋아짐

  // StatefulWidget은 껍데기일 뿐이고 실제 내용은 State에 있다.
  // 화면을 다시 그릴 때 위젯 객체는 새로 만들어지지만 State는 그대로 살아남기 때문에, 입력값처럼 유지되어야 하는 것들을 State에 둔다.
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> { // 앞의 _는 이 파일 밖에서 접근 불가
  // Form 위젯에 말을 걸기 위한 손잡이(통로 역할)다
  // formKey.currentState?.validate()로 Form 안의 모든 validator를 한 번에 실행할 수 있다.
  // build 안에서 만들면 화면이 다시 그려질 때마다 새 key가 생겨 Form 상태가 날아간다.
  final formKey = GlobalKey<FormState>();

  // 입력창의 값을 읽고 쓰는 통로. 입력창 3개라 Controller도 3개.
  // final은 이 객체를 다른 객체로 교체하지 않는다는 뜻이고, 안의 text 값은 계속 바뀐다.
  final nicknameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // 포커스(커서)를 코드에서 옮기기 위한 객체.
  // 입력창은 3개인데 2개만 만든 이유는 포커스를 '받는' 쪽에만 필요하기 때문이다.
  // 닉네임 → 이메일 → 비밀번호 순서로 넘어가므로 닉네임은 받을 일이 없다.
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  // 약관 동의 체크박스 상태. 값 자체를 true/false로 바꿔야 해서 final이 아니다.
  bool agreedToTerms = false;

  // Controller와 FocusNode는 화면이 사라져도 자동으로 정리되지 않는다.
  // 직접 해제하지 않으면 메모리에 계속 남아 누수가 생긴다.
  // super.dispose()는 반드시 맨 마지막에 호출한다. 먼저 부르면 이미 정리된 State를 만지는 꼴이 된다.
  @override
  void dispose() {
    nicknameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  // validator의 규칙: null을 반환하면 통과, 문자열을 반환하면 그 문장이 오류 메시지로 표시된다.
  // "문제가 없으면 할 말이 없다"고 생각하면 이해하기 쉽다.
  //
  // TextFormField 안에 직접 쓰지 않고 별도 메서드로 뺀 이유는
  // 같은 규칙을 validator 자리, 버튼 활성화 조건, 상태 아이콘 판정
  // 세 곳에서 쓰기 때문이다. 복사해두면 나중에 규칙을 바꿀 때 어긋날 수 있다.
  String? validateNickname(String? value) { // String?의 ?는 null일 수 있다는 뜻
    // value?.trim()은 value가 null이 아니면 앞뒤 공백 제거, null이면 그대로 null.
    // ?? ''는 그 결과가 null이면 빈 문자열로 바꾼다.
    // 두 단계를 거치면 nickname은 항상 문자열이라 이후에 null 걱정 없이 쓸 수 있다.
    final nickname = value?.trim() ?? '';

    // 빈 값 검사를 길이 검사보다 먼저 한다.
    // 순서를 바꾸면 아무것도 입력하지 않았을 때도 "2자 이상"이라는 엉뚱한 메시지가 나온다.
    if (nickname.isEmpty) {
      return '닉네임을 입력해주세요.';
    }

    if (nickname.length < 2) {
      return '닉네임은 2자 이상이어야 합니다.';
    }

    return null; // 여기까지 오면 통과
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return '이메일을 입력해주세요.';
    }

    // @와 . 존재 여부만 확인하는 단순한 검사.
    // 정규식으로 더 엄격하게 할 수도 있지만 워크북 예제 수준에 맞췄다.
    // 피그마 오류 화면의 "test@"도 .이 없어서 이 조건에 걸린다.
    if (!email.contains('@') || !email.contains('.')) {
      return '올바른 이메일 형식이 아닙니다.';
    }

    return null;
  }

  String? validatePassword(String? value) {
    // 닉네임·이메일과 달리 trim()을 쓰지 않았다.
    // 비밀번호는 공백도 유효한 문자라서 우리가 임의로 잘라내면
    // 사용자가 설정한 값과 달라진다.
    final password = value ?? '';

    if (password.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }

    if (password.length < 8) {
      return '비밀번호는 8자 이상이어야 합니다.';
    }

    return null;
  }

  // get을 붙이면 변수처럼 읽히지만 읽을 때마다 새로 계산된다(getter).
  // 입력값이 계속 바뀌므로 그때그때 최신 상태를 반영해야 해서 변수가 아닌 getter로 만들었다.
  // =>는 { return ...; }의 줄임말이다.
  //
  // 조건을 직접 쓰지 않고 validator를 재사용한 덕분에
  // 검증 규칙이 한 곳에만 존재하게 되었다.
  bool get canSubmit =>
      validateNickname(nicknameController.text) == null && // null이면 통과했다는 뜻
      validateEmail(emailController.text) == null &&
      validatePassword(passwordController.text) == null &&
      agreedToTerms; // 약관까지 동의해야 true

  // 가입 버튼을 눌렀을 때 실행된다.
  void onSubmit() {
    // Form 안의 모든 TextFormField의 validator를 한 번에 실행한다.
    // Form이 아직 그려지지 않았으면 currentState가 null일 수 있어 ?.와 ?? false로 처리했다.
    //
    // canSubmit이 이미 true라 버튼이 눌린 건데 왜 또 검사하는가:
    // canSubmit은 매 입력마다 도는 가벼운 예비 검사이고,
    // validate()는 제출 시점의 최종 검사이면서 오류 메시지를 화면에 띄우는 역할까지 한다.
    final isValid = formKey.currentState?.validate() ?? false;

    if (!isValid) return; // 유효하지 않으면 여기서 함수 종료(early return)

    // 화면 전체의 포커스를 해제해 키보드를 내린다.
    // 개별 FocusNode의 unfocus()는 그 칸만 해제하지만 이건 화면 전체에 적용된다.
    FocusScope.of(context).unfocus();

    // 이번 주차는 API 연결 범위가 아니라 실제 가입 처리는 하지 않는다.
  }

  // 현재 상태에 맞는 화면을 만들어 반환한다.
  // setState가 호출될 때마다 다시 실행되므로 무거운 작업을 넣으면 안 된다.
  @override
  Widget build(BuildContext context) { // context는 이 위젯이 트리의 어디에 있는지 담은 객체
    return Scaffold( // 앱 화면의 기본 틀. 배경색은 AppTheme의 scaffoldBackgroundColor를 따른다
      appBar: AppBar(
        leading: IconButton( // leading은 AppBar의 왼쪽 자리
          icon: const Icon(Icons.arrow_back),
          // 이전 화면이 없는 상태라 Navigator.pop()을 호출하면 에러가 난다.
          // 화면 전환은 이번 주차 범위가 아니므로 자리만 만들어두었다.
          onPressed: () {},
        ),
        title: const Text('회원가입', style: AppTextStyles.appBarTitle),
        centerTitle: true, // AppTheme에는 false로 두었지만 이 화면만 가운데 정렬로 덮어쓴다
      ),
      body: SafeArea( // 노치와 하단 제스처 바를 피해 여백을 자동으로 만들어준다
        // Column은 스크롤 기능이 없어 내용이 화면보다 길어지면 잘리거나 overflow가 난다.
        // 특히 키보드가 올라오면 쓸 수 있는 세로 공간이 줄어들어 반드시 필요하다.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24), // 사방 안쪽 여백. 글자가 화면 가장자리에 붙지 않게
          // 화면을 드래그해서 스크롤할 때 키보드가 자동으로 내려간다.
          // 폼이 길 때 키보드를 따로 닫지 않아도 되어 편하다.
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form( // 입력창들을 묶어 한 번에 검증할 수 있게 해준다
            key: formKey, // 위에서 만든 GlobalKey를 연결
            child: Column(
              // Column은 세로로 쌓으므로 가로가 cross axis다.
              // stretch를 주면 자식들이 가로로 꽉 차서 입력창과 버튼이 화면 너비에 맞춰 늘어난다.
              // 너비를 숫자로 박지 않았기 때문에 화면 크기가 달라도 자동으로 대응된다.
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SignUpHeader(), // "환영합니다!" + 안내 문구. 아래에서 따로 정의
                const SizedBox(height: 36), // 순수한 빈 공간. 여백을 만들 때 쓴다
                LabeledTextField( // 라벨 + 입력창 한 세트. 아래에서 따로 정의
                  label: '닉네임',
                  hintText: '닉네임을 입력해주세요',
                  controller: nicknameController,
                  validate: validateNickname, // 함수 자체를 넘긴다(괄호 없음)
                  textInputAction: TextInputAction.next, // 키보드 오른쪽 아래를 "다음"으로
                  // Controller와 입력창은 자동으로 동기화되지만
                  // 그 값에 따라 버튼 색까지 바뀌게 하려면 다시 그리라는 신호가 필요하다.
                  // 바꿀 값이 없어 괄호 안이 비어 있고, (_)는 매개변수를 쓰지 않는다는 표시다.
                  onChanged: (_) => setState(() {}),
                  // "다음"을 눌렀을 때 이메일 칸으로 커서를 옮긴다.
                  onFieldSubmitted: (_) => emailFocusNode.requestFocus(),
                  // 닉네임은 포커스를 받을 일이 없어 focusNode를 넘기지 않았다.
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: '이메일',
                  hintText: '이메일 주소를 입력해주세요',
                  controller: emailController,
                  focusNode: emailFocusNode, // 닉네임에서 넘어온 포커스를 받는다
                  validate: validateEmail,
                  keyboardType: TextInputType.emailAddress, // @와 .이 있는 키보드가 뜬다
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: '비밀번호',
                  hintText: '비밀번호를 입력해주세요',
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  validate: validatePassword,
                  obscureText: true, // 입력한 글자를 점으로 가린다
                  textInputAction: TextInputAction.done, // 마지막 칸이라 "완료"
                  onChanged: (_) => setState(() {}),
                  // 마지막 입력창이라 넘어갈 곳이 없어 onFieldSubmitted를 달지 않았다.
                ),
                const SizedBox(height: 32),
                TermsCheckbox( // 체크박스 + 문구. 아래에서 따로 정의
                  value: agreedToTerms, // 현재 상태를 넘겨준다
                  onChanged: (value) { // 사용자가 누르면 실행된다
                    setState(() {
                      // Checkbox는 3상태(체크/해제/미정)를 지원해 value가 null일 수 있다.
                      // ??는 왼쪽이 null이면 오른쪽 값을 쓰라는 뜻이다.
                      agreedToTerms = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  // onPressed가 null이면 Flutter가 자동으로 버튼을 비활성화한다.
                  // 색도 흐려지고 눌러도 반응하지 않는다. 별도의 enabled 속성은 없다.
                  //
                  // onSubmit에 괄호를 붙이지 않은 것이 중요하다.
                  // 괄호를 붙이면 지금 실행해서 결과를 넘기는 것이 되고,
                  // 괄호가 없어야 "눌렀을 때 실행할 함수"를 넘기는 것이 된다.
                  onPressed: canSubmit ? onSubmit : null,
                  child: const Text('가입하기'),
                ),
                const SizedBox(height: 20),
                LoginPrompt(onPressed: () {}), // 하단 링크. 로그인 화면이 없어 비워두었다
              ],
            ),
          ),
        ),
      ),
    );
  }
} // _SignUpScreenState 끝

// 상단 "환영합니다!" 안내 문구.
// 상태를 갖지 않고 고정된 내용만 그리므로 StatelessWidget이다.
class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column( // 내용이 전부 고정이라 Column 자체에 const를 붙일 수 있다
      children: [
        SizedBox(height: 8),
        Text(
          '환영합니다!',
          style: AppTextStyles.titleMedium,
          // 부모 Column이 stretch라 Text가 가로로 늘어나는데,
          // 그 안에서 글자를 가운데로 모으려면 textAlign이 필요하다.
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6),
        Text(
          '간단한 정보만 입력하고 시작해보세요.',
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// 라벨 + 간격 + 입력창을 한 세트로 묶은 위젯.
// 같은 구조가 세 번 반복되므로 하나로 만들어 재사용했다.
// 1주차에 StatItem을 만들어 세 번 쓴 것과 같은 방식이다.
class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    // required는 반드시 넘겨야 한다는 뜻. 없으면 컴파일 에러가 난다.
    // 이 네 가지는 없으면 입력창이 성립하지 않는다.
    required this.label,
    required this.hintText,
    required this.controller,
    required this.validate,
    // required가 없으면 선택 항목이다. 안 넘기면 null이 들어간다.
    this.focusNode, // 닉네임처럼 포커스를 받지 않는 칸은 넘기지 않는다
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false, // 기본값을 두어 비밀번호만 true를 넘기면 되게 했다
    this.onChanged,
    this.onFieldSubmitted,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  // "String?를 받아서 String?를 돌려주는 함수"라는 뜻.
  // 값이 아니라 함수 자체를 매개변수로 받는다.
  // 입력창마다 검사 규칙이 다르므로 그 차이를 함수로 받아서 처리한다.
  final String? Function(String?) validate;
  final FocusNode? focusNode; // ?가 붙어 null일 수 있다
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText; // 기본값이 있어서 ?가 없다
  final ValueChanged<String>? onChanged; // void Function(String)의 별칭
  final ValueChanged<String>? onFieldSubmitted;

  // 입력창 오른쪽에 붙는 상태 아이콘을 만든다.
  // 세 가지 경우로 나뉜다.
  Widget? buildStatusIcon() {
    if (controller.text.isEmpty) return null; // 빈 값이면 아이콘을 표시하지 않는다

    // 위에서 받은 validate 함수를 그대로 실행한다.
    // null이 아니면 오류 메시지가 있다는 뜻이므로 검증에 실패한 것이다.
    final hasError = validate(controller.text) != null;

    return Icon(
      hasError ? Icons.error_outline : Icons.check_circle,
      color: hasError ? AppColors.error : AppColors.violet,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // 입력창이 가로로 꽉 차게
      children: [
        Text(label, style: AppTextStyles.label), // 입력창 바깥 위에 붙는 라벨
        const SizedBox(height: 8),
        TextFormField( // TextField가 아니라 TextFormField여야 Form과 연결되고 validator가 동작한다
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration( // 테두리·배경·여백은 AppTheme에서 이미 정의했다
            hintText: hintText,
            suffixIcon: buildStatusIcon(), // 입력창 오른쪽 아이콘. null이면 표시되지 않는다
          ),
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          // 사용자가 이 칸을 한 번이라도 건드린 뒤부터 자동으로 검증한다.
          // 화면을 열자마자 오류가 도배되는 것을 막아준다.
          //
          // 처음에는 Form에 지정했는데, 그러면 "Form이 상호작용했는가"를 기준으로 판단해서
          // 한 칸만 입력해도 모든 입력창의 validator가 함께 실행되는 문제가 있었다.
          // 각 TextFormField로 옮겨 각자가 자신의 상태를 판단하게 했다.
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validate, // 부모에게서 받은 검증 함수를 그대로 연결
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
        ),
      ],
    );
  }
}

// 약관 동의 체크박스와 문구.
// 자신의 상태를 갖지 않고 부모에게 value를 받아서 그리고,
// 사용자가 누르면 onChanged로 부모에게 알리기만 한다.
// 실제 agreedToTerms 값은 부모인 _SignUpScreenState가 들고 있다.
//
// 버튼 활성화 조건이 체크박스 값을 알아야 하기 때문에
// 여러 곳에서 필요한 값은 공통 부모가 관리한다.
class TermsCheckbox extends StatelessWidget {
  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool?> onChanged; // Checkbox가 null을 줄 수 있어 bool?이다

  @override
  Widget build(BuildContext context) {
    // Checkbox 혼자서는 옆에 문구를 붙일 수 없어 Row로 감쌌다.
    // 부모 Column이 stretch라 Row가 가로로 늘어나지만,
    // Row 안의 자식들은 왼쪽부터 차례로 붙는다.
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged), // 색과 모양은 AppTheme의 checkboxTheme을 따른다
        const Text('필수 약관에 동의합니다', style: AppTextStyles.bodyMedium),
      ],
    );
  }
}

// 하단 "이미 계정이 있나요? 로그인" 영역.
class LoginPrompt extends StatelessWidget {
  const LoginPrompt({super.key, required this.onPressed});

  final VoidCallback onPressed; // void Function()의 별칭. 매개변수도 반환값도 없는 함수

  @override
  Widget build(BuildContext context) {
    return Row(
      // 부모 Column이 stretch라 Row가 가로로 늘어나는데,
      // 그 안에서 자식들을 가운데로 모은다.
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('이미 계정이 있나요?', style: AppTextStyles.bodySmall),
        // 그냥 Text로 두면 클릭이 되지 않아 TextButton으로 감쌌다.
        // 나중에 로그인 화면으로 이동할 자리다.
        TextButton(
          onPressed: onPressed,
          child: const Text('로그인', style: AppTextStyles.linkText),
        ),
      ],
    );
  }
}