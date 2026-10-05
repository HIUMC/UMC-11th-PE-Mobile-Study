package umc.bookapi.book;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BookRepository extends JpaRepository<Book, Long> {

    // 목록 조회 시 카테고리를 함께 가져와 N+1 방지
    @EntityGraph(attributePaths = "category")
    List<Book> findAllByOrderByBookIdAsc();
}
