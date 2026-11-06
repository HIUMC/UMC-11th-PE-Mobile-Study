package com.umc.movie.controller;

import com.umc.movie.dto.ApiResponse;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;

@RestControllerAdvice // 모든 Controller에서 던진 예외를 여기서 모아 처리하고, 반환값을 JSON으로 응답
public class GlobalExceptionHandler {
    @ExceptionHandler(MethodArgumentNotValidException.class) // @Valid 검증에 실패하면 발생
    public ResponseEntity<ApiResponse<Void>> handleValidation(MethodArgumentNotValidException exception) {
        String message = exception.getBindingResult().getFieldErrors().get(0).getDefaultMessage(); // 틀린 필드가 여러 개여도 첫 번째 메시지만 보냄
        return ResponseEntity.badRequest().body(ApiResponse.failure("COMMON4001", message)); // 400
    }

    @ExceptionHandler(DataIntegrityViolationException.class) // 사전 확인을 통과했어도 DB UNIQUE 제약에 걸리면 발생
    public ResponseEntity<ApiResponse<Void>> handleDataIntegrity(DataIntegrityViolationException exception) {
        return ResponseEntity.status(409).body(ApiResponse.failure("COMMON4091", "이미 존재하는 데이터입니다."));
    }

    @ExceptionHandler(IllegalArgumentException.class) // Service에서 직접 던진 중복 예외
    public ResponseEntity<ApiResponse<Void>> handleIllegalArgument(IllegalArgumentException exception) {
        return ResponseEntity.status(409).body(ApiResponse.failure("COMMON4092", exception.getMessage())); // Service가 정한 메시지를 그대로 씀
    }

    @ExceptionHandler(ResponseStatusException.class) // 상태 코드를 직접 정해서 던진 예외. 404, 403 등
    public ResponseEntity<ApiResponse<Void>> handleResponseStatus(ResponseStatusException exception) {
        int status = exception.getStatusCode().value();
        return ResponseEntity.status(status)
                .body(ApiResponse.failure("COMMON" + status, exception.getReason())); // 404면 COMMON404처럼 상태 번호를 code에 붙임
    }
}