package com.umc.study.repository;

import com.umc.study.entity.Book;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BookJpaRepository extends JpaRepository<Book, Long> {

    // 모든 도서를 bookId 기준 최신순으로 조회
    List<Book> findAllByOrderByBookIdDesc();

    // 특정 카테고리에 속한 도서를 조회
    List<Book> findByCategory_CategoryId(Long categoryId);
}