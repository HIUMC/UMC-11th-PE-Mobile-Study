package com.umc.movie.service;

import com.umc.movie.dto.CreateRatingRequest;
import com.umc.movie.dto.RatingResponse;
import com.umc.movie.dto.UpdateRatingRequest;
import com.umc.movie.entity.Member;
import com.umc.movie.entity.Rating;
import com.umc.movie.repository.MemberRepository;
import com.umc.movie.repository.RatingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RatingService {

    private final RatingRepository ratingRepository;
    private final MemberRepository memberRepository; // 회원이 있는지 먼저 확인하려고 같이 받음

    @Transactional(readOnly = true)
    public List<RatingResponse> getRatingsByMember(Long memberId) {
        if (!memberRepository.existsById(memberId)) { // 없는 회원이면 빈 목록 대신 404로 구분
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "존재하지 않는 유저입니다."); // 스프링 기본 예외로 바로 404 응답
        }

        return ratingRepository.findByMember_MemberIdOrderByRatingIdDesc(memberId).stream()
                .map(RatingResponse::from) // 엔티티 하나하나를 응답 DTO로 바꿈
                .toList();
    }

    @Transactional
    public Long create(Long memberId, CreateRatingRequest request) {
        Member member = memberRepository.findById(memberId) // 평점에 연결할 회원 엔티티가 필요해서 exists 대신 find
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "존재하지 않는 유저입니다."));

        // rating 테이블의 (member_id, movie_id) 복합 UNIQUE가 마지막으로 막아주지만, 정해둔 메시지로 응답하려고 먼저 확인
        if (ratingRepository.existsByMember_MemberIdAndMovieId(memberId, request.movieId())) {
            throw new IllegalArgumentException("이미 이 영화에 평점을 남기셨습니다."); // GlobalExceptionHandler가 409로 바꿈
        }

        Rating rating = Rating.builder()
                .member(member)
                .movieId(request.movieId())
                .score(request.score())
                .comment(request.comment())
                .build();

        return ratingRepository.save(rating).getRatingId(); // 저장 후 DB가 매긴 ratingId만 돌려줌
    }

    @Transactional
    public void update(Long ratingId, Long memberId, UpdateRatingRequest request) {
        Rating rating = findOwnedRating(ratingId, memberId);

        rating.update(request.score(), request.comment()); // 트랜잭션 안에서 값을 바꾸면 끝날 때 변경 감지로 UPDATE가 나감
        ratingRepository.save(rating);
    }

    @Transactional
    public void delete(Long ratingId, Long memberId) {
        Rating rating = findOwnedRating(ratingId, memberId);

        ratingRepository.delete(rating);
    }

    // 수정과 삭제가 똑같이 하는 검사를 묶음. 먼저 평점이 있는지(없으면 404), 그다음 주인이 맞는지(아니면 403) 확인
    private Rating findOwnedRating(Long ratingId, Long memberId) {
        Rating rating = ratingRepository.findById(ratingId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "존재하지 않는 평점입니다."));

        if (!rating.getMember().getMemberId().equals(memberId)) { // Long끼리는 ==가 아니라 equals로 값을 비교
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "본인이 작성한 평점만 수정하거나 삭제할 수 있습니다.");
        }

        return rating;
    }
}