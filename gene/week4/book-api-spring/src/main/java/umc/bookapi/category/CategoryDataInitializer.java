package umc.bookapi.category;

import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.List;

// 실습용 기본 카테고리 시드 (1: 소설, 2: 개발, 3: 에세이)
@Component
@RequiredArgsConstructor
public class CategoryDataInitializer implements CommandLineRunner {

    private final CategoryRepository categoryRepository;

    @Override
    public void run(String... args) {
        if (categoryRepository.count() == 0) {
            categoryRepository.saveAll(List.of(
                    new Category("소설"),
                    new Category("개발"),
                    new Category("에세이")
            ));
        }
    }
}
