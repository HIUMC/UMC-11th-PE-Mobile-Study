package com.umc.movie.controller;

import com.umc.movie.dto.ApiResponse;
import com.umc.movie.dto.CreateRatingRequest;
import com.umc.movie.dto.RatingResponse;
import com.umc.movie.dto.UpdateRatingRequest;
import com.umc.movie.interceptor.AuthInterceptor;
import com.umc.movie.service.RatingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor // 클래스의 @RequestMapping("/members")를 지움. 남아 있으면 /members/ratings가 돼서 404
public class RatingController {

    private final RatingService ratingService;

    @GetMapping("/members/{memberId}/ratings") // 누구나 볼 수 있는 공개 목록이라 토큰 없이 그대로 둠. 클래스 매핑이 없어서 전체 경로로 적음
    public List<RatingResponse> getMemberRatings(@PathVariable Long memberId) { // 주소의 숫자를 Long으로 바꿔서 받음
        return ratingService.getRatingsByMember(memberId);
    }

    @PostMapping("/ratings") // POST /ratings. 주소에서 memberId가 사라져서 클라이언트가 바꿔 보낼 수 없음
    public ResponseEntity<ApiResponse<RatingResponse>> create(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId, // 인터셉터가 토큰에서 꺼내 담아둔 값
            @Valid @RequestBody CreateRatingRequest request // 요청 Body는 그대로. 원래 memberId를 Body로 받지 않았음
    ) {
        RatingResponse response = ratingService.create(memberId, request);
        return ResponseEntity.status(201).body(ApiResponse.created("평점을 등록했습니다.", response));
    }

    @PatchMapping("/ratings/{ratingId}") // PATCH는 일부만 고칠 때 쓰는 메서드. @PathVariable memberId는 지워서 값의 출처가 토큰 하나뿐
    public ResponseEntity<ApiResponse<RatingResponse>> update(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @PathVariable Long ratingId,
            @Valid @RequestBody UpdateRatingRequest request
    ) {
        RatingResponse response = ratingService.update(memberId, ratingId, request);
        return ResponseEntity.ok(ApiResponse.ok("평점을 수정했습니다.", response));
    }

    @DeleteMapping("/ratings/{ratingId}")
    public ResponseEntity<ApiResponse<Void>> delete(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @PathVariable Long ratingId
    ) {
        ratingService.delete(memberId, ratingId);
        return ResponseEntity.ok(ApiResponse.ok("평점을 삭제했습니다.", null)); // 204는 Body를 못 실어서 200과 공통 응답으로 바꿈. result는 null
    }
}