package com.umc.movie.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record SignUpRequest( // 회원가입 요청 Body. 규칙을 어기면 Controller까지 오기 전에 400으로 막힘
                             @NotBlank(message = "이메일을 입력해주세요.")
                             @Email(message = "올바른 이메일 형식이 아닙니다.")
                             String email,

                             @NotBlank(message = "비밀번호를 입력해주세요.")
                             @Pattern(
                                     regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*]).{8,}$", // (?=.*x)는 x가 어딘가에 하나 이상 있어야 한다는 조건. 소문자, 대문자, 숫자, 특수문자를 각각 확인하고 전체 8자 이상
                                     message = "비밀번호는 대문자/소문자/숫자/특수문자를 포함한 8자 이상이어야 합니다."
                             )
                             String password,

                             @NotBlank(message = "닉네임을 입력해주세요.")
                             @Size(min = 2, max = 12, message = "닉네임은 2자 이상 12자 이하로 입력해주세요.")
                             String nickname
) {}