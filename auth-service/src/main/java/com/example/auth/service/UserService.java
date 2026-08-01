package com.example.auth.service;

import com.example.auth.dto.RegisterRequest;
import com.example.auth.dto.UserResponse;
import com.example.auth.entity.Role;
import com.example.auth.entity.User;
import com.example.auth.exception.AuthException;
import com.example.auth.exception.ResourceNotFoundException;
import com.example.auth.repository.UserRepository;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class UserService implements UserDetailsService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional(readOnly = true)
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + email));
    }

    @Transactional
    public UserResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.email())) {
            throw new AuthException("Email already registered");
        }

        User user = new User();
        user.setEmail(request.email().toLowerCase());
        user.setPassword(passwordEncoder.encode(request.password()));
        user.setFirstName(request.firstName());
        user.setLastName(request.lastName());
        user.setProvider("local");
        user.setRoles(Set.of(Role.ROLE_USER));

        return toResponse(userRepository.save(user));
    }

    @Transactional(readOnly = true)
    public UserResponse getUserById(UUID id) {
        return userRepository.findById(id)
                .map(this::toResponse)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    @Transactional(readOnly = true)
    public UserResponse getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .map(this::toResponse)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    @Transactional
    public User findOrCreateOAuthUser(String email, String firstName, String lastName,
                                      String provider, String providerId) {
        return userRepository.findByProviderAndProviderId(provider, providerId)
                .or(() -> userRepository.findByEmail(email))
                .map(existing -> {
                    if (existing.getProviderId() == null) {
                        existing.setProvider(provider);
                        existing.setProviderId(providerId);
                        return userRepository.save(existing);
                    }
                    return existing;
                })
                .orElseGet(() -> {
                    User user = new User();
                    user.setEmail(email.toLowerCase());
                    user.setFirstName(firstName);
                    user.setLastName(lastName);
                    user.setProvider(provider);
                    user.setProviderId(providerId);
                    user.setRoles(Set.of(Role.ROLE_USER));
                    return userRepository.save(user);
                });
    }

    private UserResponse toResponse(User user) {
        Set<String> roles = user.getRoles().stream()
                .map(Role::name)
                .collect(Collectors.toSet());
        return new UserResponse(user.getId(), user.getEmail(), user.getFirstName(),
                user.getLastName(), roles, user.getProvider());
    }
}
