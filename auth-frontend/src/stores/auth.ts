import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import * as authApi from '@/api/auth'
import type { LoginPayload, RegisterPayload, TokenResponse, UserResponse } from '@/types/auth'
import { HttpError } from '@/api/http'

const ACCESS_KEY = 'auth.accessToken'
const REFRESH_KEY = 'auth.refreshToken'
const EXPIRES_KEY = 'auth.expiresAt'

function loadStoredTokens(): Pick<TokenResponse, 'accessToken' | 'refreshToken'> | null {
  const accessToken = localStorage.getItem(ACCESS_KEY)
  const refreshToken = localStorage.getItem(REFRESH_KEY)
  if (!accessToken || !refreshToken) {
    return null
  }
  return { accessToken, refreshToken }
}

export const useAuthStore = defineStore('auth', () => {
  const accessToken = ref<string | null>(localStorage.getItem(ACCESS_KEY))
  const refreshToken = ref<string | null>(localStorage.getItem(REFRESH_KEY))
  const expiresAt = ref<number | null>(
    localStorage.getItem(EXPIRES_KEY) ? Number(localStorage.getItem(EXPIRES_KEY)) : null,
  )
  const user = ref<UserResponse | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  const isAuthenticated = computed(() => Boolean(accessToken.value))

  function persistTokens(tokens: TokenResponse) {
    accessToken.value = tokens.accessToken
    refreshToken.value = tokens.refreshToken
    const expiry = Date.now() + tokens.expiresIn * 1000
    expiresAt.value = expiry
    localStorage.setItem(ACCESS_KEY, tokens.accessToken)
    localStorage.setItem(REFRESH_KEY, tokens.refreshToken)
    localStorage.setItem(EXPIRES_KEY, String(expiry))
  }

  function clearSession() {
    accessToken.value = null
    refreshToken.value = null
    expiresAt.value = null
    user.value = null
    localStorage.removeItem(ACCESS_KEY)
    localStorage.removeItem(REFRESH_KEY)
    localStorage.removeItem(EXPIRES_KEY)
  }

  function setError(err: unknown) {
    if (err instanceof HttpError) {
      error.value = err.message
    } else if (err instanceof Error) {
      error.value = err.message
    } else {
      error.value = 'Something went wrong'
    }
  }

  async function register(payload: RegisterPayload) {
    loading.value = true
    error.value = null
    try {
      await authApi.register(payload)
    } catch (err) {
      setError(err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function login(payload: LoginPayload) {
    loading.value = true
    error.value = null
    try {
      const tokens = await authApi.login(payload)
      persistTokens(tokens)
      await fetchUser()
    } catch (err) {
      setError(err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function applyOAuthTokens(tokens: TokenResponse) {
    persistTokens(tokens)
    await fetchUser()
  }

  async function fetchUser() {
    if (!accessToken.value) {
      return
    }
    user.value = await authApi.getCurrentUser(accessToken.value)
  }

  async function ensureValidAccessToken(): Promise<string | null> {
    if (!accessToken.value) {
      return null
    }
    const bufferMs = 60_000
    if (expiresAt.value && Date.now() < expiresAt.value - bufferMs) {
      return accessToken.value
    }
    if (!refreshToken.value) {
      clearSession()
      return null
    }
    try {
      const tokens = await authApi.refresh(refreshToken.value)
      persistTokens(tokens)
      return accessToken.value
    } catch {
      clearSession()
      return null
    }
  }

  async function initialize() {
    const stored = loadStoredTokens()
    if (!stored) {
      return
    }
    accessToken.value = stored.accessToken
    refreshToken.value = stored.refreshToken
    const token = await ensureValidAccessToken()
    if (!token) {
      return
    }
    try {
      await fetchUser()
    } catch {
      clearSession()
    }
  }

  async function logout() {
    loading.value = true
    error.value = null
    const access = accessToken.value
    const refresh = refreshToken.value
    clearSession()
    try {
      if (access && refresh) {
        await authApi.logout(access, refresh)
      }
    } catch {
      // Session already cleared locally
    } finally {
      loading.value = false
    }
  }

  return {
    accessToken,
    refreshToken,
    user,
    loading,
    error,
    isAuthenticated,
    register,
    login,
    logout,
    fetchUser,
    ensureValidAccessToken,
    applyOAuthTokens,
    initialize,
    clearSession,
  }
})
