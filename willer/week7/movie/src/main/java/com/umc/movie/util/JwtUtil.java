package com.umc.movie.util;

import com.umc.movie.exception.ApiException;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.Instant;
import java.util.Date;

@Component // 스프링이 객체를 하나 만들어두고 필요한 곳에 넣어줌
public class JwtUtil { // 토큰을 만들고 검증하는 도구. 로그인과 인터셉터 두 곳에서 씀

    private final SecretKey secretKey;
    private final Duration accessExpiration;

    public JwtUtil(
            @Value("${jwt.secret}") String secret, // application.yaml의 jwt.secret 값을 받음
            @Value("${jwt.access-expiration}") Long accessExpiration
    ) {
        this.secretKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8)); // 문자열 비밀키를 HMAC 서명용 키 객체로 바꿈. 32바이트보다 짧으면 여기서 예외
        this.accessExpiration = Duration.ofSeconds(accessExpiration); // 초 단위 숫자를 기간 객체로
    }

    public String createAccessToken(Long memberId, String email) { // 로그인에 성공한 회원에게 줄 토큰
        Instant now = Instant.now();

        return Jwts.builder()
                .subject(String.valueOf(memberId)) // 토큰 주인. memberId를 넣음
                .claim("email", email) // 참고용 부가 정보. payload는 누구나 읽을 수 있어서 비밀번호 같은 건 넣지 않음
                .issuedAt(Date.from(now)) // 발급 시각
                .expiration(Date.from(now.plus(accessExpiration))) // 만료 시각. 없으면 영원히 유효한 토큰이 됨
                .signWith(secretKey) // 비밀키로 서명. payload를 바꾸면 서명이 안 맞아서 검증에서 걸림
                .compact(); // header.payload.signature 문자열로 합침
    }

    public Long getMemberId(String token) { // 검증을 통과해야 값을 돌려줌. 실패하면 예외
        try {
            return Long.valueOf(getClaims(token).getPayload().getSubject());
        } catch (ExpiredJwtException e) { // 만료는 다시 로그인하면 해결되는 상황이라 따로 구분
            throw new ApiException(HttpStatus.UNAUTHORIZED, "AUTH401_4", "토큰이 만료되었습니다. 다시 로그인해주세요.");
        } catch (JwtException | IllegalArgumentException e) { // 서명 불일치, 형식 오류 같은 나머지 실패
            throw new ApiException(HttpStatus.UNAUTHORIZED, "AUTH401_3", "유효하지 않은 토큰입니다.");
        }
    }

    private Jws<Claims> getClaims(String token) {
        return Jwts.parser()
                .verifyWith(secretKey) // 같은 키로 서명을 다시 계산해서 대조
                .clockSkewSeconds(60) // 서버와 클라이언트 시계가 조금 어긋나도 되게 60초 여유
                .build()
                .parseSignedClaims(token);
    }
}