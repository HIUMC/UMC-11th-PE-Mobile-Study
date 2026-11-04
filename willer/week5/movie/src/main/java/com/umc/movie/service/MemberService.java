package com.umc.movie.service;

import com.umc.movie.dto.EmailCheckResponse;
import com.umc.movie.dto.NicknameCheckResponse;
import com.umc.movie.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor // final 필드를 받는 생성자를 Lombok이 만들어줌. 스프링이 그 생성자로 Repository를 넣어줌
public class MemberService {

    private final MemberRepository memberRepository;

    @Transactional(readOnly = true) // 조회만 해서 readOnly. 변경 감지를 안 해서 조금 더 가벼움
    public NicknameCheckResponse checkNickname(String nickname) {
        boolean exists = memberRepository.existsByNickname(nickname); // 이미 있으면 true
        return new NicknameCheckResponse(!exists); // 있으면 사용 불가라 뒤집어서 available로 담음
    }

    @Transactional(readOnly = true)
    public EmailCheckResponse checkEmail(String email) {
        boolean exists = memberRepository.existsByEmail(email);
        return new EmailCheckResponse(!exists);
    }
}