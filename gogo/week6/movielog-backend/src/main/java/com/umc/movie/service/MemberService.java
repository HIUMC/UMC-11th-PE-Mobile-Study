package com.umc.movie.service;

import com.umc.movie.dto.*;
import com.umc.movie.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;
import java.util.List;

@Service
@Transactional(readOnly = true)
public class MemberService {
    private final MemberRepository members;
    private final RatingRepository ratings;
    public MemberService(MemberRepository members, RatingRepository ratings) {
        this.members = members;
        this.ratings = ratings;
    }
    public AvailabilityResponse nickname(String nickname) {
        return new AvailabilityResponse(!members.existsByNickname(nickname.trim()));
    }
    public AvailabilityResponse email(String email) {
        return new AvailabilityResponse(!members.existsByEmail(email.trim()));
    }
    public List<RatingResponse> ratings(Long memberId) {
        if (!members.existsById(memberId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "존재하지 않는 회원입니다.");
        }
        return ratings.findByMember_IdOrderByCreatedAtDescIdDesc(memberId).stream()
                .map(RatingResponse::from).toList();
    }
}
