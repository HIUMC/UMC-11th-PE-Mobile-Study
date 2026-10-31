package com.umc.movie.repository;

import com.umc.movie.entity.Rating;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RatingRepository extends JpaRepository<Rating, Long> {
    List<Rating> findByMember_MemberIdOrderByRatingIdDesc(Long memberId); // Member_MemberId는 rating.member의 memberId로 찾으라는 뜻. ratingId 큰 순서(최신순)로 정렬
}