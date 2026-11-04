package com.umc.movie.repository;
import com.umc.movie.entity.Rating;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface RatingRepository extends JpaRepository<Rating, Long> {
    boolean existsByMember_IdAndMovieId(Long memberId, Long movieId);
    List<Rating> findByMember_IdOrderByCreatedAtDescIdDesc(Long memberId);
}
