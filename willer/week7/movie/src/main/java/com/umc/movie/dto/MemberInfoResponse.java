package com.umc.movie.dto;

import com.umc.movie.entity.Member;

import java.time.LocalDateTime;

public record MemberInfoResponse( // 내 정보 조회, 수정 응답. password는 일부러 뺌
                                  String email,
                                  String nickname,
                                  LocalDateTime createdAt
) {
    public static MemberInfoResponse from(Member member) { // 엔티티를 그대로 응답하면 password까지 나가서 DTO로 옮겨 담음
        return new MemberInfoResponse(
                member.getEmail(),
                member.getNickname(),
                member.getCreatedAt()
        );
    }
}