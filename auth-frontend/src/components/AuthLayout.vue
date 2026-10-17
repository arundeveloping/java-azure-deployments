<script setup lang="ts">
defineProps<{
  title: string
  subtitle?: string
}>()
</script>

<template>
  <div class="auth-shell">
    <div class="auth-card">
      <header class="auth-header">
        <p class="eyebrow">Auth Service</p>
        <h1>{{ title }}</h1>
        <p v-if="subtitle" class="subtitle">{{ subtitle }}</p>
      </header>
      <slot />
    </div>
  </div>
</template>
