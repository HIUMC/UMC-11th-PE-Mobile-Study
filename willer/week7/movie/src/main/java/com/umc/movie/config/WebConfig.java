package com.umc.movie.config;

import com.umc.movie.interceptor.AuthInterceptor;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration // 서버가 켜질 때 이 설정을 읽어서 적용함
@RequiredArgsConstructor // final 필드인 AuthInterceptor를 생성자로 받음
public class WebConfig implements WebMvcConfigurer { // 스프링 MVC 기본 설정에 원하는 부분만 덧붙이는 인터페이스

    private final AuthInterceptor authInterceptor;

    @Override
    public void addCorsMappings(CorsRegistry registry) { // 컨트롤러마다 @CrossOrigin을 붙이지 않고 한곳에서 CORS 정책을 정함
        registry.addMapping("/**") // 모든 API 주소에 적용
                .allowedOrigins("http://localhost:5173") // 이 출처에서 온 요청만 응답을 읽을 수 있게 허용 헤더를 붙여줌
                .allowedMethods("GET", "POST", "PATCH", "DELETE") // 이후 회원가입, 평점 수정, 삭제까지 미리 허용
                .allowedHeaders("*"); // 요청 헤더는 종류 상관없이 허용
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) { // 컨트롤러 앞에 토큰 검사 관문을 세움
        registry.addInterceptor(authInterceptor)
                .addPathPatterns("/**") // 일단 전부 잠금. 새 API 등록을 깜빡해도 잠긴 채로 남아서 안전함
                .excludePathPatterns( // 로그인 없이 써야 하는 경로만 엶. 경로만 보고 메서드는 구분하지 못함
                        "/auth/**", // 로그인
                        "/members", // 회원가입 POST /members
                        "/members/nickname/**", // 닉네임 중복 확인
                        "/members/email/**", // 이메일 중복 확인
                        "/members/*/ratings", // 유저별 평점 조회. 누구나 볼 수 있는 공개 목록
                        "/error" // 스프링이 에러 응답을 만들 때 내부적으로 쓰는 경로
                );
    }
}