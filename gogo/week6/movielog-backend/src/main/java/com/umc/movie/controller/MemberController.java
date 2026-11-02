package com.umc.movie.controller;

import com.umc.movie.dto.*;
import com.umc.movie.service.MemberService;
import jakarta.validation.constraints.*;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/members")
public class MemberController {
    private final MemberService service;
    public MemberController(MemberService service) { this.service = service; }

    @GetMapping("/nickname/{nickname}")
    public AvailabilityResponse nickname(@PathVariable @NotBlank @Size(max = 50) String nickname) {
        return service.nickname(nickname);
    }
    @GetMapping("/email/{email}")
    public AvailabilityResponse email(@PathVariable @NotBlank @Email @Size(max = 254) String email) {
        return service.email(email);
    }
    @GetMapping("/{memberId}/ratings")
    public List<RatingResponse> ratings(@PathVariable @Positive Long memberId) {
        return service.ratings(memberId);
    }
}
