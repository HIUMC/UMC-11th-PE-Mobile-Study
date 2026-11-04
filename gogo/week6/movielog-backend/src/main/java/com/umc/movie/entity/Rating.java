package com.umc.movie.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "rating")
public class Rating {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "rating_id") private Long id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "member_id") private Member member;
    @Column(nullable = false) private Long movieId;
    @Column(nullable = false) private Byte score;
    @Column(columnDefinition = "TEXT") private String comment;
    @Column(nullable = false) private LocalDateTime createdAt;
    @Column(nullable = false) private LocalDateTime updatedAt;
    protected Rating() {}
    public Rating(Member member, Long movieId, Byte score, String comment) {
        this.member = member; this.movieId = movieId; this.score = score; this.comment = comment;
        this.createdAt = this.updatedAt = LocalDateTime.now();
    }
    public Long getMemberId() { return member.getId(); }
    public void update(Byte score, String comment) {
        if (score != null) this.score = score;
        if (comment != null) this.comment = comment;
        this.updatedAt = LocalDateTime.now();
    }
    public Long getId() { return id; }
    public Long getMovieId() { return movieId; }
    public Byte getScore() { return score; }
    public String getComment() { return comment; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
}
