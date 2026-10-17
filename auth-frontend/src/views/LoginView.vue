<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import AuthLayout from '@/components/AuthLayout.vue'
import SocialLoginButtons from '@/components/SocialLoginButtons.vue'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const router = useRouter()
const route = useRoute()

const form = reactive({
  email: '',
  password: '',
})

const fieldError = ref<string | null>(null)
const registered = route.query.registered === '1'

async function onSubmit() {
  fieldError.value = null
  auth.error = null
  if (!form.email || !form.password) {
    fieldError.value = 'Email and password are required.'
    return
  }
  try {
    await auth.login({ ...form })
    const redirect = typeof route.query.redirect === 'string' ? route.query.redirect : '/dashboard'
    await router.push(redirect)
  } catch {
    // store.error is set
  }
}
</script>

<template>
  <AuthLayout title="Sign in" subtitle="Use your account or social login.">
    <form class="form" @submit.prevent="onSubmit">
      <label>
        Email
        <input v-model="form.email" type="email" autocomplete="email" required />
      </label>
      <label>
        Password
        <input v-model="form.password" type="password" autocomplete="current-password" required />
      </label>

      <p v-if="registered" class="alert alert-success">Account created. Sign in with your credentials.</p>
      <p v-if="fieldError" class="alert alert-error">{{ fieldError }}</p>
      <p v-else-if="auth.error" class="alert alert-error">{{ auth.error }}</p>

      <button type="submit" class="btn btn-primary" :disabled="auth.loading">
        {{ auth.loading ? 'Signing in…' : 'Sign in' }}
      </button>
    </form>

    <SocialLoginButtons />

    <p class="footer-link">
      No account?
      <RouterLink to="/register">Create one</RouterLink>
    </p>
  </AuthLayout>
</template>
