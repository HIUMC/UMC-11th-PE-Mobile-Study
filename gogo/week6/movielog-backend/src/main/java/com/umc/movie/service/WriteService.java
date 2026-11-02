package com.umc.movie.service;

import com.umc.movie.dto.WriteDtos.*;
import com.umc.movie.entity.*;
import com.umc.movie.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;
import java.nio.charset.StandardCharsets;

@Service
@Transactional
public class WriteService {
    private final MemberRepository members;
    private final RatingRepository ratings;
    private final BCryptPasswordEncoder bcrypt = new BCryptPasswordEncoder();
    public WriteService(MemberRepository members, RatingRepository ratings) {
        this.members=members; this.ratings=ratings;
    }
    public MemberResponse signUp(SignUp r) {
        if(r.password().getBytes(StandardCharsets.UTF_8).length>72)
            throw error(HttpStatus.BAD_REQUEST,"비밀번호는 UTF-8 기준 72바이트 이하여야 합니다.");
        if(members.existsByEmail(r.email().trim())) throw error(HttpStatus.CONFLICT,"이미 사용 중인 이메일입니다.");
        if(members.existsByNickname(r.nickname().trim())) throw error(HttpStatus.CONFLICT,"이미 사용 중인 닉네임입니다.");
        if(r.nickname().trim().length()<2) throw error(HttpStatus.BAD_REQUEST,"닉네임은 2자 이상이어야 합니다.");
        Member m=members.saveAndFlush(new Member(r.email().trim(),bcrypt.encode(r.password()),r.nickname().trim()));
        return new MemberResponse(m.getId(),r.email().trim(),r.nickname().trim());
    }
    public Long create(Long memberId, CreateRating r) {
        Member member=members.findById(memberId).orElseThrow(()->error(HttpStatus.NOT_FOUND,"존재하지 않는 회원입니다."));
        if(ratings.existsByMember_IdAndMovieId(memberId,r.movieId()))
            throw error(HttpStatus.CONFLICT,"이미 등록한 영화 평점입니다.");
        return ratings.saveAndFlush(new Rating(member,r.movieId(),r.score(),r.comment())).getId();
    }
    public void update(Long memberId, Long ratingId, UpdateRating r) {
        Rating rating=owned(memberId,ratingId);
        if(r.score()==null && r.comment()==null) throw error(HttpStatus.BAD_REQUEST,"변경할 별점 또는 후기를 입력하세요.");
        rating.update(r.score(),r.comment());
    }
    public void delete(Long memberId, Long ratingId) { ratings.delete(owned(memberId,ratingId)); }
    private Rating owned(Long memberId, Long ratingId) {
        Rating r=ratings.findById(ratingId).orElseThrow(()->error(HttpStatus.NOT_FOUND,"존재하지 않는 평점입니다."));
        if(!r.getMemberId().equals(memberId)) throw error(HttpStatus.FORBIDDEN,"본인의 평점만 변경할 수 있습니다.");
        return r;
    }
    private ResponseStatusException error(HttpStatus status,String message) { return new ResponseStatusException(status,message); }
}
