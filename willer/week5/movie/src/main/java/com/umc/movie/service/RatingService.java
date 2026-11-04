package com.umc.movie.service;

import com.umc.movie.dto.RatingResponse;
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
}