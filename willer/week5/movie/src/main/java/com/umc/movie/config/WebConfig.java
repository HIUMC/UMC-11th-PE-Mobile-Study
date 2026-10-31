package com.umc.movie.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration // 서버가 켜질 때 이 설정을 읽어서 적용함
public class WebConfig implements WebMvcConfigurer { // 스프링 MVC 기본 설정에 원하는 부분만 덧붙이는 인터페이스

    @Override
    public void addCorsMappings(CorsRegistry registry) { // 컨트롤러마다 @CrossOrigin을 붙이지 않고 한곳에서 CORS 정책을 정함
        registry.addMapping("/**") // 모든 API 주소에 적용
                .allowedOrigins("http://localhost:5173") // 이 출처에서 온 요청만 응답을 읽을 수 있게 허용 헤더를 붙여줌
                .allowedMethods("GET", "POST", "PATCH", "DELETE") // 이후 회원가입, 평점 수정, 삭제까지 미리 허용
                .allowedHeaders("*"); // 요청 헤더는 종류 상관없이 허용
    }
}