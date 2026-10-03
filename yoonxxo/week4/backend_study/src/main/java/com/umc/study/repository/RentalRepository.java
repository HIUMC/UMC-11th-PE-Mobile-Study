package com.umc.study.repository;

import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.Map;

@Repository
@RequiredArgsConstructor
public class RentalRepository {

    // Spring이 준비한 DB 통신 도구
    private final JdbcTemplate jdbcTemplate;

    // 신규 대여 기록 저장
    public void save(Map<String, Object> body) {

        // rented_at : 현재 시간
        // due_at    : 현재 시간으로부터 7일 뒤
        String sql =
                "INSERT INTO rental (user_id, book_id, rented_at, due_at) " +
                        "VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY))";

        // 첫 번째 ? -> userId
        // 두 번째 ? -> bookId
        jdbcTemplate.update(
                sql,
                body.get("userId"),
                body.get("bookId")
        );
    }
}