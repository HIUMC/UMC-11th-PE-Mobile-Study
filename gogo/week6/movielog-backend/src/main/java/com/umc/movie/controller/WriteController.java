package com.umc.movie.controller;

import com.umc.movie.dto.WriteDtos.*;
import com.umc.movie.service.WriteService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/members")
public class WriteController {
    private final WriteService service;
    public WriteController(WriteService service) { this.service=service; }
    @PostMapping
    public ResponseEntity<ApiResponse> signup(@Valid @RequestBody SignUp r) {
        return ResponseEntity.status(201).body(ApiResponse.ok(201,"회원가입에 성공했습니다.",service.signUp(r)));
    }
    @PostMapping("/{memberId}/ratings")
    public ResponseEntity<ApiResponse> create(@PathVariable @Positive Long memberId,@Valid @RequestBody CreateRating r) {
        return ResponseEntity.status(201).body(ApiResponse.ok(201,"평점 등록에 성공했습니다.",service.create(memberId,r)));
    }
    @PatchMapping("/{memberId}/ratings/{ratingId}")
    public ApiResponse update(@PathVariable @Positive Long memberId,@PathVariable @Positive Long ratingId,@Valid @RequestBody UpdateRating r) {
        service.update(memberId,ratingId,r); return ApiResponse.ok(200,"평점 수정에 성공했습니다.",null);
    }
    @DeleteMapping("/{memberId}/ratings/{ratingId}")
    public ResponseEntity<Void> delete(@PathVariable @Positive Long memberId,@PathVariable @Positive Long ratingId) {
        service.delete(memberId,ratingId); return ResponseEntity.noContent().build();
    }
}
