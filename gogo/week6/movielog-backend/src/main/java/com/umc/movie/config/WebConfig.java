package com.umc.movie.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.*;

@Configuration
@ConditionalOnProperty(name = "app.cors.enabled", havingValue = "true", matchIfMissing = true)
public class WebConfig implements WebMvcConfigurer {
    private final String[] origins;
    public WebConfig(@Value("${app.cors.allowed-origins}") String[] origins) { this.origins = origins; }
    @Override public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/members/**")
                .allowedOrigins(origins)
                .allowedMethods("GET", "POST", "PATCH", "DELETE")
                .allowedHeaders("Content-Type")
                .maxAge(3600);
    }
}
