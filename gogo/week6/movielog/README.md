# MovieLog · 6주차 Required Mission

4주차 프로젝트를 재사용해 6주차 기능을 추가했습니다. Flutter의 Dio가 워크북 서버와 TMDB에 **직접 HTTPS 요청**합니다. 중계 서버와 Python 실행은 필요 없습니다.

## 실행

프로젝트 폴더에서 실행합니다.

```sh
cd /Users/koh/Documents/GitHub/UMC-11th-PE-Mobile-Study/gogo/week6/movielog
flutter pub get
flutter devices
flutter run -d emulator-5554 --dart-define-from-file=.env
```

Android Studio Device Manager에서 에뮬레이터를 먼저 켜고, `emulator-5554`는 `flutter devices`에서 확인한 ID로 바꿉니다. macOS는 `-d macos`, Chrome은 `-d chrome`으로 실행할 수 있습니다. `adb reverse`는 필요 없습니다.

## TMDB 토큰과 Git 제외

[TMDB API 설정](https://www.themoviedb.org/settings/api)의 **API Read Access Token**을 사용합니다. `.env.example`에는 빈 형식만 있으며, `.env`에는 로컬에서 값을 입력합니다. 현재 사용자의 `.env`는 보존했습니다.

```dotenv
TMDB_ACCESS_TOKEN=여기에_토큰값
```

`Bearer `는 붙이지 않습니다. Flutter가 `--dart-define-from-file=.env`로 값을 읽고 `String.fromEnvironment`를 통해 Dio에 전달합니다. 별도 dotenv 패키지나 asset 등록은 필요 없습니다. 토큰을 바꾼 경우 앱을 종료한 후 같은 명령으로 재실행합니다.

`.gitignore`에는 `.env`, `.env.*`를 제외하고 `.env.example`만 허용하는 규칙이 있습니다. 직접 점검하려면:

```sh
git check-ignore .env
# .env가 출력되면 제외 규칙 적용 중

git ls-files .env
# 아무것도 출력되지 않아야 함

git status --short
# .env가 새 파일/변경 파일로 나타나지 않아야 함
```

만약 본인이 나중에 `.env`를 추적 대상으로 추가했다면 `git rm --cached .env`로 추적만 해제합니다(로컬 파일은 유지). 이미 GitHub에 올라간 토큰은 파일 삭제만으로 해결되지 않으므로 폐기 후 재발급합니다. `.env`를 `git add -f`로 강제 추가하거나 코드·README·스크린샷에 토큰을 넣지 않습니다.

이 방식은 **Git 저장소 제외**를 위한 구성입니다. 토큰은 로컬 앱 빌드에 포함되므로 토큰이 든 APK·웹 빌드 등을 저장소에 올리지 않습니다. `/build/`도 Git에서 제외되어 있습니다.

디버그 네트워크 로그는 `Authorization: Bearer ***`로 표시합니다. 헤더 원문, 응답 본문, 전체 URL·쿼리, 예외 원문은 기록하지 않습니다. 실제 요청에는 정상 토큰을 전송하며, 마스킹은 로그에만 적용합니다.

## 실제 서버 통신 범위

| 기능 | 데이터 출처 |
|---|---|
| 닉네임·이메일 중복 확인 | 워크북 v5 서버 |
| 내가 등록한 평점 | 워크북 v5 서버의 학습용 회원 1 |
| 평점 카드 제목·포스터 | TMDB 상세 API 및 이미지 서버 |
| 기존 홈·영화 목록 | 4주차 로컬 더미 데이터 유지 |

실제 회원가입과 평점 저장·수정·삭제는 하지 않습니다. 프런트 워크북에서 명시한 v5를 사용합니다.

- GET `/v5/members/nickname/{nickname}`
- GET `/v5/members/email/{email}`
- GET `/v5/members/1/ratings`
- TMDB GET `/3/movie/{movieId}`

## Required 구현

- 공용 MovieLogButton: 기본·회색 비활성·로딩 인디케이터.
- 내용 기반 폭(null): 중복 확인, 전체 폭: 가입하기, 고정 140: 평점 빈 목록·오류의 재시도 버튼.
- 닉네임·이메일 독립 상태, 로컬 검증, 중복·통신 오류 구분, 입력 변경 즉시 결과 무효화.
- 요청 버전·dispose 검사로 오래된 응답 무시.
- 평점 Loading / Empty / Error / Success 및 400·404·네트워크 오류 구분.
- 영화 정보 캐시·부분 실패 시 평점 유지·일시적 실패 재시도.
- 마이페이지 → 평점 화면은 root Navigator에 표시하고 하단 탭 숨김. 뒤로가기로 복귀.
- Challenge의 중복 문자열 기억·재입력 즉시 복원 기능은 제외.

## 검증

```sh
flutter analyze
flutter test
```

상태 전이, 폼, 작은 화면, 버튼 폭, 캐시, 라우터 이동·뒤로가기, 인증 로그 마스킹을 테스트합니다. `evidence`에는 이전 실제 API 확인 화면이 있으며 직접 통신 전환 뒤 새 검증 결과는 별도로 기록합니다. Android 에뮬레이터에서의 실제 실행은 아직 미검증입니다.
