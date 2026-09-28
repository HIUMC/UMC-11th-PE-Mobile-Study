package com.umc.study.controller;

import com.umc.study.service.BookService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;
import java.util.Map;

// HTTP 요청을 받는 Controller
@RestController // 1. "나는 데이터를 JSON으로 서빙하는 API 카운터야!"
@RequestMapping("/books") // 2. 이 컨트롤러로 들어오는 요청의 기본 주소는 /books
@RequiredArgsConstructor
public class BookController {

    // BookService를 Spring이 자동으로 주입
    private final BookService bookService;

    // GET /books 요청을 처리
    @GetMapping
    public List<Map<String, Object>> getBooks() {

        // Service에게 전체 책 목록을 요청
        return bookService.getAllBooks();
    }
    // POST / books 요청을 처리
    @PostMapping
    public String createBook(@RequestBody Map<String, Object> body){
        // Postman에서 받은 JSON 데이터를 Service로 전달
        bookService.createBook(body);
        return "도서 등록이 완료되었습니다!";
    }
    // GET /books/category/{categoryId}
    // URL 경로에 들어온 categoryId를 받아 해당 카테고리 도서 조회
    @GetMapping("/category/{categoryId}")
    public List<Map<String, Object>> getBooksByCategory(
            @PathVariable Long categoryId
    ) {
        return bookService.getBooksByCategory(categoryId);
    }
}