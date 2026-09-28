package com.umc.study.service;

import com.umc.study.repository.BookRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service // 스프링에 "나 셰프(비즈니스 로직 담당)야" 하고 등록
@RequiredArgsConstructor // final 필드(BookRepository)를 받는 생성자를 Lombok이 만들어줌. 스프링이 보관 중인 BookRepository를 넣어줌
public class BookService {

    private final BookRepository bookRepository; // 창고지기. 서비스는 SQL을 직접 쓰지 않고 Repository에 시킴

    public List<Map<String, Object>> getAllBooks() {
        return bookRepository.findAll(); // 지금은 규칙이 없어서 창고지기가 가져온 목록을 그대로 넘김. 나중에 비즈니스 규칙이 들어갈 자리
    }

    public List<Map<String, Object>> getBooksByCategory(Long categoryId) {
        return bookRepository.findByCategoryId(categoryId); // 받은 카테고리 id를 창고지기에게 넘겨 조회
    }

    public void createBook(Map<String, Object> body) {
        bookRepository.save(body); // 받은 Body를 그대로 창고지기에게 넘겨 저장. 값 검증 같은 규칙은 아직 없음
    }
}