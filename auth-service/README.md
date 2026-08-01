# Auth Service

Production-ready OAuth2 authentication microservice built with Spring Boot 3, Spring Authorization Server, JWT, PostgreSQL, and Redis.

## Features

- **OAuth2 Authorization Server** — Authorization Code, Refresh Token, and Client Credentials flows
- **JWT access tokens** — Short-lived tokens with role claims
- **Refresh token rotation** — Secure refresh with automatic revocation on reuse
- **Social login** — Google and GitHub OAuth2 integration
- **Token blacklisting** — Redis-backed logout/revocation
- **User registration** — Email/password with BCrypt hashing
- **API documentation** — OpenAPI/Swagger UI
- **Health checks** — Spring Actuator endpoints
- **Database migrations** — Flyway for schema management
- **Docker ready** — Multi-container setup with PostgreSQL and Redis

## Architecture

```
┌─────────────┐     ┌──────────────────┐     ┌────────────┐
│   Client    │────▶│   Auth Service   │────▶│ PostgreSQL │
│  (Web/App)  │     │  (Spring Boot)   │     └────────────┘
└─────────────┘     │                  │     ┌────────────┐
                    │  - OAuth2 Server │────▶│   Redis    │
                    │  - JWT Issuer    │     └────────────┘
                    │  - User Mgmt     │
                    └──────────────────┘
```

## Quick Start

### Prerequisites

- Java 21+
- Maven 3.9+
- Docker & Docker Compose (optional)

### Local Development

1. Start infrastructure:

```bash
docker compose up postgres redis -d
```

2. Run the service:

```bash
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

3. Open Swagger UI: http://localhost:8080/swagger-ui.html

### Full Docker Deployment

```bash
# Build and start all services
mvn clean package -DskipTests
docker compose up --build -d
```

## API Endpoints

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/api/v1/auth/register` | Register new user | Public |
| POST | `/api/v1/auth/login` | Login with credentials | Public |
| POST | `/api/v1/auth/refresh` | Refresh access token | Public |
| POST | `/api/v1/auth/logout` | Revoke tokens | Bearer |
| GET | `/api/v1/auth/me` | Get current user | Bearer |
| GET | `/oauth2/authorize` | OAuth2 authorization | OAuth2 |
| POST | `/oauth2/token` | OAuth2 token endpoint | OAuth2 |
| GET | `/oauth2/authorization/google` | Google social login | Public |
| GET | `/oauth2/authorization/github` | GitHub social login | Public |

## Usage Examples

### Register

```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "securePassword123",
    "firstName": "John",
    "lastName": "Doe"
  }'
```

### Login

```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "securePassword123"
  }'
```

### Access Protected Resource

```bash
curl http://localhost:8080/api/v1/auth/me \
  -H "Authorization: Bearer <access_token>"
```

### OAuth2 Authorization Code Flow

1. Redirect user to:
   ```
   http://localhost:8080/oauth2/authorize?response_type=code&client_id=auth-client&redirect_uri=http://localhost:3000/callback&scope=openid profile email
   ```

2. Exchange code for tokens:
   ```bash
   curl -X POST http://localhost:8080/oauth2/token \
     -u auth-client:auth-secret-change-in-production \
     -d "grant_type=authorization_code&code=<code>&redirect_uri=http://localhost:3000/callback"
   ```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `JWT_SECRET` | (dev default) | Base64-encoded 256-bit secret |
| `JWT_ACCESS_EXPIRATION_MS` | 900000 | Access token TTL (15 min) |
| `JWT_REFRESH_EXPIRATION_MS` | 604800000 | Refresh token TTL (7 days) |
| `DB_HOST` | localhost | PostgreSQL host |
| `REDIS_HOST` | localhost | Redis host |
| `GOOGLE_CLIENT_ID` | — | Google OAuth2 client ID |
| `GOOGLE_CLIENT_SECRET` | — | Google OAuth2 client secret |
| `GITHUB_CLIENT_ID` | — | GitHub OAuth2 client ID |
| `GITHUB_CLIENT_SECRET` | — | GitHub OAuth2 client secret |
| `OAUTH2_CLIENT_SECRET` | — | OAuth2 registered client secret |

Generate a production JWT secret:

```bash
openssl rand -base64 64
```

## Production Checklist

- [ ] Set strong `JWT_SECRET` (64+ bytes, base64-encoded)
- [ ] Change `OAUTH2_CLIENT_SECRET`
- [ ] Configure social OAuth credentials
- [ ] Use HTTPS/TLS termination
- [ ] Persist RSA keys for OAuth2 (current in-memory keys reset on restart)
- [ ] Enable database connection pooling tuning
- [ ] Set up centralized logging and monitoring
- [ ] Configure rate limiting at API gateway level

## Running Tests

```bash
mvn test
```

## Project Structure

```
auth-service/
├── src/main/java/com/example/auth/
│   ├── config/          # OAuth2 server, OpenAPI config
│   ├── controller/      # REST endpoints
│   ├── dto/             # Request/response records
│   ├── entity/          # JPA entities
│   ├── exception/       # Global error handling
│   ├── repository/      # Data access
│   ├── security/        # JWT filter, OAuth2 handlers
│   └── service/         # Business logic
├── src/main/resources/
│   ├── application.yml
│   └── db/migration/    # Flyway SQL scripts
├── Dockerfile
└── docker-compose.yml
```

## License

MIT
