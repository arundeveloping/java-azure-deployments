package com.example.auth.service;

import com.example.auth.dto.LoginRequest;
import com.example.auth.dto.RegisterRequest;
import com.example.auth.dto.TokenResponse;
import com.example.auth.exception.AuthException;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class AuthServiceIntegrationTest {

    @Autowired
    private UserService userService;

    @Autowired
    private AuthService authService;

    @Test
    void registerLoginAndRefreshFlow() {
        var registerRequest = new RegisterRequest(
                "test@example.com", "password123", "Test", "User");

        var user = userService.register(registerRequest);
        assertThat(user.email()).isEqualTo("test@example.com");
        assertThat(user.roles()).contains("ROLE_USER");

        TokenResponse loginTokens = authService.login(
                new LoginRequest("test@example.com", "password123"));

        assertThat(loginTokens.accessToken()).isNotBlank();
        assertThat(loginTokens.refreshToken()).isNotBlank();
        assertThat(loginTokens.tokenType()).isEqualTo("Bearer");

        TokenResponse refreshed = authService.refresh(loginTokens.refreshToken());
        assertThat(refreshed.accessToken()).isNotBlank();
        assertThat(refreshed.refreshToken()).isNotEqualTo(loginTokens.refreshToken());
    }

    @Test
    void duplicateRegistrationFails() {
        var request = new RegisterRequest(
                "duplicate@example.com", "password123", "Dup", "User");

        userService.register(request);

        assertThatThrownBy(() -> userService.register(request))
                .isInstanceOf(AuthException.class)
                .hasMessageContaining("already registered");
    }
}
