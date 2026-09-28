import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

class GenreFilterSheet extends StatefulWidget { // 장르를 여러 개 고르는 BottomSheet. 확인 전까지 고른 걸 기억해야 해서 StatefulWidget
  const GenreFilterSheet({super.key, required this.initialGenres}); // 필수. 시트를 열 때 이미 적용돼 있던 장르들

  static const genres = ['드라마', 'SF', '애니메이션', '스릴러', '로맨스', '액션']; // 고를 수 있는 장르. 아무것도 안 고르면 전체라서 '전체'는 없음

  final List<String> initialGenres;

  @override
  State<GenreFilterSheet> createState() => _GenreFilterSheetState();
}

class _GenreFilterSheetState extends State<GenreFilterSheet> {
  final selectedGenres = <String>{}; // 시트 안에서만 쓰는 임시 선택. {}는 Set. 같은 값이 두 번 안 들어가서 체크 목록에 맞음

  @override
  void initState() { // State가 처음 만들어질 때 한 번만 실행
    super.initState();
    selectedGenres.addAll(widget.initialGenres); // 적용돼 있던 장르를 복사해서 시작. 원본을 직접 바꾸지 않아서 확인 전에는 목록에 반영 안 됨
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet( // 손가락으로 위아래로 끌어서 높이를 바꾸는 시트
      expand: false, // 부모가 준 전체 높이까지 강제로 늘리지 않음. 아래 비율대로 열림
      initialChildSize: 0.5, // 처음 열릴 때 화면 높이의 절반
      minChildSize: 0.3, // 아래로 끌어내릴 수 있는 최소 높이
      maxChildSize: 0.9, // 위로 끌어올릴 수 있는 최대 높이
      builder: (context, scrollController) { // scrollController는 시트 끌기와 안쪽 목록 스크롤을 이어주는 연결고리
        return Column(
          children: [
            Expanded( // 목록이 남은 공간만 차지. 그 안에서만 스크롤되고 아래 확인 버튼은 스크롤 영역 밖이라 항상 보임
              child: ListView.builder(
                controller: scrollController, // 반드시 연결. 없으면 목록 스크롤과 시트 끌어올리기가 따로 놂
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: GenreFilterSheet.genres.length, // static이라 클래스 이름으로 접근
                itemBuilder: (context, index) {
                  final genre = GenreFilterSheet.genres[index];

                  return Row( // Checkbox 혼자서는 옆에 글자를 붙일 수 없어서 Row로 감쌈
                    children: [
                      Checkbox( // 색과 모양은 AppTheme의 checkboxTheme을 따름
                        value: selectedGenres.contains(genre), // 임시 선택에 있으면 체크된 상태
                        onChanged: (checked) { // 누르면 바뀔 값이 들어옴. Checkbox는 null을 줄 수 있어서 bool?
                          setState(() { // 시트 안의 체크 모양만 다시 그림. 목록 화면은 아직 그대로
                            if (checked ?? false) {
                              selectedGenres.add(genre); // 체크하면 추가
                            } else {
                              selectedGenres.remove(genre); // 해제하면 제거
                            }
                          });
                        },
                      ),
                      Text(genre, style: AppTextStyles.bodyMedium),
                    ],
                  );
                },
              ),
            ),
            SafeArea( // 하단 제스처 바와 버튼이 겹치지 않게 여백을 자동으로 줌
              top: false, // 위쪽은 목록이 있어서 여백 필요 없음
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity, // 버튼을 가로로 꽉 채움
                  child: ElevatedButton( // 색과 모양은 AppTheme의 elevatedButtonTheme을 따름
                    onPressed: () {
                      final result = GenreFilterSheet.genres.where(selectedGenres.contains).toList(); // 고른 장르만 남김. 누른 순서가 아니라 장르 목록 순서대로 정렬돼서 주소가 항상 같은 모양
                      Navigator.pop(context, result); // 시트를 닫으면서 선택 결과를 돌려줌. 이때 처음으로 목록에 반영됨
                    },
                    child: const Text('확인'),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}