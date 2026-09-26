package com.umc.study.repository; // 이 파일이 속한 패키지(폴더) 위치

import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate; // 스프링이 만들어둔 SQL 실행 도구
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository // 스프링에 "나 창고지기(DB 담당)야" 하고 등록. 서버가 켜질 때 스프링이 객체를 만들어 보관함
@RequiredArgsConstructor // final 필드를 받는 생성자를 Lombok이 대신 만들어줌. 스프링이 이 생성자로 JdbcTemplate을 넣어줌
public class BookRepository {

    private final JdbcTemplate jdbcTemplate; // 스프링이 application.yml을 읽고 만들어둔 도구. 커넥션 풀에서 연결을 빌려 SQL을 실행함

    public List<Map<String, Object>> findAll() { // 모든 도서를 조회. 한 행이 Map 하나, 여러 행이라 List
        String sql = "SELECT * FROM book"; // 2주차 Workbench에서 손으로 실행하던 쿼리를 문자열로 그대로 씀

        return jdbcTemplate.queryForList(sql); // 쿼리를 실행하고 결과를 List<Map>으로 돌려줌. Map의 Key는 컬럼명(title), Value는 실제 값(달빛 도서관)
    }

    public List<Map<String, Object>> findByCategoryId(Long categoryId) { // 특정 카테고리의 도서만 조회
        String sql = "SELECT * FROM book WHERE category_id = ?"; // 조건 값 자리도 ?로 뚫어둠. 주소에서 온 값도 사용자 입력이라 이어 붙이지 않음

        return jdbcTemplate.queryForList(sql, categoryId); // SQL 뒤에 넘긴 값이 ? 자리에 바인딩됨. 해당하는 책이 없으면 빈 리스트
    }

    public void save(Map<String, Object> body) { // 새 도서를 저장. 요청 Body(JSON)가 Map으로 들어옴
        String sql = "INSERT INTO book (category_id, title, description, is_available) VALUES (?, ?, ?, true)"; // book_id는 AUTO_INCREMENT라 생략. 새 책은 대여 가능(true)으로 고정. 나머지 값 자리는 ?로 뚫어둠

        jdbcTemplate.update( // INSERT, UPDATE, DELETE처럼 데이터를 바꾸는 쿼리는 update로 실행
                sql,
                body.get("categoryId"), // 첫 번째 ? 자리. SQL 문자열에 이어 붙이지 않고 따로 넘겨서 SQL Injection을 막음
                body.get("title"), // 두 번째 ? 자리. 순서가 컬럼 순서와 정확히 맞아야 함
                body.get("description") // 세 번째 ? 자리
        );
    }
}