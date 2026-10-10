# 4주차 실습 — ORM으로 도서 API 만들기 (Spring Boot + JPA)

- Spring Boot 4.1.1 / Java 17 / Gradle
- Spring Data JPA (Hibernate) + H2 인메모리 DB
- Bean Validation, Lombok

## 실행
```bash
./gradlew bootRun        # http://localhost:8080
```
> JDK 17이 필요해요. 기본 Java가 다른 버전이면 `export JAVA_HOME=$(/usr/libexec/java_home -v 17)` 후 실행하세요.

앱을 시작할 때 카테고리 3개(1 소설, 2 개발, 3 에세이)를 미리 넣어둬요.
H2 콘솔: http://localhost:8080/h2-console (JDBC URL: `jdbc:h2:mem:bookdb`)

## 구조
```
src/main/java/umc/bookapi/
├── category/
│   ├── Category.java                 # @Entity, PK: id
│   ├── CategoryRepository.java       # JpaRepository<Category, Long>
│   └── CategoryDataInitializer.java  # 기본 카테고리 시드
├── book/
│   ├── Book.java                     # @Entity, PK: book_id, FK: category_id → category.id (@ManyToOne)
│   ├── BookRepository.java           # JpaRepository<Book, Long> + @EntityGraph
│   ├── BookService.java
│   ├── BookController.java           # GET /books, POST /books
│   └── dto/
│       ├── CreateBookRequest.java    # @NotNull @Positive categoryId, @NotBlank title, @Size description
│       └── BookResponse.java
└── global/
    ├── GlobalExceptionHandler.java   # 400 / 404 공통 에러 응답
    ├── ErrorResponse.java
    └── NotFoundException.java
```

## 체크리스트
- [x] Spring Boot 또는 NestJS 중 한 스택의 ORM 설정을 완료했다. → `application.properties` (JPA + H2)
- [x] `Book`과 `Category`의 PK/FK 관계를 엔티티로 표현했다. → `@ManyToOne` + `@JoinColumn(name = "category_id")`
- [x] 요청 DTO에 제목과 카테고리 ID 검증을 적용했다. → `@NotNull`, `@Positive`, `@NotBlank`, `@Size(max=100)`, description `@Size(max=500)` + `@Valid`
- [x] `GET /books`가 ORM Repository를 통해 도서 목록을 반환한다. → `BookRepository.findAllByOrderByBookIdAsc()`
- [x] `POST /books`가 새 도서를 저장하고 201 상태 코드를 반환한다. → `@ResponseStatus(HttpStatus.CREATED)`
- [x] 존재하지 않는 카테고리와 빈 제목 요청에서 오류 응답을 확인했다.

## 테스트 결과
```
POST /books {"categoryId":2,"title":"클린 코드","description":"애자일 소프트웨어 장인 정신"}
→ 201 {"bookId":1,"title":"클린 코드","description":"애자일 소프트웨어 장인 정신","categoryName":"개발","isAvailable":true}

GET /books
→ 200 [{"bookId":1,"title":"클린 코드","description":"애자일 소프트웨어 장인 정신","categoryName":"개발","isAvailable":true},{"bookId":2,"title":"데미안","description":null,"categoryName":"소설","isAvailable":true}]

POST /books {"title":"없는 카테고리 책","categoryId":999}
→ 404 {"status":404,"error":"Not Found","messages":["ID가 999인 카테고리가 존재하지 않습니다."]}

POST /books {"title":"","categoryId":1}
→ 400 {"status":400,"error":"Bad Request","messages":["제목은 비어 있을 수 없습니다."]}

POST /books {"title":"   ","categoryId":1}
→ 400 {"status":400,"error":"Bad Request","messages":["제목은 비어 있을 수 없습니다."]}

POST /books {"title":"제목만"}
→ 400 {"status":400,"error":"Bad Request","messages":["categoryId는 필수입니다."]}
```
