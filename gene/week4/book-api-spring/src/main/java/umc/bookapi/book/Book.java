package umc.bookapi.book;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import umc.bookapi.category.Category;

@Entity
@Table(name = "book")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Book {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "book_id")
    private Long bookId; // PK

    @Column(nullable = false, length = 100)
    private String title;

    @Column(length = 500)
    private String description;

    // 대여 가능 여부 — 새로 등록한 책은 대여 가능
    @Column(name = "is_available", nullable = false)
    private Boolean isAvailable;

    // N(Book) : 1(Category) — book.category_id(FK) 가 category.id(PK) 를 참조
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    public Book(String title, String description, Category category) {
        this.title = title;
        this.description = description;
        this.isAvailable = true;
        this.category = category;
    }
}
