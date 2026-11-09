# 5주차 백엔드 필수 실습 · Spring Boot

6주차 Flutter와 연결하기 위해 같은 week6 폴더에 둔 **5주차 백엔드**입니다.
Spring Boot 3.5.0 / Java 21 / Gradle 8.14.3 / MySQL 8.4를 사용합니다.
VS Code에서 실행할 수 있으며 IntelliJ 설치는 필수가 아닙니다.

## 구현

- `member`, `rating`, `favorite` 테이블 및 회원·평점 시드
- Entity → Repository → Service → Controller, DTO로 필요한 필드만 반환
- `GET /members/nickname/{nickname}` → `{"available": true/false}`
- `GET /members/email/{email}` → 같은 형식
- `GET /members/{memberId}/ratings` → 작성일 최신순 배열 (동일 작성일은 ID 내림차순)
- 잘못된 입력 400 / 없는 회원 404 / 평점 없는 기존 회원 `[]`
- localhost:5173(간이 프론트), localhost:7358(Flutter Web)만 CORS 허용

6주차 Standard Mission의 회원가입·평점 등록/수정/삭제도 추가했습니다. 명세는 [API.md](API.md), 요청 모음은 `postman/week6.postman_collection.json`에 있습니다. 로그인은 아직 구현하지 않았습니다.
시드 비밀번호는 로그인에 사용할 수 없는 실습용 문자열입니다.

## 실행 (Mac의 터미널)

프로젝트 루트에서:

```sh
cd gogo/week6/movielog-backend
export JAVA_HOME=$(/usr/libexec/java_home -v 21)
```

현재 로컬 `.env`는 생성되어 있습니다. 새 PC에서는 `.env.example`을 `.env`로 복사하고 로컬 DB 비밀번호 2개를 채우세요. `.env`는 Git에서 제외됩니다.

Docker Desktop을 실행한 뒤:

```sh
docker compose up -d --wait
set -a
source .env
set +a
./gradlew bootRun
```

서버는 `http://localhost:8080`에서 실행됩니다. 이미 실행 중이면 중복 실행하지 마세요.
종료는 `Ctrl+C`, DB 중지는 `docker compose stop`입니다. DB 볼륨은 유지됩니다.
`db/init.sql`은 **빈 DB를 처음 만들 때만** 실행됩니다.

## Flutter 연결

다른 터미널에서 Flutter 프로젝트로 이동합니다.

```sh
cd gogo/week6/movielog
flutter run -d chrome --web-port 7358 \
  --dart-define-from-file=.env \
  --dart-define=MOVIELOG_BASE_URL=http://localhost:8080 \
  --dart-define=MOVIELOG_API_PREFIX=
```

Android 에뮬레이터는 `flutter devices`에서 ID를 확인한 뒤:

```sh
flutter run -d <에뮬레이터-ID> \
  --dart-define-from-file=.env \
  --dart-define=MOVIELOG_BASE_URL=http://10.0.2.2:8080 \
  --dart-define=MOVIELOG_API_PREFIX=
```

`10.0.2.2`는 Android 에뮬레이터에서 Mac을 가리킵니다. 디버그 빌드에서 이 주소에만 로컬 HTTP를 허용합니다. Android 실행 자체는 이번 인증에서 확인하지 않았으며, 실제 화면 인증은 Flutter Web으로 진행했습니다.

닉네임·이메일·내 평점은 **직접 만든 Spring 서버 → 로컬 MySQL**을 사용합니다.
영화 제목·포스터는 Flutter가 TMDB에 직접 요청합니다. 홈·영화 목록의 기존 샘플 데이터는 유지됩니다.
서버 옵션 없이 실행하면 기존 워크북 제공 서버(`/v5`)를 사용합니다.

### 확인할 값

| 항목 | 중복/데이터 있음 | 사용 가능/비어 있음 |
|---|---|---|
| 닉네임 | 수현 | 새로운닉네임 |
| 이메일 | noco@example.com | new@example.com |
| 회원 ID | 1 (영화 155 → 550) | 3 (`[]`) |

앱 시작 → 회원가입에서 두 중복 확인 버튼을 누릅니다.
내 평점은 홈 → 마이페이지 → 내가 등록한 평점에서 확인합니다 (학습용 회원 1).

## CORS 전후 재현

1. 실행 중인 서버를 `Ctrl+C`로 종료합니다.
2. DB 환경변수를 로드한 터미널에서 `CORS_ENABLED=false ./gradlew bootRun`을 실행합니다.
3. 별도 터미널에서 아래 명령으로 간이 프론트를 실행합니다.

```sh
export JAVA_HOME=$(/usr/libexec/java_home -v 21)
"$JAVA_HOME/bin/jwebserver" -p 5173 -d "$PWD/cors-demo"
```

4. `http://localhost:5173`에서 호출 버튼을 누르면 Console에 CORS 오류가 나타납니다.
5. 서버를 종료한 뒤 `CORS_ENABLED=true ./gradlew bootRun`으로 재실행합니다.
6. 같은 프론트에서 버튼을 누르면 세 API가 200으로 응답합니다.

브라우저에서 확인해야 하는 실습입니다. Postman/Android는 브라우저 CORS 차단을 재현하지 않습니다.

## Postman

`postman/week5.postman_collection.json`을 Import하면 정상·중복·빈 목록·오류 요청 8개가 준비됩니다. 기본 baseUrl은 `http://localhost:8080`입니다. URL과 응답 JSON이 함께 보이게 캡처합니다.

## 검증

DB 실행 및 `.env` 환경변수 로드 후 `./gradlew test`.
실제 MySQL로 중복 여부, 최신순, 빈 목록, 400/404, CORS 허용·거부를 검증합니다.
Flutter에서는 `flutter test`, `flutter analyze`를 실행합니다.

## 실제 트러블슈팅

- 증상: 시드에 있는 한글 닉네임이 사용 가능으로 응답함.
- 원인: MySQL 초기화 SQL의 클라이언트 문자셋 때문에 한글이 잘못 저장됨.
- 수정: `init.sql`에 `SET NAMES utf8mb4` 추가, 이번 실습 시드 한글 복구.
- 재검증: `수현` 조회가 `available: false`, 통합 테스트 4개 통과.

회고: API가 200이어도 데이터가 맞는지 확인해야 한다. 중복·빈 목록·오류 입력과 브라우저 CORS까지 함께 검증했다.

## Git에 올리지 않을 파일

두 프로젝트의 `.env`, 빌드 결과, 로그는 제외됩니다. Flutter의 TMDB 토큰과 백엔드 DB 비밀번호는 별도 `.env`입니다.
커밋 전 `git status --short`에서 `.env`가 없는지 확인하세요. 이번 작업에서 커밋·푸시·PR은 만들지 않았습니다.
