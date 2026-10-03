package com.umc.study.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
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
    private Long bookId;

    @ManyToOne(fetch = FetchType.LAZY) // 책 여러 권이 카테고리 하나에 속함. LAZY는 카테고리를 실제로 꺼내 쓸 때 조회
    @JoinColumn(name = "category_id", nullable = false) // FK 컬럼. 숫자 대신 Category 객체로 들고 있음
    private Category category;

    @Column(nullable = false, length = 100) // NOT NULL, varchar(100)
    private String title;

    @Column(columnDefinition = "TEXT") // text 타입. NULL 허용
    private String description;

    @Column(name = "is_available", nullable = false) // tinyint(1)을 true/false로 다룸
    private Boolean isAvailable = true; // 새 책은 대여 가능으로 시작

    public Book(Category category, String title, String description) { // 새 책을 만들 때 쓰는 생성자. id와 대여 여부는 받지 않음
        this.category = category;
        this.title = title;
        this.description = description;
    }
}