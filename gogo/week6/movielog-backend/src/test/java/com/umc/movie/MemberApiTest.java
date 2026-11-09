package com.umc.movie;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

// 실제 과제용 MySQL과 init.sql의 시드 데이터를 검증합니다.
@SpringBootTest
@AutoConfigureMockMvc
class MemberApiTest {
    @Autowired MockMvc mvc;
    @Test void duplicatesAndAvailableValues() throws Exception {
        mvc.perform(get("/members/nickname/수현")).andExpect(status().isOk())
                .andExpect(jsonPath("$.available").value(false));
        mvc.perform(get("/members/nickname/새로운닉네임")).andExpect(status().isOk())
                .andExpect(jsonPath("$.available").value(true));
        mvc.perform(get("/members/email/noco@example.com")).andExpect(status().isOk())
                .andExpect(jsonPath("$.available").value(false));
        mvc.perform(get("/members/email/new@example.com")).andExpect(status().isOk())
                .andExpect(jsonPath("$.available").value(true));
    }
    @Test void newestFirstWithoutPrivateMemberFields() throws Exception {
        mvc.perform(get("/members/1/ratings")).andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$[0].movieId").value(155))
                .andExpect(jsonPath("$[1].movieId").value(550))
                .andExpect(jsonPath("$[0].member").doesNotExist())
                .andExpect(jsonPath("$[0].password").doesNotExist());
        mvc.perform(get("/members/3/ratings")).andExpect(status().isOk())
                .andExpect(content().json("[]"));
    }
    @Test void invalidAndMissingMembers() throws Exception {
        mvc.perform(get("/members/99999/ratings")).andExpect(status().isNotFound());
        mvc.perform(get("/members/nope/ratings")).andExpect(status().isBadRequest());
        mvc.perform(get("/members/0/ratings")).andExpect(status().isBadRequest());
        mvc.perform(get("/members/email/invalid")).andExpect(status().isBadRequest());
    }
    @Test void corsAllowsOnlyConfiguredOrigins() throws Exception {
        mvc.perform(get("/members/1/ratings").header("Origin", "http://localhost:5173"))
                .andExpect(status().isOk())
                .andExpect(header().string("Access-Control-Allow-Origin", "http://localhost:5173"));
        mvc.perform(get("/members/1/ratings").header("Origin", "https://untrusted.example"))
                .andExpect(status().isForbidden())
                .andExpect(header().doesNotExist("Access-Control-Allow-Origin"));
    }
}
