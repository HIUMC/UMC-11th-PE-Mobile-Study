import 'package:flutter/material.dart';

// 직접 만든 공통 파일을 불러옴
import '../widgets/common_app_bar.dart';
import '../widgets/profile_header.dart';
import '../widgets/edit_profile_button.dart';
import '../widgets/stat_item.dart';
import '../widgets/favorite_genres.dart';

// 프로필 화면을 나타내는 Widget
// 1주차 화면은 데이터가 바뀌지 않는 정적 화면이라 StatelessWidget 사용
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold = 한 화면의 기본 뼈대
    // appBar와 body 같은 영역을 나눌 수 있음
    return Scaffold(
      // 우리가 만든 공용 AppBar 사용
      appBar: CommonAppBar(title: '내 프로필'),

      // 화면의 실제 내용 영역
      body: const SafeArea(
        // 화면 좌우에 24만큼 여백을 줌.
        //
        // Padding = Widget 내부의 여백을 만드는 Widget
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),

          // Column을 사용해서
          // 앞으로 프로필 화면 내용을 위 → 아래 순서로 배치할 예정
          child: Column(
            // Column 안의 Widget이 화면 가로 너비를 사용하도록
            // 왼쪽 기준으로 정렬
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              // AppBar 아래와 프로필 사진 사이의 간격
              SizedBox(height: 32),

              // 프로필 이미지 + 닉네임 + 소개글
              ProfileHeader(),

              // 소개글과 버튼 사이 간격
              SizedBox(height: 24),

              // 프로필 수정 버튼
              // 버튼 자체는 화면 전체 너비로 늘어나면 안 되므로
              // Center로 감싸서 필요한 크기만 사용하게 함
              Center(child: EditProfileButton()),

              // 프로필 수정 버튼과 통계 카드 사이 간격
              SizedBox(height: 32),

              // Row:
              // 자식 Widget들을 가로 방향으로 배치함.
              Row(
                children: [
                  // Expanded:
                  // Row 안에서 남은 가로 공간을 나눠서 사용하게 함.
                  Expanded(
                    child: StatItem(label: '본 영화', value: '342'),
                  ),

                  // 카드 사이 가로 간격
                  SizedBox(width: 8),

                  Expanded(
                    child: StatItem(label: '평점', value: '4.2'),
                  ),

                  SizedBox(width: 8),

                  Expanded(
                    child: StatItem(label: '즐겨찾기', value: '58'),
                  ),
                ],
              ),
              // 통계 카드와 장르 영역 사이 간격
              SizedBox(height: 32),

              // 선호하는 장르 영역
              FavoriteGenres(),
            ],
          ),
        ),
      ),
    );
  }
}
