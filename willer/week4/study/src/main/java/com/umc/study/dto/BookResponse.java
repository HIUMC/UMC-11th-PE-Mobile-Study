package com.umc.study.dto;

import com.umc.study.entity.Book;

public record BookResponse( // 응답 JSON의 모양. 엔티티를 그대로 보내지 않고 필요한 값만 골라 보냄
                            Long bookId,
                            String title,
                            String description,
                            String categoryName, // FK 숫자 대신 카테고리 이름
                            Boolean isAvailable
) {
    public static BookResponse from(Book book) { // 엔티티를 응답 DTO로 바꾸는 정적 메서드
        return new BookResponse(
                book.getBookId(),
                book.getTitle(),
                book.getDescription(),
                book.getCategory().getName(), // LAZY라 이 순간 카테고리를 조회. 트랜잭션 안에서 호출돼야 함
                book.getIsAvailable()
        );
    }
}