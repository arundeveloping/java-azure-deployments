package com.example.auth.service;

import java.time.Instant;

public interface TokenBlacklist {

    void blacklist(String token, Instant expiresAt);

    boolean isBlacklisted(String token);
}
