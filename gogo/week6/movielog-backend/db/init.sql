USE umc_movie;
SET NAMES utf8mb4;
CREATE TABLE member (
  member_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(254) NOT NULL UNIQUE,
  password VARCHAR(60) NOT NULL,
  nickname VARCHAR(50) NOT NULL UNIQUE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
CREATE TABLE rating (
  rating_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  member_id BIGINT NOT NULL,
  movie_id BIGINT NOT NULL,
  score TINYINT NOT NULL,
  comment TEXT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_rating_member FOREIGN KEY (member_id) REFERENCES member(member_id),
  CONSTRAINT uk_rating_member_movie UNIQUE (member_id, movie_id),
  CONSTRAINT ck_rating_score CHECK (score BETWEEN 1 AND 5)
);
CREATE TABLE favorite (
  favorite_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  member_id BIGINT NOT NULL,
  movie_id BIGINT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_favorite_member FOREIGN KEY (member_id) REFERENCES member(member_id),
  CONSTRAINT uk_favorite_member_movie UNIQUE (member_id, movie_id)
);
-- 조회 실습 전용 회원. 비밀번호 로그인/회원가입은 5주차 범위 밖입니다.
INSERT INTO member (email, password, nickname) VALUES
 ('noco@example.com', 'seed-only-login-disabled', '수현'),
 ('minseo@example.com', 'seed-only-login-disabled', '민서'),
 ('empty@example.com', 'seed-only-login-disabled', '빈회원');
INSERT INTO rating (member_id,movie_id,score,comment,created_at,updated_at) VALUES
 (1,550,5,'최고의 영화!','2026-10-30 10:00:00','2026-10-30 10:00:00'),
 (1,155,4,'다시 봐도 명작','2026-11-01 10:00:00','2026-11-01 10:00:00'),
 (2,550,3,NULL,'2026-10-31 10:00:00','2026-10-31 10:00:00');
