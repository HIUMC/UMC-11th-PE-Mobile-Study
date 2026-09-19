import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // SvgPicture를 쓰려면 필요. Flutter 기본 기능으로느 SVG를 그릴 수 없어서 외부 패키지 사용

import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // 화면 한 장의 뼈대. appBar, body, floatingActionButton, bottomNavigationBar 같은 자리를 미리 잡아둔 틀
      body: SafeArea( // 지금은 body만 사용. 시작 화면은 상단바 없는 전체 화면이라서. SafeArea가 없으면 상태바와 겹쳐서 글자가 잘림.
        child: Padding( // SafeArea가 Padding이라는 자식 하나만 받아서 child
          padding: const EdgeInsets.symmetric(horizontal: 16), // 좌우 16여백. 위아래는 0 (horizontal). 컴파일 시점에 확정이라 const
          child: Column( // Padding도 Column이라는 자식 하나만 받아서 child
            mainAxisAlignment: MainAxisAlignment.center, // 주축정렬 의미. 자식들을 세로로 쌓고(Column안에 선언해서), 주축(세로) 방향으로 가운데 정렬
            children: [ // Column은 여러 자식을 받아서 children.
              SvgPicture.asset(
                'assets/logos/movielog_logo.svg', // 경로는 pubspec.yaml의 assets:에 등록한 폴더 안이어야 함. 
                width: 72,
                height: 72,
                semanticsLabel: 'MovieLog 로고', // 스크린 리더용 설명. 화면엔 안보임. 
              ),
              const SizedBox(height: 24), // 세로 24간격. 빈 상자로 간격을 만듦
              const Text( //컴파일 시점에 확정이라 const
                '영화의 순간을 기록하세요', // 첫번째 값만 이름 없이 넘김. Text의 문자열만 positional parameter고 나머지는 전부 named.
                textAlign: TextAlign.center, // Text가 차지한 영역 안에서 가로 가운데 정렬.
                maxLines: 2, // 최대 2줄까지 표시
                overflow: TextOverflow.ellipsis, // 넘치면 ...으로 자름. maxLines와 세트로 다님. 
                style: AppTextStyles.titleLarge, // 이제 상수를 참조
              ),
              const SizedBox(height: 12),
              const Text(
                '보고 싶은 영화부터 나만의 평점까지 한곳에서 관리해요',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () { // onPressed에 넘긴 () {...} 익명 함수.
                  debugPrint('시작하기 버튼을 눌렀습니다.'); // print의 Flutter 버전. 알아서 나눠 출력
                },
                style: ElevatedButton.styleFrom( // styleFrom은 버튼 스타일을 만드는 헬퍼.
                  backgroundColor: AppColors.violet, // 버튼 배경색
                  foregroundColor: AppColors.white,  // 글자와 아이콘 색
                  minimumSize: const Size(double.infinity, 52), // double.infinity는 부모가 허용하는 최대까지, 세로는 52고정
                  shape: RoundedRectangleBorder(  //shpae은 버튼 모양. 모서리가 둥근 사각형 모양으로 설정. 
                    borderRadius: BorderRadius.circular(8), // 모서리 반지름 8
                  ),
                ),
                child: const Text('시작하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}