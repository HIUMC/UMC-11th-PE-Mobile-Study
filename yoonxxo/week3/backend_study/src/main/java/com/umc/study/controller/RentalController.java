package com.umc.study.controller;

import com.umc.study.service.RentalService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/rentals")
@RequiredArgsConstructor
public class RentalController {

    private final RentalService rentalService;

    // POST /rentals
    // 클라이언트가 보낸 userId, bookId를 이용해 대여 기록 생성
    @PostMapping
    public String createRental(@RequestBody Map<String, Object> body) {

        rentalService.createRental(body);

        return "도서 대여가 완료되었습니다!";
    }
}