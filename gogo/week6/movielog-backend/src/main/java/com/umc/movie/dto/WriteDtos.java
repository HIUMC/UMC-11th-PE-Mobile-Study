package com.umc.movie.dto;

import jakarta.validation.constraints.*;

public final class WriteDtos {
    private WriteDtos() {}
    public record SignUp(
        @NotBlank @Email @Size(max=254) String email,
        @NotBlank @Size(min=2,max=12) String nickname,
        @NotBlank @Size(max=72)
        @Pattern(regexp="^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*]).{8,}$") String password) {}
    public record CreateRating(@NotNull @Positive Long movieId,
        @NotNull @Min(1) @Max(5) Byte score, @Size(max=2000) String comment) {}
    public record UpdateRating(@Min(1) @Max(5) Byte score, @Size(max=2000) String comment) {}
    public record MemberResponse(Long memberId, String email, String nickname) {}
    public record ApiResponse(boolean isSuccess, String code, String message, Object result) {
        public static ApiResponse ok(int status, String message, Object result) {
            return new ApiResponse(true,"COMMON"+status,message,result);
        }
    }
}
