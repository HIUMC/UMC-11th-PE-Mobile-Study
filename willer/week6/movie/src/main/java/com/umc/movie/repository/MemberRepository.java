package com.umc.movie.repository;

import com.umc.movie.entity.Member;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MemberRepository extends JpaRepository<Member, Long> { // <엔티티, PK 타입>. 기본 CRUD와 existsById를 자동으로 제공
    boolean existsByNickname(String nickname); // 메서드 이름만으로 "nickname이 같은 행이 있는지" 쿼리를 만들어줌
    boolean existsByEmail(String email); // email 기준으로 같은 방식
}