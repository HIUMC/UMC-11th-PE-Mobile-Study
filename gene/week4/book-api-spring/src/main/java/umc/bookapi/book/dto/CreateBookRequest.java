package umc.bookapi.book.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public record CreateBookRequest(
        @NotNull(message = "categoryId는 필수입니다.")
        @Positive(message = "categoryId는 양수여야 합니다.")
        Long categoryId,

        @NotBlank(message = "제목은 비어 있을 수 없습니다.")
        @Size(max = 100, message = "제목은 100자 이하여야 합니다.")
        String title,

        // 선택 입력 (null 허용)
        @Size(max = 500, message = "설명은 500자 이하여야 합니다.")
        String description
) {
}
