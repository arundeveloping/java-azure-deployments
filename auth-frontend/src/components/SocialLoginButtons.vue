<script setup lang="ts">
import { oauthAuthorizeUrl } from '@/api/auth'

function startOAuth(provider: 'google' | 'github') {
  window.location.href = oauthAuthorizeUrl(provider)
}
</script>

<template>
  <div class="social-block">
    <p class="divider"><span>or continue with</span></p>
    <div class="social-row">
      <button type="button" class="btn btn-social" @click="startOAuth('google')">
        Google
      </button>
      <button type="button" class="btn btn-social" @click="startOAuth('github')">
        GitHub
      </button>
    </div>
  </div>
</template>
