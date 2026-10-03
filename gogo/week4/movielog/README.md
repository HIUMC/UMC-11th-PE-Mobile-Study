# MovieLog · Week 4

워크북: https://app.notion.com/p/4-f7bb57f4596b837e8a6d01ac146a278c

`gogo` 브랜치의 Week 3 프로젝트를 Week 4로 복사한 Flutter 앱입니다. 이전 주차는 수정하지 않았습니다.

## 미션 체크리스트
- [x] Week 3 Movie / MovieCard 재사용, MovieGrid 분리
- [x] FakeMovieService의 Future.delayed(1초), 성공·빈 목록·실패 모드
- [x] initState에서 Future 생성, FutureBuilder로 Loading / Empty / Error / Success 분기
- [x] 장르·검색·정렬 변경은 메모리 내 필터링 (추가 요청 없음)
- [x] 사용자용 오류 문구와 다시 시도 → 새 Future 생성
- [x] 상단 장르 Chips, SharedPreferencesAsync 저장 및 비동기 복원
- [x] await 이후 mounted 확인, 설정 읽기·쓰기 예외 처리
- [x] TODO(5주차 유저별 평점 조회 API) 교체 지점 명시
- [x] 실제 API / Dio / Retrofit / Provider / MVVM 사용하지 않음

## 도전 과제
- [x] RefreshIndicator (성공·빈 결과·오류에서 아래로 당겨 새로고침)
- [x] Future.timeout(3초), 별도의 시간 초과 메시지
- [x] 영화 카드 Skeleton UI
- [x] 정렬(기본순·평점순·최신순) 저장·복원
- [x] Mock Service 성공·빈 결과·실패 테스트
- [x] 네 가지 상태, 오류 재시도, 시간 초과, 장르 저장·복원 및 불필요한 재조회 방지 테스트

## 실행 및 화면 확인
```sh
flutter pub get
flutter run
flutter test
flutter analyze
flutter drive --driver=test_driver/screenshots.dart --target=integration_test/user_flow_test.dart -d emulator-5554
```

시작 화면 → 가입 입력 → 영화 탭. 디버그 빌드의 우측 실험 아이콘으로 성공 / 빈 결과 / 오류 / 시간 초과를 재현합니다. 오류와 시간 초과는 1회 상황이며 다시 시도와 새로고침은 정상 응답으로 복구합니다. 릴리스에서는 실험 메뉴가 보이지 않습니다.

`evidence/week4/`에 에뮬레이터 캡처가 저장됩니다. `evidence/week3-baseline/`은 복사해 온 이전 주차 자료입니다.

## 비동기와 로컬 저장 정리
Future는 이후 한 번 전달되는 값 또는 오류입니다. async/await로 비동기 흐름을 순서대로 표현하고 try/catch/finally로 실패와 마무리를 처리합니다. 영화와 설정은 독립적이므로 Future.wait로 병렬로 읽습니다. Future는 build에서 생성하지 않으며 명시적인 새로고침 때만 교체합니다. timeout은 기다리기를 중단하지만 원래 Future 자체를 취소하지는 않습니다.

SharedPreferencesAsync에는 공개 설정인 `week4.genre`, `week4.sort`만 저장합니다. JWT·비밀번호·개인정보는 저장하지 않습니다. 비밀 값에는 플랫폼 보안 저장소를 사용하는 flutter_secure_storage 같은 별도 저장 방식이 필요합니다. iOS Keychain 값은 앱 삭제 뒤에도 남을 수 있으므로 인증을 도입할 때는 일반 저장소의 최초 실행 표시와 함께 잔존 토큰 정리 정책을 정해야 합니다. 이번 과제에는 인증과 보안 저장소를 추가하지 않았습니다.

메모리 설정 저장은 큐로 직렬화해 빠른 연속 선택의 기록 순서를 보장합니다. 잘못된 저장값은 기본값으로 복원합니다. 명시적인 장르 링크가 있으면 그 장르를 우선합니다.

## 제출
커밋·푸시·PR 생성은 실행하지 않습니다. 제출용 커밋 메시지와 PR 초안은 채팅으로 제공합니다.

## 검증 결과
- `flutter test`: 3개 테스트 통과
- `flutter analyze`: No issues found
- Android 에뮬레이터 통합 테스트 통과: 네 가지 상태, 오류 재시도, 실제 저장소 장르·정렬 복원
- 일반 앱에서 SF 선택 후 프로세스 강제 종료·재실행하여 SF 복원 확인 (`08-process-restored.png`)
- `07-app-relaunch.png`: 일반 앱 전체 목록 화면
