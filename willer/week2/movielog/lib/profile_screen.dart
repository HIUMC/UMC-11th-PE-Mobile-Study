import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '내 프로필'), // appBar 자리에 직접 만든 위젯 넣음. 
      body: SafeArea(
        child: SingleChildScrollView( // 자식이 화면보다 길어지면 스크롤할 수 있게 해줌
          child: Padding( // 자식 주위에 여백을 만드는 역할
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(                      // Column의 교차축은 가로. 기본값이 center인데 그대로 두면 "선호하는 장르"
              crossAxisAlignment: CrossAxisAlignment.start, // 제목과 Chip들이 가운데로 몰림.
              children: const [ // children 리스트 전체에 const. 이렇게 하면 개별 위젯마다 const를 붙일 필요 없음.
                SizedBox(height: 16), // 간격은 8배수
                ProfileHeader(),
                SizedBox(height: 24),
                ProfileStats(),
                SizedBox(height: 32),
                FavoriteGenres(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// Scaffold의 appBar 자리에 아무 위젯 못 받고, 높이를 미리 알려줄 수 있는 위젯만 받음. 그래서 PreferredSizeWidget이 필요!
// Dart는 클래스 하나만 상속할 수 있어서 StatelessWidget을 extends로 상속받고 PreferredSizeWidget은 구현만 하면 되서 implements로 받음
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({ // 생성자
    super.key,
    required this.title, // 필수. 이거 없이 CommonAppBar() 쓰면 에러남
    this.onBack, //선택. 안넘기면 null로 들어감
    this.actions, // 선택
    this.centerTitle = false, //
    this.titleStyle, // 선택
  });

  final String title; // 필드 선언. final이라 한 번 정해지면 안바뀜. StatelessWidget은 상태가 없어야해서 필드도 불변이어야 함.
  final VoidCallback? onBack; // void Function()의 별칭. 버튼 콜백에 딱 맞음
  final List<Widget>? actions; // 위젯 여러개를 받는 리스트. null일 수도 있음. AppBar 오른쪽에 버튼을 여러 개놓을 수 있어서 리스트.
  final bool centerTitle;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return AppBar( // 위젯이 반환하는 건 결국 Flutter 기본 AppBar. CommonAppBar는 그걸 감싸서 기본값을 미리 채워둔 껍데기
      title: Text(
        title,
        style: titleStyle ?? // ??는 null 병합 연산자. 왼쪽이 null이면 오른쪽을 쓴다는 뜻
            AppTextStyles.titleLarge.copyWith(color: AppColors.violet), // 기존 스타일에서 약간 수정. AppBar 제목은 보라색
      ),
      centerTitle: centerTitle, // 받은 값을 그대로 넘김. 왼쪽은 AppBar 속성, 오른쪽은 CommonAppBar 필드
      leading: onBack == null // 삼항 연산자. onBack이 null이면 leading도 null로 넘기고, 아니면 뒤로가기 버튼을 만든다는 뜻
          ? null
          : IconButton(  // 지금은 onBack을 안넘겨서 버튼이 안그려짐.
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); //PreferredSizeWidget이 요구하는 유일한 멤버. 이걸 구현해야
                // Scaffold의 appBar 자리에 들어갈 수 있음. 
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key}); // 지금은 외부에서 받을게 없어서 {} 안에 아무것도 없음.

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // 교차축을 center로 잡음. 바깥 ProfileScreen의 Column이 start라서 Chip들이 왼쪽으로 몰려서, 이 안에서만 가운데 정렬
      children: [
        ClipOval( // 자식을 타원형으로 잘라내는 위젯
          child: Image.asset( // 화면에 직접 그리기
            'assets/images/profile/profile_movielog.jpg',
            width: 112,
            height: 112,
            fit: BoxFit.cover, // 빈공간이 생기면 어색해서 cover
          ),
        ),
        const SizedBox(height: 16), // 사진과 닉네임 사이 간격
        Row( // 아이콘과 닉네임을 가로로 나란히 놓기 위해서. Column안에 Row가 들어간 구조. 
          mainAxisAlignment: MainAxisAlignment.center, // Row의 주축은 가로니까 가로 가운데 정렬. 없으면 mainAxisSize가 max라서 Row가 화면 끝까지 늘어나서 가운데 정렬이 안됨.
          children: [
            SvgPicture.asset(
              'assets/icons/star.svg', // 별모양 아이콘
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode( // colorFilter는 SVG의 색을 코드에서 바꾸는 방법. 
                AppColors.violet, // 색상
                BlendMode.srcIn, // 블렌드모드 의 구조. BlendMode.srcIn은 "source(지정한 색)를 destination(SVG)의 불투명한 영약안에만 채워라"라는 뜻
              ),
              semanticsLabel: '별 아이콘',
            ),
            const SizedBox(width: 8), // height가 아니라 width. Row안이라 가로 간격을 만들어야함
            const Text('무비러버', style: AppTextStyles.titleLarge), // 닉네임. TextStyle은 AppTextStyles에서 상수로 만들어둔 걸 그대로 참조
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '매주 주말엔 영화관으로 출근하는 프로 관람객. 좋은 영화를 보고 기록하는 것을 좋아합니다.',
          textAlign: TextAlign.center, // 텍스트가 길어서 두 줄로 나뉨. 그때 두 줄이 각각 가운데 정렬됨. 
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 16),
        const EditProfileButton(), // 수정 버튼을 별도의 위젯으로 뺌. 뺀 이유는 ProfileHeader가 너무 길어져서 헤더 코드 안에 섞이면 구조가 잘 보이지 않음.
      ],
    );
  }
}

class EditProfileButton extends StatelessWidget {
  const EditProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        debugPrint('프로필 수정 버튼을 눌렀습니다.');
      },
      style: TextButton.styleFrom(
        foregroundColor: AppColors.violet, // 글자색
        backgroundColor: AppColors.white, // 배경색
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // 버튼 내부 여백
        side: const BorderSide(color: AppColors.violet), // 버튼 테두리
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // 모서리 반지름 8. 폭을 지정하지 않아서 버튼이 내용물 크기만큼 차지
        ),
      ),
      child: const Text('프로필 수정'),
    );
  }
}

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row( // 통계 카드 가로로 배치
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Expanded(child: StatItem(label: '본 영화', value: '342')), // Expanded는 자식이 Row나 Column에서 남은 공간을 다 차지하게 해줌. 자식이 3개라서 1/3씩 나눠가짐.
        Expanded(child: StatItem(label: '평점', value: '4.2')),
        Expanded(child: StatItem(label: '즐겨찾기', value: '58')),
      ],
    );
  }
}

class StatItem extends StatelessWidget { // 재사용 위젯. 달라지는 값만 파라미터로 받고 나머지 구조는 안에서 고정
  const StatItem({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container( // 배경색, 테두리, 둥근 모서리 필요해서 Container로 감쌈. 여백만 필요하다면 Padding으로 감싸도됨.
      margin: const EdgeInsets.symmetric(horizontal: 4), // 카드 사이 간격
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16), // 카드 내부 여백
      decoration: BoxDecoration( // 노션내용대로 Container.color가 아니라 decoration 안에 color를 넣음
        color: AppColors.white,
        border: Border.all(color: AppColors.gray.withValues(alpha: 0.3)), //Border.all(..)은 네 방향 전부 같은 테두리
        borderRadius: BorderRadius.circular(8), // 네 모서리 반지름 8
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 이게 없으면 카드가 세로로 길어짐. min을 주면 내용물(라벨 + 간격 + 숫자) 크기만큼만 차지. 작은박스 안에 Column을 넣을때 필요
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4), // 라벨과 숫자 사이 간격
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.violet), // 숫자 색만 보라로 바꿈
          ),
        ],
      ),
    );
  }
}

class FavoriteGenres extends StatelessWidget {
  const FavoriteGenres({super.key});

  static const genres = <String>['드라마', 'SF', '애니메이션'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // 교차축(가로)을 왼쪽 정렬로
      children: [
        const Text('선호하는 장르', style: AppTextStyles.titleMedium), // 섹션 제목
        const SizedBox(height: 12), // 제목과 Chip 사이 간격
        Row(
          children: genres
              .map( // genres.map((genre) => 위젯)은 "문자열 3개짜리 리스트를 위젯 3개로 바꿔라"는 뜻. Chip을 세 번 복사 안해도됨
                (genre) => Container(
                  margin: const EdgeInsets.only(right: 8), //Chip 사이 간격
                  child: Chip(
                    label: Text(genre), // Chip안에 표시할 위젯. 
                    labelStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.violet,
                    ),
                    backgroundColor: AppColors.violet.withValues(alpha: 0.12),
                    side: BorderSide.none, // 테두리 없음. container의 decoration은 Border를 받고, Chip과 버튼은 BorderSide를 받음
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              )
              .toList(), // map이 반환하는 건 Iterable<Widget>이지 List<Widget> 이 아님. Row의 childeren은 후자를 요구해서 변환해야함
        ),
      ],
    );
  }
}