package com.umc.study.controller;

import com.umc.study.service.BookService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController // 스프링에 "나 웨이터(요청 받고 응답하는 API)야" 하고 등록. 반환값을 자동으로 JSON으로 바꿔서 응답
@RequestMapping("/books") // 이 컨트롤러가 맡는 기본 주소. 아래 메서드들은 전부 /books로 시작
@RequiredArgsConstructor
public class BookController {

    private final BookService bookService; // 셰프. 컨트롤러는 직접 요리(로직)하지 않고 서비스에 넘김

    @GetMapping // HTTP GET 방식으로 /books 요청이 오면 이 메서드가 실행됨
    public List<Map<String, Object>> getBooks() {
        return bookService.getAllBooks(); // 서비스가 준 List<Map>을 그대로 반환. @RestController 덕분에 JSON 배열로 바뀌어 응답됨
    }

    @GetMapping("/category/{categoryId}") // 기본 주소 /books 뒤에 붙음. 최종 주소는 /books/category/{categoryId}. {}는 빈칸
    public List<Map<String, Object>> getBooksByCategory(@PathVariable Long categoryId) { // 주소의 {categoryId} 빈칸 값을 꺼내 Long으로 바꿔 넣어줌. 이름이 빈칸 이름과 같아야 함
        return bookService.getBooksByCategory(categoryId);
    }

    @PostMapping // HTTP POST 방식으로 /books 요청이 오면 이 메서드가 실행됨. 같은 주소라도 GET과 POST는 다른 메서드로 연결됨
    public String createBook(@RequestBody Map<String, Object> body) { // @RequestBody는 요청 본문의 JSON을 Map으로 바꿔서 넣어줌
        bookService.createBook(body);
        return "도서 등록이 완료되었습니다!"; // 등록 결과는 안내 문구만 응답
    }
}