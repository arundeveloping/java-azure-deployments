# Auth Service - cURL Commands

Base URL: `http://localhost:8080`

Run requests in this order: Health → Register → Login → Me → Refresh → Logout

---

## 1. Health Check

```bash
curl --location 'http://localhost:8080/actuator/health'
```

---

## 2. Register User

```bash
curl --location 'http://localhost:8080/api/v1/auth/register' \
--header 'Content-Type: application/json' \
--data-raw '{
  "email": "user@example.com",
  "password": "password123",
  "firstName": "John",
  "lastName": "Doe"
}'
```

---

## 3. Login

```bash
curl --location 'http://localhost:8080/api/v1/auth/login' \
--header 'Content-Type: application/json' \
--data-raw '{
  "email": "user@example.com",
  "password": "password123"
}'
```

Save the `accessToken` and `refreshToken` from the response for the next requests.

---

## 4. Get Current User (Protected)

Replace `YOUR_ACCESS_TOKEN` with the token from login.

```bash
curl --location 'http://localhost:8080/api/v1/auth/me' \
--header 'Authorization: Bearer YOUR_ACCESS_TOKEN'
```

---

## 5. Refresh Token

Replace `YOUR_REFRESH_TOKEN` with the token from login.

```bash
curl --location 'http://localhost:8080/api/v1/auth/refresh' \
--header 'Content-Type: application/json' \
--data-raw '{
  "refreshToken": "YOUR_REFRESH_TOKEN"
}'
```

---

## 6. Logout

```bash
curl --location 'http://localhost:8080/api/v1/auth/logout' \
--header 'Authorization: Bearer YOUR_ACCESS_TOKEN' \
--header 'Content-Type: application/json' \
--data-raw '{
  "refreshToken": "YOUR_REFRESH_TOKEN"
}'
```
