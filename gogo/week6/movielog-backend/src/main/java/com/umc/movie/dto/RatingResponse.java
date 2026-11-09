package com.umc.movie.dto;
import com.umc.movie.entity.Rating;
import java.time.LocalDateTime;

public record RatingResponse(Long ratingId, Long movieId, Byte score, String comment,
                             LocalDateTime createdAt, LocalDateTime updatedAt) {
    public static RatingResponse from(Rating r) {
        return new RatingResponse(r.getId(), r.getMovieId(), r.getScore(), r.getComment(),
                r.getCreatedAt(), r.getUpdatedAt());
    }
}
