package com.umc.movie.controller;

import com.umc.movie.dto.WriteDtos.ApiResponse;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.method.annotation.HandlerMethodValidationException;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.dao.DataIntegrityViolationException;

@RestControllerAdvice
public class ApiErrors {
    @ExceptionHandler(ResponseStatusException.class)
    ResponseEntity<ApiResponse> business(ResponseStatusException e) {
        return response(e.getStatusCode().value(),e.getReason());
    }
    @ExceptionHandler({MethodArgumentNotValidException.class, HandlerMethodValidationException.class,
        MethodArgumentTypeMismatchException.class,HttpMessageNotReadableException.class})
    ResponseEntity<ApiResponse> validation(Exception e) {
        return response(400,"입력값의 형식 또는 범위를 확인하세요.");
    }
    @ExceptionHandler(DataIntegrityViolationException.class)
    ResponseEntity<ApiResponse> conflict(DataIntegrityViolationException e) {
        return response(409,"이미 등록된 데이터이거나 저장 조건에 맞지 않습니다.");
    }
    private ResponseEntity<ApiResponse> response(int status,String message) {
        return ResponseEntity.status(status).body(new ApiResponse(false,"COMMON"+status,message,null));
    }
}
