package com.umc.movie.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "rating", uniqueConstraints = @UniqueConstraint(columnNames = {"member_id", "movie_id"})) // 한 사람이 같은 영화에 평점 하나만
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Rating extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "rating_id")
    private Long ratingId;

    @ManyToOne(fetch = FetchType.LAZY) // 평점 여러 개가 회원 한 명에 속함. 회원 정보는 실제로 쓸 때만 조회
    @JoinColumn(name = "member_id", nullable = false) // rating.member_id FK로 연결
    private Member member;

    @Column(name = "movie_id", nullable = false) // TMDB 영화 id. 영화 테이블이 없어서 연관관계 없이 숫자만 저장
    private Long movieId;

    @Column(nullable = false, columnDefinition = "TINYINT") // DB 컬럼이 TINYINT라서 validate가 통과하도록 맞춤
    private Integer score;

    @Column(columnDefinition = "TEXT")
    private String comment;

    @Builder // Rating.builder().member(..).movieId(..)처럼 이름을 붙여서 값을 넣음
    public Rating(Member member, Long movieId, Integer score, String comment) {
        this.member = member;
        this.movieId = movieId;
        this.score = score;
        this.comment = comment;
    }

    public void update(Integer score, String comment) { // setter 대신 바꿀 수 있는 값만 모아둔 메서드. movieId와 작성자는 못 바꿈
        this.score = score;
        this.comment = comment;
    }
}