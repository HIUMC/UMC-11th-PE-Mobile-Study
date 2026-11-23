package com.umc.movie.dto;

public record LoginResponse( // 로그인 성공 응답
                             String nickname,
                             String accessToken // 이후 요청의 Authorization 헤더에 Bearer와 함께 실어 보낼 토큰
) {}