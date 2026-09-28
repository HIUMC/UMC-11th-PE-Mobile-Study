package com.umc.study.repository;

import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.Map;

@Repository // 스프링에 "나 창고지기(DB 담당)야" 하고 등록. rental 테이블 전담
@RequiredArgsConstructor // final 필드를 받는 생성자를 Lombok이 대신 만들어줌. 스프링이 이 생성자로 JdbcTemplate을 넣어줌
public class RentalRepository {

    private final JdbcTemplate jdbcTemplate; // BookRepository와 같은 JdbcTemplate을 스프링이 넣어줌. 커넥션 풀도 같이 씀

    public void save(Map<String, Object> body) { // 새 대여 기록을 저장. 요청 Body(JSON)가 Map으로 들어옴
        String sql = "INSERT INTO rental (user_id, book_id, rented_at, due_at) " // rental_id는 AUTO_INCREMENT, returned_at은 NULL 허용이라 둘 다 생략
                + "VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY))"; // 사용자 값은 ?로 바인딩. 대여일은 지금, 반납 예정일은 7일 뒤를 DB 함수로 계산

        jdbcTemplate.update( // 데이터를 바꾸는 INSERT라 update로 실행
                sql,
                body.get("userId"), // 첫 번째 ? 자리. 존재하지 않는 사용자면 외래키 제약조건 때문에 DB가 거부함
                body.get("bookId") // 두 번째 ? 자리. 존재하지 않는 책이면 마찬가지로 거부
        );
    }

    public void returnRental(Long rentalId) { // 대여 기록 하나를 반납 처리
        String sql = "UPDATE rental SET returned_at = NOW() WHERE rental_id = ?"; // 반납일을 지금 시각으로 바꿈. WHERE가 없으면 모든 대여 기록이 바뀌어서 반드시 필요

        jdbcTemplate.update(sql, rentalId); // UPDATE도 데이터를 바꾸는 쿼리라 update로 실행. ? 자리에 rentalId가 들어감
    }
}