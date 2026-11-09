# 6주차 API 명세 (Standard Mission)

Base URL: `http://localhost:8080` · 요청 Content-Type: `application/json`

| 기능 | Method · URL | 입력 JSON | 성공 |
|---|---|---|---|
| 회원가입 | POST `/members` | `{"email":"user@example.com","nickname":"무비팬","password":"Study6!Demo"}` | 201, result: memberId/email/nickname |
| 평점 등록 | POST `/members/{memberId}/ratings` | `{"movieId":680,"score":5,"comment":"좋아요"}` | 201, result: ratingId |
| 평점 수정 | PATCH `/members/{memberId}/ratings/{ratingId}` | `{"score":4,"comment":"수정한 후기"}` | 200, result: null |
| 평점 삭제 | DELETE `/members/{memberId}/ratings/{ratingId}` | 없음 | 204, 본문 없음 |

회원가입: 유효한 이메일, 닉네임 2~12자, 비밀번호 대문자·소문자·숫자·특수문자 포함 8자 이상, UTF-8 기준 최대 72바이트. bcrypt 해시만 저장하며 password는 응답에서 제외합니다.

평점: movieId 양의 정수, score 1~5 정수, comment 선택(최대 2000자). PATCH는 score/comment 중 하나 이상 전달하며 생략한 필드는 유지합니다. comment를 비우려면 빈 문자열을 보냅니다.

성공 형식 (DELETE 제외):
```json
{"isSuccess":true,"code":"COMMON201","message":"평점 등록에 성공했습니다.","result":4}
```

오류 형식:
```json
{"isSuccess":false,"code":"COMMON409","message":"이미 등록한 영화 평점입니다.","result":null}
```

| 상태 | 원인 |
|---|---|
| 400 | 입력 형식·범위 오류, 잘못된 별점, 빈 수정 요청 |
| 403 | 다른 회원 소유 평점 수정·삭제 |
| 404 | 존재하지 않는 회원(등록 시) 또는 평점 |
| 409 | 중복 이메일·닉네임 또는 같은 회원/영화의 중복 평점 |

이 주차는 로그인 전 실습이므로 memberId를 URL로 받습니다. 실제 로그인 인증은 아직 구현하지 않았습니다. 기존 5주차 GET 응답 형식은 유지합니다.
