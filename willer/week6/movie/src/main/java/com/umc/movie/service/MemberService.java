package com.umc.movie.service;

import com.umc.movie.dto.EmailCheckResponse;
import com.umc.movie.dto.MemberResponse;
import com.umc.movie.dto.NicknameCheckResponse;
import com.umc.movie.dto.SignUpRequest;
import com.umc.movie.entity.Member;
import com.umc.movie.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor // final 필드를 받는 생성자를 Lombok이 만들어줌. 스프링이 그 생성자로 Repository를 넣어줌
public class MemberService {

    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder; // PasswordConfig에서 등록한 BCryptPasswordEncoder가 들어옴

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

    @Transactional // 저장이 있어서 readOnly를 뺌
    public MemberResponse signUp(SignUpRequest request) {
        if (memberRepository.existsByEmail(request.email())) { // 저장 전에 중복을 먼저 확인해서 원하는 메시지로 응답
            throw new IllegalArgumentException("이미 사용 중인 이메일입니다.");
        }
        if (memberRepository.existsByNickname(request.nickname())) {
            throw new IllegalArgumentException("이미 사용 중인 닉네임입니다.");
        }

        Member member = Member.builder()
                .email(request.email())
                .password(passwordEncoder.encode(request.password())) // 평문 대신 bcrypt 해시를 저장
                .nickname(request.nickname())
                .build();

        Member savedMember = memberRepository.save(member); // 저장하면 DB가 매긴 memberId가 채워짐
        return new MemberResponse(savedMember.getMemberId(), savedMember.getEmail(), savedMember.getNickname()); // password는 빼고 응답
    }
}