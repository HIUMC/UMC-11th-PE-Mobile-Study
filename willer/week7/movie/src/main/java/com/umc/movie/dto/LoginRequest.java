package com.umc.movie.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record LoginRequest( // 로그인 요청 Body
                            @NotBlank(message = "이메일을 입력해주세요.")
                            @Email(message = "이메일 형식이 올바르지 않습니다.")
                            String email,

                            @NotBlank(message = "비밀번호를 입력해주세요.") // 비밀번호 규칙은 검사하지 않음. 규칙이 바뀌기 전에 가입한 회원도 로그인할 수 있어야 해서
                            String password
) {}