package com.umc.study.service;

import com.umc.study.dto.BookResponse;
import com.umc.study.dto.CreateBookRequest;
import com.umc.study.entity.Book;
import com.umc.study.entity.Category;
import com.umc.study.repository.BookJpaRepository;
import com.umc.study.repository.BookRepository;
import com.umc.study.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

// 비즈니스 로직을 담당하는 Service
@Service
@RequiredArgsConstructor
public class BookService {

    // BookRepository를 Spring이 자동으로 넣어줌
    private final BookRepository bookRepository;

    // JPA를 사용하는 Repository
    private final BookJpaRepository bookJpaRepository;

    // Category를 조회하기 위한 JPA Repository
    private final CategoryRepository categoryRepository;

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

    // ==================== Week 4 JPA/ORM ====================

    // JPA를 사용해서 전체 도서를 최신 등록순으로 조회
    @Transactional(readOnly = true)
    public List<BookResponse> getAllBooksJpa() {

        // bookId가 큰 순서대로 도서를 조회
        List<Book> books = bookJpaRepository.findAllByOrderByBookIdDesc();

        // Entity를 API 응답용 DTO로 변환
        return books.stream()
                .map(BookResponse::from)
                .toList();
    }

    // JPA를 사용해서 새로운 도서를 등록
    @Transactional
    public BookResponse createBook(CreateBookRequest request) {

        // 요청으로 받은 categoryId로 카테고리를 조회
        Category category = categoryRepository.findById(request.categoryId())
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 카테고리입니다."));

        // 조회한 카테고리와 요청 데이터를 이용해서 Book Entity 생성
        Book book = new Book(
                category,
                request.title(),
                request.description()
        );

        // JPA를 통해 DB에 저장
        Book savedBook = bookJpaRepository.save(book);

        // 저장된 Entity를 응답 DTO로 변환
        return BookResponse.from(savedBook);
    }
}