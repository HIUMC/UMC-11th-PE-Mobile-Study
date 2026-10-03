package com.umc.study.service;

import com.umc.study.repository.RentalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service // 스프링에 "나 셰프(비즈니스 로직 담당)야" 하고 등록
@RequiredArgsConstructor // final 필드(RentalRepository)를 받는 생성자를 Lombok이 만들어줌
public class RentalService {

    private final RentalRepository rentalRepository; // 창고지기. 서비스는 SQL을 직접 쓰지 않고 Repository에 시킴

    public void createRental(Map<String, Object> body) {
        rentalRepository.save(body); // 지금은 규칙 없이 그대로 저장. "이미 대여 중인 책인지" 같은 대여 규칙이 들어갈 자리
    }

    public void returnRental(Long rentalId) {
        rentalRepository.returnRental(rentalId); // 지금은 규칙 없이 그대로 반납 처리. "이미 반납된 기록인지" 같은 규칙이 들어갈 자리
    }
}
