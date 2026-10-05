package umc.bookapi.book;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import umc.bookapi.book.dto.CreateBookRequest;
import umc.bookapi.book.dto.BookResponse;
import umc.bookapi.category.Category;
import umc.bookapi.category.CategoryRepository;
import umc.bookapi.global.NotFoundException;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class BookService {

    private final BookRepository bookRepository;
    private final CategoryRepository categoryRepository;

    public List<BookResponse> findAll() {
        return bookRepository.findAllByOrderByBookIdAsc().stream()
                .map(BookResponse::from)
                .toList();
    }

    @Transactional
    public BookResponse create(CreateBookRequest request) {
        Category category = categoryRepository.findById(request.categoryId())
                .orElseThrow(() -> new NotFoundException(
                        "ID가 " + request.categoryId() + "인 카테고리가 존재하지 않습니다."));

        Book saved = bookRepository.save(new Book(request.title().strip(), request.description(), category));
        return BookResponse.from(saved);
    }
}
