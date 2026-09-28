import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart'; 

// [StatefulWidget] 화면 내에서 사용자의 입력이나 체크박스 클릭 등 상태가 계속 변할 때 사용
// 위젯이 다시 그려져야 하는(동적인) 데이터가 있을 때 필수적인 뼈대입니다.
class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  // [GlobalKey<FormState>] 폼(Form) 내부의 여러 텍스트 필드들을 한 번에 관리하는 '마스터 키'
  // 나중에 이 키를 통해 전체 유효성 검사를 실행하거나 모든 입력값을 초기화
  final _formKey = GlobalKey<FormState>();

  // [TextEditingController] 텍스트 필드에 입력된 글자를 실시간으로 읽어오거나 변경할 때 사용하는 조종기
  // 닉네임, 이메일, 비밀번호 각각의 입력값을 추적하기 위해 3개를 생성
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // [FocusNode] 특정 텍스트 필드를 클릭했을 때 커서가 깜빡이게(포커스) 하거나, 다음 칸으로 넘길 때 사용
  // 이메일에서 키보드 '다음'을 누르면 비밀번호로 커서를 넘겨주기 위해 선언
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isTermsAgreed = false;

  // [RegExp (정규표현식)] 입력된 문자열이 이메일 형식(xxx@xxx.xxx)에 맞는지 검사
  // 앱이 실행될 때 한 번만 메모리에 올리도록 final로 선언
  final _emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  // [dispose()] 화면이 완전히 닫힐 때 컨트롤러와 포커스 노드가 차지하던 메모리를 해제하는 함수.
  // 이 작업을 생략하면 화면을 껐다 켤 때마다 불필요한 데이터가 쌓이는 '메모리 누수'가 발생
  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // [setState] 변수의 값이 바뀌었으니 화면을 최신 상태로 다시 그리라고 플러터 엔진에 알려주는 함수
  // 사용자가 글자를 입력할 때마다 실시간으로 에러 문구나 버튼 활성화 여부를 갱신하기 위해 호출
  void _updateState() {
    setState(() {});
  }

  // [Getter (get)] 함수처럼 생겼지만 변수처럼 사용할 수 있는 읽기 전용 속성
  // 모든 조건(닉네임 길이, 이메일 형식, 비밀번호 길이, 약관 동의)이 참(true)일 때만 true를 반환하여 버튼을 활성화
  bool get _isFormValid {
    return _nicknameController.text.length >= 2 &&
        _emailRegex.hasMatch(_emailController.text) &&
        _passwordController.text.length >= 8 &&
        _isTermsAgreed;
  }

  @override
  Widget build(BuildContext context) {
    // [Scaffold] 앱 화면의 기본 뼈대(앱바, 바디, 하단바 등)를 구성하는 도화지 역할
    // 여기에 배경색, AppBar 등 화면의 가장 기본적인 레이아웃을 설정
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), 
          // [Navigator.maybePop] 현재 화면을 닫고 이전 화면으로 돌아감.
          // pop과 달리 이전 화면이 없을 때는 앱이 꺼지는 에러를 방지해 주는 안전한 방식
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w500,
            fontSize: 22,
            height: 28 / 22, 
            letterSpacing: 0,
            color: AppColors.primary,
          ),
        ),
      ),
      // [SafeArea] 아이폰의 노치나 기기 하단의 홈 바 영역을 침범하지 않도록 안전 구역에 위젯을 배치
      // 이 위젯이 없으면 글자나 버튼이 기기 베젤에 가려질 수 있음
      body: SafeArea(
        // [SingleChildScrollView] 내용이 길어져 기기 화면 밖으로 넘어갈 때 스크롤이 가능케함.
        // 텍스트 필드를 터치해서 키보드가 올라올 때 발생하는 '화면 오버플로우' 에러를 방지.
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          // [Form] 폼 텍스트 필드들을 하나의 논리적인 그룹으로 묶어주는 역할
          // 앞서 선언한 _formKey를 연결해 두었기 때문에 전체 필드를 한 번에 제어
          child: Form(
            key: _formKey,
            // [Column] 자식 위젯들을 위에서 아래로(세로 방향) 차곡차곡 쌓아주는 위젯
            // crossAxisAlignment를 stretch로 주어 자식들이 가로로 꽉 차게 팽창하도록 만들었습니다.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '환영합니다!\n간단한 정보만 입력하고 시작해보세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    height: 24 / 16,
                    letterSpacing: 0,
                    color: AppColors.textSecondary,
                  ),
                ),
                // [SizedBox] 빈 여백을 만들거나 위젯의 강제 크기를 지정할 때 사용하는 투명한 상자
                // 여기서는 위아래 위젯 사이에 32픽셀만큼의 간격을 주기 위해 사용
                const SizedBox(height: 32),

                const SectionLabel(text: '닉네임'),
                CustomInputField(
                  controller: _nicknameController,
                  hintText: '닉네임을 입력해주세요',
                  textInputAction: TextInputAction.next, // 키보드 우측 하단 버튼을 '다음'으로 변경
                  onChanged: (value) => _updateState(),
                  // [FocusScope.requestFocus] '다음' 버튼을 눌렀을 때 커서를 지정한 노드(이메일 필드)로 즉시 넘김
                  // 사용자가 화면을 터치하지 않고도 키보드만으로 입력을 이어갈 수 있게 해줌
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocusNode),
                  isValid: _nicknameController.text.length >= 2,
                  isError: _nicknameController.text.isNotEmpty && _nicknameController.text.length < 2,
                  errorText: '닉네임은 2자 이상이어야 합니다.',
                ),
                const SizedBox(height: 16),

                const SectionLabel(text: '이메일'),
                CustomInputField(
                  controller: _emailController,
                  focusNode: _emailFocusNode, // 닉네임에서 넘겨준 포커스를 받을 수 있도록 연결
                  hintText: '이메일 주소를 입력해주세요',
                  keyboardType: TextInputType.emailAddress, // 키보드 자판을 이메일 입력용으로 변경
                  textInputAction: TextInputAction.next,
                  onChanged: (value) => _updateState(),
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
                  isValid: _emailRegex.hasMatch(_emailController.text), 
                  isError: _emailController.text.isNotEmpty && !_emailRegex.hasMatch(_emailController.text),
                  errorText: '올바른 이메일 형식이 아닙니다.',
                ),
                const SizedBox(height: 16),

                const SectionLabel(text: '비밀번호'),
                CustomInputField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  hintText: '비밀번호를 입력해주세요',
                  obscureText: true, // 입력한 글자가 동그라미로 가려지도록 처리하는 속
                  textInputAction: TextInputAction.done,
                  onChanged: (value) => _updateState(),
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(), // 입력을 완료하면 키보드를 닫음
                  isValid: _passwordController.text.length >= 8,
                  isError: _passwordController.text.isNotEmpty && _passwordController.text.length < 8,
                  errorText: '비밀번호는 8자 이상이어야 합니다.',
                ),
                const SizedBox(height: 146),

                TermsCheckbox(
                  isAgreed: _isTermsAgreed,
                  onChanged: (value) {
                    setState(() {
                      _isTermsAgreed = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // [ElevatedButton] 누르면 살짝 떠오르는 듯한 그림자 효과를 가진 Material 기본 버튼
                // onPressed 속성에 null이 들어가면 버튼이 비활성화(회색)되고, 함수가 들어가면 활성화
                ElevatedButton(
                  onPressed: _isFormValid ? () => debugPrint('가입 완료') : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.disabledButton,
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '가입하기', 
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500,
                      fontSize: 16, 
                      height: 24 / 16,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24), 

                // [Row] 자식 위젯들을 가로(좌측에서 우측)로 나란히 배치해 주는 역할을 합니다.
                // mainAxisAlignment를 center로 주어 글자들을 화면 가운데 정렬시켰습니다.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '이미 계정이 있나요? ',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 24 / 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    // [GestureDetector] 터치 이벤트를 감지하지 못하는 일반 글자나 이미지를 버튼처럼 만들어주는 투명한 감지기입니다.
                    // onTap에 기능을 넣으면 글씨를 클릭했을 때 함수가 실행되게 할 수 있습니다.
                    GestureDetector(
                      onTap: () {
                        // TODO: 로그인 화면 구현 후 아래 주석 해제하여 연결
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginView()));
                        debugPrint('로그인 버튼 누름');
                      },
                      child: const Text(
                        '로그인',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 24 / 16,
                          color: AppColors.primary,
                        ),
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

// [StatelessWidget] 한 번 화면에 그려지면 스스로 모습을 바꿀 수 없는(상태가 없는) 정적인 위젯입니다.
// 재사용성을 높이기 위해 닉네임, 이메일 등의 라벨(제목) 부분을 따로 컴포넌트로 분리한 것입니다.
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w500,
          fontSize: 16,
          height: 24 / 16,
          letterSpacing: 0,
          color: AppColors.textPrimary,
        ),
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
  final bool isValid;
  final bool isError;
  final String? errorText;

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
    required this.isValid,
    required this.isError,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // [TextField] 사용자가 키보드로 글자를 입력할 수 있도록 해주는 핵심 입력 위젯입니다.
        // 앞서 넘겨받은 controller와 focusNode를 연결하여 부모 위젯(SignupView)에서 데이터를 관리할 수 있게 돕습니다.
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onSubmitted: onFieldSubmitted,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary, 
            fontSize: 16,
          ),
          // [InputDecoration] 텍스트 필드의 디자인(테두리, 배경색, 힌트 텍스트, 아이콘 등)을 꾸며주는 클래스입니다.
          // 커서가 없을 때(enabledBorder)와 클릭해서 커서가 생겼을 때(focusedBorder)의 테두리 색을 다르게 지정할 수 있습니다.
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w500,
              color: AppColors.hint, 
              fontSize: 16,
            ),
            filled: true,
            fillColor: isError ? AppColors.errorFill : AppColors.fieldFill,
            // [suffixIcon] 텍스트 필드의 우측 끝에 배치되는 아이콘입니다.
            // 에러가 났을 땐 에러 아이콘을, 조건이 맞았을 땐 체크 아이콘을 표시하는 로직이 들어있습니다.
            suffixIcon: isError
                ? const Icon(Icons.error_outline, color: AppColors.error, size: 20)
                : (isValid ? const Icon(Icons.check_circle, color: AppColors.primary, size: 20) : null),
            contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.fieldBorder, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isError ? AppColors.error : AppColors.fieldBorder, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isError ? AppColors.error : AppColors.primary, width: 1.5),
            ),
          ),
        ),
        if (isError && errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                fontFamily: 'Manrope',
                color: AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
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
    // [HitTestBehavior.opaque] 투명한 여백을 클릭해도 이벤트를 무시하지 않고 터치로 인식하게 만들어주는 속성입니다.
    // 사용자가 체크박스 아이콘을 정확히 누르지 않고 그 주변을 대충 눌러도 체크되도록 편의성을 높여줍니다.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!isAgreed),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            height: 26,
            child: Checkbox(
              value: isAgreed,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              checkColor: Colors.white,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            '필수 약관에 동의합니다',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w500,
              fontSize: 16, 
              color: AppColors.textPrimary, 
              height: 24 / 16,
            ),
          ),
        ],
      ),
    );
  }
}
