package com.umc.movie.controller;

import com.umc.movie.dto.EmailCheckResponse;
import com.umc.movie.dto.NicknameCheckResponse;
import com.umc.movie.service.MemberService;
import lombok.RequiredArgsConstructor;
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
}