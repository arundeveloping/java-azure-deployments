package com.example.auth.security;

import com.example.auth.entity.User;
import com.example.auth.service.AuthService;
import com.example.auth.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;

@Component
public class OAuth2LoginSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

    private final UserService userService;
    private final AuthService authService;
    private final String redirectUri;

    public OAuth2LoginSuccessHandler(UserService userService,
                                     @Lazy AuthService authService,
                                     @Value("${auth.oauth2.redirect-uri:http://localhost:3000/auth/callback}") String redirectUri) {
        this.userService = userService;
        this.authService = authService;
        this.redirectUri = redirectUri;
    }

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request,
                                        HttpServletResponse response,
                                        Authentication authentication) throws IOException {
        OAuth2User oAuth2User = (OAuth2User) authentication.getPrincipal();

        String email = oAuth2User.getAttribute("email");
        String firstName = extractFirstName(oAuth2User);
        String lastName = extractLastName(oAuth2User);
        String provider = extractProvider(request);
        String providerId = oAuth2User.getName();

        User user = userService.findOrCreateOAuthUser(email, firstName, lastName, provider, providerId);
        var tokens = authService.generateTokenPair(user);

        String targetUrl = UriComponentsBuilder.fromUriString(redirectUri)
                .queryParam("access_token", tokens.accessToken())
                .queryParam("refresh_token", tokens.refreshToken())
                .queryParam("token_type", tokens.tokenType())
                .queryParam("expires_in", tokens.expiresIn())
                .build()
                .toUriString();

        getRedirectStrategy().sendRedirect(request, response, targetUrl);
    }

    private String extractFirstName(OAuth2User oAuth2User) {
        String givenName = oAuth2User.getAttribute("given_name");
        if (givenName != null) {
            return givenName;
        }
        String name = oAuth2User.getAttribute("name");
        if (name != null && name.contains(" ")) {
            return name.split(" ")[0];
        }
        return name != null ? name : "User";
    }

    private String extractLastName(OAuth2User oAuth2User) {
        String familyName = oAuth2User.getAttribute("family_name");
        if (familyName != null) {
            return familyName;
        }
        String name = oAuth2User.getAttribute("name");
        if (name != null && name.contains(" ")) {
            String[] parts = name.split(" ");
            return parts[parts.length - 1];
        }
        return "";
    }

    private String extractProvider(HttpServletRequest request) {
        String uri = request.getRequestURI();
        if (uri.contains("google")) {
            return "google";
        }
        if (uri.contains("github")) {
            return "github";
        }
        return "oauth2";
    }
}
