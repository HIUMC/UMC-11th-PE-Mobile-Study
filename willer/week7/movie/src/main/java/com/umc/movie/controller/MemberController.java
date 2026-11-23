package com.umc.movie.controller;

import com.umc.movie.dto.ApiResponse;
import com.umc.movie.dto.EmailCheckResponse;
import com.umc.movie.dto.MemberInfoResponse;
import com.umc.movie.dto.MemberResponse;
import com.umc.movie.dto.MemberUpdateRequest;
import com.umc.movie.dto.NicknameCheckResponse;
import com.umc.movie.dto.SignUpRequest;
import com.umc.movie.interceptor.AuthInterceptor;
import com.umc.movie.service.MemberService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController // 반환한 객체를 JSON으로 바꿔 응답 Body에 담음
@RequiredArgsConstructor
@RequestMapping("/members") // 이 클래스의 모든 주소 앞에 /members가 붙음
public class MemberController {

    private final MemberService memberService;

    @GetMapping("/nickname/{nickname}") // GET /members/nickname/수현
    public NicknameCheckResponse checkNickname(@PathVariable String nickname) { // 주소의 {nickname} 자리 값을 꺼냄
        return memberService.checkNickname(nickname);
    }

    @GetMapping("/email/{email}") // GET /members/email/noco@umc.com
    public EmailCheckResponse checkEmail(@PathVariable String email) {
        return memberService.checkEmail(email);
    }

    @PostMapping // POST /members
    public ResponseEntity<ApiResponse<MemberResponse>> signUp( // ResponseEntity로 감싸야 상태 코드를 201로 바꿀 수 있음
                                                               @Valid @RequestBody SignUpRequest request // @RequestBody는 JSON Body를 DTO로 바꿈. @Valid가 있어야 DTO의 검증 규칙이 실행됨
    ) {
        MemberResponse response = memberService.signUp(request);
        return ResponseEntity.status(201)
                .body(ApiResponse.created("회원가입에 성공했습니다.", response));
    }

    @GetMapping("/me") // GET /members/me. 주소에 누구인지가 없고 토큰이 알려줌
    public ResponseEntity<ApiResponse<MemberInfoResponse>> getMyInfo(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId // 인터셉터가 setAttribute로 담아둔 값을 꺼냄
    ) {
        MemberInfoResponse response = memberService.getMyInfo(memberId);
        return ResponseEntity.ok(ApiResponse.ok("회원 정보를 조회했습니다.", response));
    }

    @PatchMapping("/me") // PATCH /members/me
    public ResponseEntity<ApiResponse<MemberInfoResponse>> updateMyInfo(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @Valid @RequestBody MemberUpdateRequest request
    ) {
        MemberInfoResponse response = memberService.updateMyInfo(memberId, request);
        return ResponseEntity.ok(ApiResponse.ok("회원 정보를 수정했습니다.", response));
    }
}