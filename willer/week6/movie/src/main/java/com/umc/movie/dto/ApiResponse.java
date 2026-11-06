package com.umc.movie.dto;

public record ApiResponse<T>(boolean isSuccess, String code, String message, T result) { // 성공과 실패가 같은 모양. T는 result에 담길 값의 타입
    public static <T> ApiResponse<T> created(String message, T result) { // 201 성공용
        return new ApiResponse<>(true, "COMMON201", message, result);
    }

    public static <T> ApiResponse<T> ok(String message, T result) { // 200 성공용
        return new ApiResponse<>(true, "COMMON200", message, result);
    }

    public static ApiResponse<Void> failure(String code, String message) { // 실패용. result는 항상 null
        return new ApiResponse<>(false, code, message, null);
    }
}