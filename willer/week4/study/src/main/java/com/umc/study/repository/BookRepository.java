package com.umc.study.repository;

import com.umc.study.entity.Book;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BookRepository extends JpaRepository<Book, Long> { // <엔티티, PK 타입>. findAll, findById, save 같은 기본 메서드가 자동으로 생김. 구현 클래스는 스프링이 만들어줌

    List<Book> findAllByOrderByBookIdDesc(); // 메서드 이름을 읽고 SQL을 만들어줌. bookId 내림차순 = 최신 등록순

    List<Book> findAllByCategory_CategoryId(Long categoryId); // category 필드 안의 categoryId로 조회. _는 필드 안으로 들어간다는 표시
}