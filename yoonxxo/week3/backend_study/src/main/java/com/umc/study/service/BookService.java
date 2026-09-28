package com.umc.study.service;

import com.umc.study.repository.BookRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

// 비즈니스 로직을 담당하는 Service
@Service
@RequiredArgsConstructor
public class BookService {

    // BookRepository를 Spring이 자동으로 넣어줌
    private final BookRepository bookRepository;

    // 전체 책 목록 조회
    public List<Map<String, Object>> getAllBooks() {

        // Repository에게 DB 조회 요청
        return bookRepository.findAll();
    }
    // 새로 추가: 도서 등록
    public void createBook(Map<String, Object> body) {

        // Repository에게 실제 INSERT 작업을 맡김
        bookRepository.save(body);
    }
    // 특정 카테고리의 도서 목록 조회
    public List<Map<String, Object>> getBooksByCategory(Long categoryId) {

        // Repository에게 해당 categoryId의 책만 가져오도록 요청
        return bookRepository.findByCategoryId(categoryId);
    }
}