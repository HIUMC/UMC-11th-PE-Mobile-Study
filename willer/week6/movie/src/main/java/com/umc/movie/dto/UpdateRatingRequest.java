package com.umc.movie.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record UpdateRatingRequest( // 평점 수정 요청 Body. 영화는 바꿀 수 없어서 movieId가 없음
                                   @NotNull(message = "별점을 입력해주세요.")
                                   @Min(value = 1, message = "별점은 1점 이상이어야 합니다.")
                                   @Max(value = 5, message = "별점은 5점 이하여야 합니다.")
                                   Integer score,

                                   @Size(max = 500, message = "후기는 500자 이하로 입력해주세요.")
                                   String comment
) {}