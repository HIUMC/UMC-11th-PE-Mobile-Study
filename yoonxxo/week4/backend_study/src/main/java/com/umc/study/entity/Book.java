package com.umc.study.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "book")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Book {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "book_id")
    private Long bookId; // 도서의 PK

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category; // 여러 도서가 하나의 카테고리에 속함

    @Column(nullable = false, length = 100)
    private String title; // 도서 제목

    @Column(columnDefinition = "TEXT")
    private String description; // 도서 설명

    @Column(name = "is_available", nullable = false)
    private Boolean isAvailable = true; // 대여 가능 여부

    // 새로운 도서를 만들 때 사용하는 생성자
    public Book(Category category, String title, String description) {
        this.category = category;
        this.title = title;
        this.description = description;
    }
}