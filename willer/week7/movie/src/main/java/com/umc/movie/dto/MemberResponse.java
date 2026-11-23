package com.umc.movie.dto;

public record MemberResponse( // 회원가입 성공 응답. password는 일부러 뺌
                              Long memberId,
                              String email,
                              String nickname
) {}