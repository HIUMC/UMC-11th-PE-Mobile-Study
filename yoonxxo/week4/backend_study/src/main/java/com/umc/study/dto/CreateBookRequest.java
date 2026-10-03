package com.umc.study.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CreateBookRequest(
        @NotNull Long categoryId, // 카테고리 ID는 반드시 필요
        @NotBlank @Size(max = 100) String title, // 제목은 비어 있으면 안 되고 최대 100자
        String description // 설명은 선택 사항
) {
}
