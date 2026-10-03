# MovieLog · Week 3

[노션 워크북](https://app.notion.com/p/makeus-challenge/3-626b57f4596b8337ba260112dd97fda5)의 Guided Practice, Required Mission, Challenge Mission 구현입니다.

## 실행

```sh
flutter pub get
flutter run
```

시작하기 → 회원가입 입력 검증 → 홈 순서입니다. 닉네임 2자 이상, 이메일 형식, 비밀번호 8자 이상, 실습용 약관 체크를 충족하면 홈으로 이동합니다. 서버 가입·인증은 하지 않으며 입력한 계정 정보는 저장하거나 전송하지 않습니다.

## 구현 체크리스트

- [x] `MaterialApp.router` 하나와 공통 Material 3 Theme 사용
- [x] 홈, 영화 목록, 영화 상세, 마이페이지 및 시작·회원가입 화면
- [x] 공통 Movie 모델과 Mock Data, `findMovieById`
- [x] `GestureDetector` 카드 선택 → 영화 ID Path Parameter → 상세 → 뒤로가기
- [x] 시작에서 회원가입으로 `pushReplacement`, 검증 후 홈으로 `go`
- [x] 회원가입·홈 이전 화면 복귀 방지
- [x] NavigationBar 선택 상태와 현재 탭 일치
- [x] `StatefulShellRoute.indexedStack`과 `goBranch`로 탭의 필터·검색·스크롤 상태 보존
- [x] `ListView` 장르 목록, `GridView.builder` 영화 목록, 가로 `ListView.separated` 영화 카드
- [x] 장르 필터링: 기본 Chip 방식 대신 **Challenge 지시대로 Chip 영역을 제거**하고 오른쪽 필터 아이콘과 BottomSheet로 확장
- [x] 드래그 가능한 BottomSheet, 다중 장르 Checkbox, 독립 스크롤 목록, 고정 ElevatedButton
- [x] Sheet 내부 임시 선택 → 확인 시 적용, 바깥 터치·뒤로가기 취소 시 기존 필터 유지
- [x] 장르 선택이 없으면 전체 목록, 장르·검색 조건 Query Parameter 반영
- [x] `MovieRatingInput`과 `RatingBar.builder`: 0.5 단위 선택
- [x] 평점 Dialog의 선택값·숫자·확인 버튼 동시 갱신
- [x] 0점 초기 상태에서는 저장 불가, 평점 초기화 후 다시 선택 가능
- [x] Dialog 취소는 기존 평점 보존, 확인은 로컬 평점 갱신
- [x] `RatingBarIndicator`로 Mock 평균 표시, 별빛 아래 우리 평균 4.5
- [x] 즐겨찾기 추가·삭제 Snackbar 및 채움/외곽선 아이콘 변경
- [x] MovieCard, MovieRatingInput, MovieRatingIndicator, RatingDialog, GenreFilterSheet 등 의미 단위 Widget 분리
- [x] API·인증·Provider·MVVM 미사용, 앱 실행 중 메모리의 평점·즐겨찾기만 공유
- [ ] Pull Request 링크 및 PR 영상 첨부 — 사용자 승인 전에는 커밋·푸시·PR을 생성하지 않음

## Route와 화면 전환 설명

`MaterialApp.router`는 `AppRouter.router`의 경로 구성으로 화면을 그립니다. `home` 속성이나 별도의 MaterialApp을 중첩하지 않습니다.

| Route | 역할 |
| --- | --- |
| `/start` | 시작 화면, 앱 기본 진입점 |
| `/register` | 입력 검증 실습 |
| `/home` | 추천·인기 영화 |
| `/movies?genre=드라마,SF&q=검색어` | 영화 목록과 선택 조건 |
| `/movies/:movieId` | ID로 Mock 영화 조회, 잘못된 ID 안내 |
| `/my` | 즐겨찾기·개인 평점 통계 |

- `go`: Route 구성을 목적 위치로 변경합니다. 가입 완료 후 홈, 검색·필터 URL 변경에 사용합니다.
- `push`: 현재 화면 위에 상세를 쌓아 출발 화면의 상태와 복귀 위치를 유지합니다.
- `pushReplacement`: 현재 화면을 교체합니다. 시작 화면을 회원가입으로 교체하여 이전 화면을 남기지 않습니다.
- `pop`: 상세를 닫아 출발 화면으로 돌아갑니다. 직접 상세 URL로 들어와 이전 화면이 없으면 `/movies`로 이동합니다.
- `goBranch`: 탭마다 유지한 Navigator로 전환합니다. 이미 선택한 탭을 다시 누르면 해당 탭의 시작 위치로 이동합니다.

Path는 영화 ID처럼 대상을 식별하고, Query는 장르·검색어처럼 선택적인 조건을 표현합니다. Extra는 메모리의 객체를 편리하게 전달하지만 직접 URL 접근이나 앱 재시작에서는 없을 수 있습니다. 따라서 이 앱은 Extra 없이 ID를 기준으로 Mock Data를 조회합니다. 상세는 공통 루트에 표시하여 홈·영화·마이 어느 화면에서 열어도 해당 출발 화면으로 복귀합니다.

## 트러블슈팅

1. 시작 버튼이 회원가입을 건너뛰고 홈으로 이동하던 문제: 초기 Route를 `/start`로 지정하고 시작→가입 교체, 가입→홈 Route 변경을 적용했습니다.
2. 평점 초기화 후 표시와 버튼 상태가 어긋날 수 있던 문제: Dialog가 임시 평점을 소유하고 초기화 시 RatingBar의 Key도 갱신합니다. 확인 전에는 저장하지 않습니다.
3. 즐겨찾기 Snackbar가 평점 버튼을 가리던 문제: 상세 하단 버튼을 `Scaffold.bottomNavigationBar`로 옮겨 Snackbar가 버튼 위에 배치되도록 했습니다.
4. 영화별 평균이 상세에서 모두 4.5로 고정되고 홈은 10점 척도였던 문제: 홈·목록·상세 모두 같은 Movie의 5점 척도 평균을 사용합니다.
5. Android D8 중복 클래스 빌드 실패: 기존 build 폴더에 같은 이름의 `..._0.jar`와 `..._0 2.jar`가 함께 남아 있었습니다. `flutter clean` 후 재빌드하여 생성 산출물을 정리했습니다.

## 검증 및 증빙

```sh
flutter analyze
flutter test
# 연결된 Android 에뮬레이터에서 전체 흐름 실행 및 PNG 저장
flutter drive --driver=test_driver/screenshots.dart --target=integration_test/user_flow_test.dart -d emulator-5554
```

`test/widget_test.dart`는 가입 검증·Back Stack, 필터 적용/취소/전체 복구, 상세 복귀, 즐겨찾기, 평점 초기화/저장, 탭 상태 보존, 잘못된 ID를 확인합니다.

`integration_test/user_flow_test.dart`는 에뮬레이터에서 사용자 흐름을 실행하고, `test_driver/screenshots.dart`가 `evidence/`에 화면 PNG를 저장합니다. 의존성 버전은 `pubspec.lock`에 기록되어 있으며 go_router는 18.0.1, flutter_rating_bar는 4.0.1입니다.

### 최종 실행 결과 (2026-09-28)

- Android Medium Phone 에뮬레이터에서 전체 사용자 흐름 통과
- `evidence/01-start.png`부터 `17-final-home.png`까지 스크린샷 17장
- `evidence/user-flow.mp4`: 시작·가입·탭 전환·필터·상세 복귀·평점·즐겨찾기 흐름 녹화
- `flutter test`: 위젯 테스트 2개 통과
- `flutter analyze`: 이슈 없음
- Notion 원본 체크박스는 변경하지 않았으며, 구현 여부는 위 체크리스트로 정리했습니다. PR 관련 항목만 사용자 승인 후 진행합니다.

영상까지 함께 다시 저장하려면 `ANDROID_ADB` 환경변수에 adb 실행 파일 경로를 지정한 뒤 위 `flutter drive` 명령을 실행하세요. 녹화 대상 기기는 `emulator-5554`입니다.
