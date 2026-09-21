USE umc_book;

-- 미션 1. 문학 카테고리의 대여 가능한 도서, 최신순 10개
SELECT b.title, b.description, c.name AS category_name
FROM book b
JOIN category c ON b.category_id = c.category_id
WHERE c.name = '문학'
  AND b.is_available = TRUE
ORDER BY b.book_id DESC
LIMIT 10;

-- 미션 2. 특정 사용자가 아직 반납하지 않은 책, 반납 예정일 순
SELECT b.title, r.rented_at, r.due_at
FROM rental r
JOIN book b ON r.book_id = b.book_id
WHERE r.user_id = 1
  AND r.returned_at IS NULL
ORDER BY r.due_at;

-- 미션 3-1. 특정 책의 태그 목록
SELECT b.title, t.name AS tag_name
FROM book b
JOIN book_tag bt ON b.book_id = bt.book_id
JOIN tag t ON bt.tag_id = t.tag_id
WHERE b.book_id = 1
ORDER BY t.tag_id;

-- 미션 3-2. 특정 사용자의 해당 책 좋아요 여부
SELECT user_id, book_id
FROM book_like
WHERE book_id = 1
  AND user_id = 1;