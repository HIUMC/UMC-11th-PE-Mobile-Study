package com.umc.movie.dto;

import com.umc.movie.entity.Rating;

import java.time.LocalDateTime;

public record RatingResponse( // 평점 하나의 응답 모양. API 명세의 필드 이름과 똑같이 맞춤
                              Long ratingId,
                              Long movieId,
                              Integer score,
                              String comment,
                              LocalDateTime createdAt,
                              LocalDateTime updatedAt
) {
    public static RatingResponse from(Rating rating) { // 엔티티를 응답 DTO로 바꾸는 정적 팩토리 메서드. Member 정보는 빼고 필요한 값만 담음
        return new RatingResponse(
                rating.getRatingId(),
                rating.getMovieId(),
                rating.getScore(),
                rating.getComment(),
                rating.getCreatedAt(), // BaseTimeEntity의 @Getter 덕분에 쓸 수 있음
                rating.getUpdatedAt()
        );
    }
}