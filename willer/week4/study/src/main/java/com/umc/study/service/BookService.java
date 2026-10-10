package com.umc.study.service;

import com.umc.study.dto.BookResponse;
import com.umc.study.dto.CreateBookRequest;
import com.umc.study.entity.Book;
import com.umc.study.entity.Category;
import com.umc.study.repository.BookRepository;
import com.umc.study.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BookService {

    private final BookRepository bookRepository;
    private final CategoryRepository categoryRepository;

    @Transactional(readOnly = true) // 조회 전용 트랜잭션. 변경 감지를 안 해서 가벼움. DTO 변환(카테고리 조회)까지 이 안에서 끝남
    public List<BookResponse> getBooks() {
        return bookRepository.findAllByOrderByBookIdDesc().stream() // 엔티티 목록을 하나씩 흘려보냄
                .map(BookResponse::from) // 하나씩 응답 DTO로 변환
                .toList();
    }

    @Transactional(readOnly = true)
    public List<BookResponse> getBooksByCategory(Long categoryId) {
        return bookRepository.findAllByCategory_CategoryId(categoryId).stream()
                .map(BookResponse::from)
                .toList();
    }

    @Transactional // 저장 작업. 중간에 예외가 나면 전부 되돌림
    public BookResponse createBook(CreateBookRequest request) {
        Category category = categoryRepository.findById(request.categoryId()) // 카테고리가 실제로 있는지 먼저 확인. 결과는 Optional
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 카테고리입니다.")); // 없으면 저장하지 않고 예외

        Book book = new Book(category, request.title(), request.description()); // FK 숫자 대신 조회한 Category 객체를 넣음
        return BookResponse.from(bookRepository.save(book)); // INSERT 후 id가 채워진 엔티티를 DTO로 바꿔 반환
    }
}