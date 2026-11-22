package com.umc.movie.interceptor;

import com.umc.movie.exception.ApiException;
import com.umc.movie.util.JwtUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
@RequiredArgsConstructor
public class AuthInterceptor implements HandlerInterceptor { // 컨트롤러 앞에서 토큰을 검사하는 관문. 인증만 하고 인가는 Service가 함

    public static final String MEMBER_ID = "memberId"; // 컨트롤러가 @RequestAttribute로 꺼낼 때 쓰는 이름
    private static final String BEARER_PREFIX = "Bearer "; // Bearer 뒤 띄어쓰기 한 칸까지 포함

    private final JwtUtil jwtUtil;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) { // 컨트롤러 실행 전에 호출. true면 통과, 예외면 여기서 끝
        if (HttpMethod.OPTIONS.matches(request.getMethod())) { // 브라우저 CORS 사전 요청은 토큰이 없어서 그냥 통과
            return true;
        }

        String header = request.getHeader(HttpHeaders.AUTHORIZATION);
        if (header == null || !header.startsWith(BEARER_PREFIX)) { // Bearer 형식이 아니면 토큰을 안 보낸 것으로 봄
            throw new ApiException(HttpStatus.UNAUTHORIZED, "AUTH401_2", "로그인이 필요한 요청입니다.");
        }

        Long memberId = jwtUtil.getMemberId(header.substring(BEARER_PREFIX.length())); // 검증에 실패하면 JwtUtil이 401을 던짐
        request.setAttribute(MEMBER_ID, memberId); // 뒤이어 실행될 컨트롤러가 꺼내 쓰게 요청에 담아둠
        return true;
    }
}