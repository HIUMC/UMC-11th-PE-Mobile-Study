package com.umc.movie.controller;

import com.umc.movie.dto.RatingResponse;
import com.umc.movie.service.RatingService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/members") // 평점이 회원에 속한 자원이라 주소도 /members 아래
public class RatingController {

    private final RatingService ratingService;

    @GetMapping("/{memberId}/ratings") // GET /members/1/ratings
    public List<RatingResponse> getMemberRatings(@PathVariable Long memberId) { // 주소의 숫자를 Long으로 바꿔서 받음
        return ratingService.getRatingsByMember(memberId);
    }
}