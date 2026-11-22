package com.umc.movie.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record MemberUpdateRequest( // 내 정보 수정 요청 Body. 지금은 닉네임만 바꿀 수 있음
                                   @NotBlank(message = "닉네임을 입력해주세요.")
                                   @Size(min = 2, max = 12, message = "닉네임은 2자 이상 12자 이하여야 합니다.")
                                   String nickname
) {}