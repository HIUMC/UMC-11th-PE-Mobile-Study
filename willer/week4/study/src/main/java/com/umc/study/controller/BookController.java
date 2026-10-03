package com.umc.study.controller;

import com.umc.study.dto.BookResponse;
import com.umc.study.dto.CreateBookRequest;
import com.umc.study.service.BookService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController // 반환값을 자동으로 JSON으로 바꿔서 응답
@RequestMapping("/books") // 아래 메서드들은 전부 /books로 시작
@RequiredArgsConstructor
public class BookController {

    private final BookService bookService;

    @GetMapping // GET /books
    public List<BookResponse> getBooks() {
        return bookService.getBooks();
    }

    @GetMapping("/category/{categoryId}") // GET /books/category/{categoryId}
    public List<BookResponse> getBooksByCategory(@PathVariable Long categoryId) {
        return bookService.getBooksByCategory(categoryId);
    }

    @PostMapping // POST /books
    @ResponseStatus(HttpStatus.CREATED) // 성공하면 200 대신 201
    public BookResponse createBook(@Valid @RequestBody CreateBookRequest request) { // @Valid가 DTO의 검증 규칙을 Service에 닿기 전에 검사. 실패하면 400
        return bookService.createBook(request);
    }

    @ExceptionHandler(IllegalArgumentException.class) // 이 컨트롤러의 요청 처리 중 IllegalArgumentException이 나면 500 대신 여기로 옴
    @ResponseStatus(HttpStatus.NOT_FOUND) // 찾는 카테고리가 없다는 뜻으로 404
    public Map<String, String> handleIllegalArgument(IllegalArgumentException e) {
        return Map.of("message", e.getMessage()); // {"message": "존재하지 않는 카테고리입니다."}. 내부 StackTrace 대신 안내 문구만 응답
    }
}