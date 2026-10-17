import type { ApiError } from '@/types/auth'

const API_BASE = import.meta.env.VITE_API_BASE_URL ?? ''

export class HttpError extends Error {
  status: number
  body?: ApiError

  constructor(message: string, status: number, body?: ApiError) {
    super(message)
    this.name = 'HttpError'
    this.status = status
    this.body = body
  }
}

export function apiUrl(path: string): string {
  const base = API_BASE.replace(/\/$/, '')
  return `${base}${path.startsWith('/') ? path : `/${path}`}`
}

export async function request<T>(
  path: string,
  options: RequestInit & { auth?: string } = {},
): Promise<T> {
  const headers = new Headers(options.headers)
  if (!headers.has('Content-Type') && options.body) {
    headers.set('Content-Type', 'application/json')
  }
  if (options.auth) {
    headers.set('Authorization', `Bearer ${options.auth}`)
  }

  const { auth: _auth, ...fetchOptions } = options
  const response = await fetch(apiUrl(path), {
    ...fetchOptions,
    headers,
  })

  if (response.status === 204) {
    return undefined as T
  }

  const text = await response.text()
  const data = text ? (JSON.parse(text) as T | ApiError) : undefined

  if (!response.ok) {
    const err = data as ApiError | undefined
    throw new HttpError(
      err?.message ?? response.statusText ?? 'Request failed',
      response.status,
      err,
    )
  }

  return data as T
}
