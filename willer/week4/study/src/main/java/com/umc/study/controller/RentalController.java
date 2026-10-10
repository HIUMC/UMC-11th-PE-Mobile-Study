package com.umc.study.controller;

import com.umc.study.service.RentalService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController // 스프링에 "나 웨이터(요청 받고 응답하는 API)야" 하고 등록
@RequestMapping("/rentals") // 이 컨트롤러가 맡는 기본 주소. 도서(/books)와 대여(/rentals)는 자원이 달라서 컨트롤러도 나눔
@RequiredArgsConstructor
public class RentalController {

    private final RentalService rentalService; // 셰프. 컨트롤러는 직접 요리(로직)하지 않고 서비스에 넘김

    @PostMapping // HTTP POST 방식으로 /rentals 요청이 오면 이 메서드가 실행됨
    public String createRental(@RequestBody Map<String, Object> body) { // 요청 본문의 JSON({ "userId": 1, "bookId": 1 })을 Map으로 받음
        rentalService.createRental(body);
        return "대여 기록이 생성되었습니다!"; // 도서 등록과 같은 방식으로 안내 문구만 응답
    }

    @PatchMapping("/{rentalId}/return") // 최종 주소는 /rentals/{rentalId}/return. 이미 있는 기록의 일부(반납일)만 바꾸는 요청이라 PATCH
    public String returnRental(@PathVariable Long rentalId) { // 주소의 {rentalId} 값을 Long으로 꺼냄. Body는 필요 없음
        rentalService.returnRental(rentalId);
        return "반납 처리가 완료되었습니다!";
    }
}