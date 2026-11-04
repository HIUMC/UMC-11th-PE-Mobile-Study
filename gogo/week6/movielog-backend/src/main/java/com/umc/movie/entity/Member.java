package com.umc.movie.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "member")
public class Member {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "member_id")
    private Long id;
    @Column(nullable = false, unique = true, length = 254)
    private String email;
    @Column(nullable = false, length = 60)
    private String password;
    @Column(nullable = false, unique = true, length = 50)
    private String nickname;
    @Column(nullable = false) private LocalDateTime createdAt;
    @Column(nullable = false) private LocalDateTime updatedAt;
    protected Member() {}
    public Member(String email, String password, String nickname) {
        this.email = email; this.password = password; this.nickname = nickname;
        this.createdAt = this.updatedAt = LocalDateTime.now();
    }
    public Long getId() { return id; }
}
