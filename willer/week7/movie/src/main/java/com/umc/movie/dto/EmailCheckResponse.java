package com.umc.movie.dto;

public record EmailCheckResponse(boolean available) {} // 닉네임과 응답 모양은 같지만 API마다 따로 둬서 나중에 필드가 달라져도 서로 영향 없음