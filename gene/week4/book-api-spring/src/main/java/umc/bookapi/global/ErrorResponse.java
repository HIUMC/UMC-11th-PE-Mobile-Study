package umc.bookapi.global;

import java.util.List;

public record ErrorResponse(
        int status,
        String error,
        List<String> messages
) {
}
