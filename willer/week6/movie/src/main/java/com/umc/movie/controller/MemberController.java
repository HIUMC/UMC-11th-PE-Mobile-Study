package com.umc.movie.controller;

import com.umc.movie.dto.ApiResponse;
import com.umc.movie.dto.EmailCheckResponse;
import com.umc.movie.dto.MemberResponse;
import com.umc.movie.dto.NicknameCheckResponse;
import com.umc.movie.dto.SignUpRequest;
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
}