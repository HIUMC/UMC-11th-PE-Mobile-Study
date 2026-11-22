package com.umc.movie.entity;

import jakarta.persistence.Column;
import jakarta.persistence.MappedSuperclass;
import lombok.Getter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Getter // 자식 엔티티에서 getCreatedAt(), getUpdatedAt()을 쓰려면 여기에도 붙여야 함
@MappedSuperclass // 자체 테이블은 없고, 상속한 엔티티에 컬럼 정의만 물려줌
public abstract class BaseTimeEntity { // 생성, 수정 시각을 엔티티마다 반복해서 쓰지 않게 뽑아낸 공통 부모

    @CreationTimestamp // 처음 저장할 때 Hibernate가 현재 시각을 채움. 이후엔 안 바뀜
    @Column(name = "created_at", nullable = false, updatable = false) // updatable = false라 UPDATE문에 안 들어감
    private LocalDateTime createdAt;

    @UpdateTimestamp // 저장될 때마다 현재 시각으로 다시 채움
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
}