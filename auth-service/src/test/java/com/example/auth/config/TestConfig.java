package com.example.auth.config;

import com.example.auth.service.TokenBlacklist;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;

import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Configuration
@Profile("test")
public class TestConfig {

    @Bean
    @Primary
    public TokenBlacklist inMemoryTokenBlacklist() {
        return new InMemoryTokenBlacklist();
    }

    static class InMemoryTokenBlacklist implements TokenBlacklist {

        private final Map<String, Instant> blacklist = new ConcurrentHashMap<>();

        @Override
        public void blacklist(String token, Instant expiresAt) {
            blacklist.put(token, expiresAt);
        }

        @Override
        public boolean isBlacklisted(String token) {
            Instant expiry = blacklist.get(token);
            if (expiry == null) {
                return false;
            }
            if (Instant.now().isAfter(expiry)) {
                blacklist.remove(token);
                return false;
            }
            return true;
        }
    }
}
