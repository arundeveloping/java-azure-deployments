import { request, apiUrl } from '@/api/http'
import type {
  LoginPayload,
  RegisterPayload,
  TokenResponse,
  UserResponse,
} from '@/types/auth'

export function register(payload: RegisterPayload): Promise<UserResponse> {
  return request<UserResponse>('/api/v1/auth/register', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export function login(payload: LoginPayload): Promise<TokenResponse> {
  return request<TokenResponse>('/api/v1/auth/login', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}

export function refresh(refreshToken: string): Promise<TokenResponse> {
  return request<TokenResponse>('/api/v1/auth/refresh', {
    method: 'POST',
    body: JSON.stringify({ refreshToken }),
  })
}

export function logout(accessToken: string, refreshToken: string): Promise<void> {
  return request<void>('/api/v1/auth/logout', {
    method: 'POST',
    auth: accessToken,
    body: JSON.stringify({ refreshToken }),
  })
}

export function getCurrentUser(accessToken: string): Promise<UserResponse> {
  return request<UserResponse>('/api/v1/auth/me', {
    method: 'GET',
    auth: accessToken,
  })
}

export function oauthAuthorizeUrl(provider: 'google' | 'github'): string {
  return apiUrl(`/oauth2/authorization/${provider}`)
}
