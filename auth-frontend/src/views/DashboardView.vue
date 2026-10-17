<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const router = useRouter()

onMounted(async () => {
  const token = await auth.ensureValidAccessToken()
  if (!token) {
    await router.replace({ name: 'login' })
    return
  }
  if (!auth.user) {
    await auth.fetchUser()
  }
})

async function onLogout() {
  await auth.logout()
  await router.push({ name: 'login' })
}
</script>

<template>
  <div class="dashboard">
    <header class="dashboard-header">
      <div>
        <p class="eyebrow">Signed in</p>
        <h1>Dashboard</h1>
      </div>
      <button type="button" class="btn btn-ghost" :disabled="auth.loading" @click="onLogout">
        Sign out
      </button>
    </header>

    <section v-if="auth.user" class="profile-card">
      <h2>{{ auth.user.firstName }} {{ auth.user.lastName }}</h2>
      <dl>
        <div>
          <dt>Email</dt>
          <dd>{{ auth.user.email }}</dd>
        </div>
        <div>
          <dt>Provider</dt>
          <dd>{{ auth.user.provider }}</dd>
        </div>
        <div>
          <dt>Roles</dt>
          <dd>
            <span v-for="role in auth.user.roles" :key="role" class="chip">{{ role }}</span>
          </dd>
        </div>
        <div>
          <dt>User ID</dt>
          <dd class="mono">{{ auth.user.id }}</dd>
        </div>
      </dl>
    </section>

    <p v-else class="muted">Loading profile…</p>
  </div>
</template>
