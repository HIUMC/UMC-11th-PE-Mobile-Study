package com.umc.movie.controller;

import com.umc.movie.dto.ApiResponse;
import com.umc.movie.dto.CreateRatingRequest;
import com.umc.movie.dto.RatingResponse;
import com.umc.movie.dto.UpdateRatingRequest;
import com.umc.movie.service.RatingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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

    @PostMapping("/{memberId}/ratings") // POST /members/1/ratings
    public ResponseEntity<ApiResponse<Long>> create(
            @PathVariable Long memberId, // 로그인이 없어서 누구의 요청인지 주소로 받음
            @Valid @RequestBody CreateRatingRequest request
    ) {
        Long ratingId = ratingService.create(memberId, request);
        return ResponseEntity.status(201).body(ApiResponse.created("평점 등록에 성공했습니다.", ratingId)); // result에 새 ratingId
    }

    @PatchMapping("/{memberId}/ratings/{ratingId}") // PATCH는 일부만 고칠 때 쓰는 메서드
    public ResponseEntity<ApiResponse<Void>> update(
            @PathVariable Long memberId,
            @PathVariable Long ratingId,
            @Valid @RequestBody UpdateRatingRequest request
    ) {
        ratingService.update(ratingId, memberId, request);
        return ResponseEntity.ok(ApiResponse.ok("평점 수정에 성공했습니다.", null)); // 200. 돌려줄 값이 없어서 result는 null
    }

    @DeleteMapping("/{memberId}/ratings/{ratingId}")
    public ResponseEntity<Void> delete(@PathVariable Long memberId, @PathVariable Long ratingId) {
        ratingService.delete(ratingId, memberId);
        return ResponseEntity.noContent().build(); // 204. Body 없이 상태 코드만 보냄
    }
}