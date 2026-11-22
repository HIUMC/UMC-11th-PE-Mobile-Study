package com.umc.movie.dto;

public record NicknameCheckResponse(boolean available) {} // 응답 JSON이 {"available": true} 모양이 됨. record라 getter와 생성자가 자동으로 생김