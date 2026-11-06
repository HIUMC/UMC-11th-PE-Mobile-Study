package com.umc.movie.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity // member 테이블과 연결되는 클래스
@Table(name = "member")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED) // JPA가 객체를 만들 때 쓰는 빈 생성자. 외부에서 막 만들지 못하게 protected
public class Member extends BaseTimeEntity { // created_at, updated_at은 부모에게 물려받음

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // AUTO_INCREMENT로 DB가 번호를 매김
    @Column(name = "member_id")
    private Long memberId;

    @Column(nullable = false, unique = true, length = 254) // 이메일 최대 길이 254자
    private String email;

    @Column(nullable = false, length = 60) // bcrypt 해시 길이 60자
    private String password;

    @Column(nullable = false, unique = true, length = 50)
    private String nickname;

    @Builder // Member.builder().email(..).password(..).nickname(..).build()처럼 이름을 붙여서 값을 넣을 수 있음. 순서를 헷갈려 값이 뒤바뀌는 실수를 막음
    public Member(String email, String password, String nickname) { // 회원가입 때 쓸 생성자
        this.email = email;
        this.password = password;
        this.nickname = nickname;
    }
}