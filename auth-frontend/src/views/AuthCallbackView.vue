<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import type { TokenResponse } from '@/types/auth'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const message = ref('Completing sign-in…')

onMounted(async () => {
  const accessToken = route.query.access_token
  const refreshToken = route.query.refresh_token
  const tokenType = route.query.token_type
  const expiresIn = route.query.expires_in

  if (
    typeof accessToken !== 'string' ||
    typeof refreshToken !== 'string' ||
    typeof tokenType !== 'string' ||
    typeof expiresIn !== 'string'
  ) {
    message.value = 'Missing tokens from authentication provider.'
    return
  }

  const tokens: TokenResponse = {
    accessToken,
    refreshToken,
    tokenType,
    expiresIn: Number(expiresIn),
  }

  try {
    await auth.applyOAuthTokens(tokens)
    await router.replace({ name: 'dashboard' })
  } catch {
    message.value = auth.error ?? 'Could not complete sign-in.'
  }
})
</script>

<template>
  <div class="auth-shell">
    <div class="auth-card narrow">
      <p class="subtitle">{{ message }}</p>
      <RouterLink v-if="message !== 'Completing sign-in…'" to="/login">Back to sign in</RouterLink>
    </div>
  </div>
</template>
