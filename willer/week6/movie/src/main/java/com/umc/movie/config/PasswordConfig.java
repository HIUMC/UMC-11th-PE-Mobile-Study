package com.umc.movie.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration // 서버가 켜질 때 이 클래스의 @Bean 메서드를 실행해서 객체를 등록함
public class PasswordConfig {
    @Bean // 반환한 객체를 스프링이 보관해두고, PasswordEncoder가 필요한 곳에 넣어줌
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(); // 같은 비밀번호도 매번 다른 salt를 붙여 60자 해시로 만듦
    }
}