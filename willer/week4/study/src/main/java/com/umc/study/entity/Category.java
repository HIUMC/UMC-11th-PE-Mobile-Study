package com.umc.study.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity // JPA가 관리하는 클래스. 객체 하나가 테이블의 한 행
@Table(name = "category") // 연결할 테이블 이름
@Getter // 모든 필드의 getter를 Lombok이 만들어줌
@NoArgsConstructor(access = AccessLevel.PROTECTED) // JPA가 DB 값을 채울 때 쓰는 빈 생성자. 외부에서 빈 객체를 막 만들지 못하게 protected
public class Category {

    @Id // PK
    @GeneratedValue(strategy = GenerationType.IDENTITY) // 값은 DB의 auto_increment가 정함
    @Column(name = "category_id") // 필드명(categoryId)과 컬럼명(category_id)이 달라서 직접 연결
    private Long categoryId; // bigint와 짝

    @Column(nullable = false, length = 50) // NOT NULL, varchar(50)
    private String name;
}