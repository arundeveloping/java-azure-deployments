<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import AuthLayout from '@/components/AuthLayout.vue'
import SocialLoginButtons from '@/components/SocialLoginButtons.vue'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const router = useRouter()

const form = reactive({
  firstName: '',
  lastName: '',
  email: '',
  password: '',
})

const fieldError = ref<string | null>(null)
const success = ref(false)

async function onSubmit() {
  fieldError.value = null
  auth.error = null
  success.value = false

  if (form.password.length < 8) {
    fieldError.value = 'Password must be at least 8 characters.'
    return
  }

  try {
    await auth.register({ ...form })
    success.value = true
    await router.push({ name: 'login', query: { registered: '1' } })
  } catch {
    // store.error is set
  }
}
</script>

<template>
  <AuthLayout title="Create account" subtitle="Register with email and password.">
    <form class="form" @submit.prevent="onSubmit">
      <div class="row">
        <label>
          First name
          <input v-model="form.firstName" type="text" autocomplete="given-name" required />
        </label>
        <label>
          Last name
          <input v-model="form.lastName" type="text" autocomplete="family-name" required />
        </label>
      </div>
      <label>
        Email
        <input v-model="form.email" type="email" autocomplete="email" required />
      </label>
      <label>
        Password
        <input
          v-model="form.password"
          type="password"
          autocomplete="new-password"
          minlength="8"
          required
        />
      </label>

      <p v-if="fieldError" class="alert alert-error">{{ fieldError }}</p>
      <p v-else-if="auth.error" class="alert alert-error">{{ auth.error }}</p>
      <p v-if="success" class="alert alert-success">Account created. You can sign in now.</p>

      <button type="submit" class="btn btn-primary" :disabled="auth.loading">
        {{ auth.loading ? 'Creating…' : 'Register' }}
      </button>
    </form>

    <SocialLoginButtons />

    <p class="footer-link">
      Already registered?
      <RouterLink to="/login">Sign in</RouterLink>
    </p>
  </AuthLayout>
</template>
