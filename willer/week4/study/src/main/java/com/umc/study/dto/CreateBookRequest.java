package com.umc.study.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CreateBookRequest( // 도서 등록 요청 Body의 모양. record는 값만 담는 불변 클래스라 생성자·getter를 자동으로 만들어줌
                                 @NotNull Long categoryId, // 빠지면 400
                                 @NotBlank @Size(max = 100) String title, // 비어 있거나 공백만 있거나 100자를 넘으면 400
                                 String description // 선택 값. 없으면 null
) {}