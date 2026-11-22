package com.umc.movie.service;

import com.umc.movie.dto.CreateRatingRequest;
import com.umc.movie.dto.RatingResponse;
import com.umc.movie.dto.UpdateRatingRequest;
import com.umc.movie.entity.Member;
import com.umc.movie.entity.Rating;
import com.umc.movie.exception.ApiException;
import com.umc.movie.repository.MemberRepository;
import com.umc.movie.repository.RatingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RatingService {

    private final RatingRepository ratingRepository;
    private final MemberRepository memberRepository; // 회원이 있는지 먼저 확인하려고 같이 받음

    @Transactional(readOnly = true)
    public List<RatingResponse> getRatingsByMember(Long memberId) {
        if (!memberRepository.existsById(memberId)) { // 없는 회원이면 빈 목록 대신 404로 구분
            throw new ApiException(HttpStatus.NOT_FOUND, "MEMBER404_1", "해당 회원을 찾을 수 없습니다.");
        }

        return ratingRepository.findByMember_MemberIdOrderByRatingIdDesc(memberId).stream()
                .map(RatingResponse::from) // 엔티티 하나하나를 응답 DTO로 바꿈
                .toList();
    }

    @Transactional
    public RatingResponse create(Long memberId, CreateRatingRequest request) { // memberId는 토큰에서 꺼낸 값. 인자 순서를 누가, 무엇을로 통일
        Member member = memberRepository.findById(memberId) // 평점에 연결할 회원 엔티티가 필요해서 exists 대신 find
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "MEMBER404_1", "해당 회원을 찾을 수 없습니다."));

        // rating 테이블의 (member_id, movie_id) 복합 UNIQUE가 마지막으로 막아주지만, 정해둔 code로 응답하려고 먼저 확인
        if (ratingRepository.existsByMember_MemberIdAndMovieId(memberId, request.movieId())) {
            throw new ApiException(HttpStatus.CONFLICT, "RATING409_1", "이미 이 영화에 평점을 남기셨습니다.");
        }

        Rating rating = Rating.builder()
                .member(member)
                .movieId(request.movieId())
                .score(request.score())
                .comment(request.comment())
                .build();

        return RatingResponse.from(ratingRepository.save(rating)); // ratingId 숫자만이 아니라 저장된 평점 전체를 돌려줌
    }

    @Transactional
    public RatingResponse update(Long memberId, Long ratingId, UpdateRatingRequest request) {
        Rating rating = findOwnedRating(memberId, ratingId);

        rating.update(request.score(), request.comment()); // 트랜잭션 안에서 값을 바꾸면 끝날 때 변경 감지로 UPDATE가 나감
        ratingRepository.save(rating);

        return RatingResponse.from(rating);
    }

    @Transactional
    public void delete(Long memberId, Long ratingId) {
        Rating rating = findOwnedRating(memberId, ratingId);

        ratingRepository.delete(rating);
    }

    // 수정과 삭제가 똑같이 하는 인가 검사. 인증은 인터셉터, 이 평점이 내 것인지는 DB를 봐야 알아서 Service가 맡음
    // 먼저 평점이 있는지(없으면 404), 그다음 주인이 맞는지(아니면 403) 확인. 순서가 반대면 없는 평점에 권한 없음이라고 답하게 됨
    private Rating findOwnedRating(Long memberId, Long ratingId) {
        Rating rating = ratingRepository.findById(ratingId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "RATING404_1", "해당 평점을 찾을 수 없습니다."));

        if (!rating.getMember().getMemberId().equals(memberId)) { // Long끼리는 ==가 아니라 equals로 값을 비교
            throw new ApiException(HttpStatus.FORBIDDEN, "RATING403_1", "본인이 작성한 평점만 수정하거나 삭제할 수 있습니다.");
        }

        return rating;
    }
}