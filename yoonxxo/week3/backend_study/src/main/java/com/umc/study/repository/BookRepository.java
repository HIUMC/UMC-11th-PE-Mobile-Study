package com.umc.study.repository;

import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

// 이 클래스를 DB에 접근하는 Repository로 Spring에 등록
@Repository
@RequiredArgsConstructor
public class BookRepository {

    // Spring이 만들어 둔 DB 통신 도구를 주입받음
    private final JdbcTemplate jdbcTemplate;

    // DB의 book 테이블에 있는 모든 데이터를 조회
    public List<Map<String, Object>> findAll() {

        // Workbench에서 직접 실행했던 SQL과 동일
        String sql = "SELECT * FROM book";

        // SQL 실행 결과를 List<Map> 형태로 반환
        return jdbcTemplate.queryForList(sql);
    }
    // 책 추가
    public void save(Map<String, Object> body){
        // book_id는 AUTO_INCREMENT이므로 생략, is_available은 기본 true로 삽입
        String sql = "INSERT INTO book (category_id, title, description, is_available) VALUES (?, ?, ?, true)";

        // SQL 뒤에 파라미터를 차례대로 넘겨주면 ? 자리에 순서대로 안전하게 바인딩됩니다.
        jdbcTemplate.update(
                sql,
                body.get("categoryId"),
                body.get("title"),
                body.get("description")
        );
    }
    // 특정 카테고리에 속한 도서만 조회
    public List<Map<String, Object>> findByCategoryId(Long categoryId) {

        // category_id가 전달받은 값과 같은 책만 조회
        String sql = "SELECT * FROM book WHERE category_id = ?";

        // ? 자리에 categoryId를 안전하게 바인딩
        return jdbcTemplate.queryForList(sql, categoryId);
    }
}