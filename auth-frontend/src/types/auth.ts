export interface RegisterPayload {
  email: string
  password: string
  firstName: string
  lastName: string
}

export interface LoginPayload {
  email: string
  password: string
}

export interface TokenResponse {
  accessToken: string
  refreshToken: string
  tokenType: string
  expiresIn: number
}

export interface UserResponse {
  id: string
  email: string
  firstName: string
  lastName: string
  roles: string[]
  provider: string
}

export interface ApiError {
  status: number
  error: string
  message: string
  path: string
  timestamp: string
}
