package com.umc.movie.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public record CreateRatingRequest( // 평점 등록 요청 Body
                                   @NotNull(message = "영화 ID를 입력해주세요.")
                                   @Positive(message = "영화 ID는 양수여야 합니다.")
                                   Long movieId, // TMDB 영화 id. movie 테이블을 참조하지 않음

                                   @NotNull(message = "별점을 입력해주세요.") // 숫자 타입은 빈 문자열이 없어서 @NotBlank 대신 @NotNull
                                   @Min(value = 1, message = "별점은 1점 이상이어야 합니다.")
                                   @Max(value = 5, message = "별점은 5점 이하여야 합니다.")
                                   Integer score, // int가 아니라 Integer라서 값이 빠지면 null이 되고 @NotNull에 걸림

                                   @Size(max = 500, message = "후기는 500자 이하로 입력해주세요.")
                                   String comment // 선택 입력이라 @NotNull 없음
) {}