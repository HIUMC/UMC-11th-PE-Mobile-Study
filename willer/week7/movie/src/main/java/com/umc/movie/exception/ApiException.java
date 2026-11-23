package com.umc.movie.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public class ApiException extends RuntimeException { // 상태 코드와 code 문자열을 같이 들고 던지는 예외. 어디서 던지든 전역 처리기가 받아서 응답으로 바꿈

    private final HttpStatus status; // 응답 HTTP 상태 코드
    private final String code; // 응답 Body의 code. AUTH401_1처럼 도메인, 상태, 일련번호로 지음

    public ApiException(HttpStatus status, String code, String message) {
        super(message); // message는 부모 RuntimeException이 들고 있음
        this.status = status;
        this.code = code;
    }
}