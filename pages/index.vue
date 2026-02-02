<template>
  <div id="app">
    <el-container>
      <el-header class="app-header">
        <div class="logo">Todo App</div>
        <div class="header-right">
          <ClientOnly>
            <el-tooltip :content="isDark ? '切换到浅色模式' : '切换到深色模式'" placement="bottom">
              <el-button 
                :icon="isDark ? Sunny : Moon" 
                circle 
                @click="toggleTheme"
                class="theme-toggle"
              />
            </el-tooltip>
          </ClientOnly>
          <div v-if="user" class="user-info">
            <span>欢迎, {{ user.username }}</span>
            <el-button type="info" size="small" @click="handleLogout" style="margin-left: 15px;">退出登录</el-button>
          </div>
        </div>
      </el-header>
      
      <el-main class="app-main">
        <div v-if="!user" class="login-container">
          <el-empty description="请先登录以管理你的待办事项">
            <el-button type="primary" size="large" @click="showLogin = true">点击登录</el-button>
          </el-empty>
        </div>

        <TodoList v-else :user="user" @refresh="refreshUser" />
      </el-main>
    </el-container>

    <LoginModal v-model="showLogin" @login="onLogin" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount, type Ref } from 'vue'
import { Sunny, Moon } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import LoginModal from '~/components/LoginModal.vue'
import TodoList from '~/components/TodoList.vue'

interface User {
  username: string
  id?: string
  [key: string]: any
}

interface LoginCredentials {
  username: string
  password: string
}

interface LoginResponse {
  token: string
  user: User
}

const showLogin: Ref<boolean> = ref(false)
const user: Ref<User | null> = ref(null)
const isDark: Ref<boolean> = ref(false)
let mediaQuery: MediaQueryList | null = null

onMounted(() => {
  initTheme()
  checkAuth()
})

onBeforeUnmount(() => {
  if (mediaQuery) {
    mediaQuery.removeEventListener('change', handleSystemThemeChange)
  }
})

async function checkAuth(): Promise<void> {
  const token = useCookie('auth_token')
  if (token.value) {
    try {
      const { data } = await useFetch<User>('/api/auth/me', {
        headers: {
          Authorization: `Bearer ${token.value}`
        }
      })
      if (data.value) {
        user.value = data.value
      }
    } catch (error) {
      console.error('认证失败:', error)
      token.value = null
    }
  }
}

async function onLogin(credentials: LoginCredentials): Promise<void> {
  try {
    const { data, error } = await useFetch<LoginResponse>('/api/auth/login', {
      method: 'POST',
      body: credentials
    })
    
    if (error.value) {
      ElMessage.error(error.value.data?.message || '登录失败')
      return
    }
    
    if (data.value) {
      const token = useCookie('auth_token')
      token.value = data.value.token
      user.value = data.value.user
      showLogin.value = false
      ElMessage.success('登录成功')
    }
  } catch (err) {
    ElMessage.error('登录失败，请重试')
  }
}

function handleLogout(): void {
  const token = useCookie('auth_token')
  token.value = null
  user.value = null
  ElMessage.success('已退出登录')
}

async function refreshUser(): Promise<void> {
  await checkAuth()
}

function initTheme(): void {
  const savedTheme = localStorage.getItem('theme')
  if (savedTheme) {
    isDark.value = savedTheme === 'dark'
  } else {
    isDark.value = window.matchMedia('(prefers-color-scheme: dark)').matches
  }
  
  applyTheme()
  
  mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
  mediaQuery.addEventListener('change', handleSystemThemeChange)
}

function handleSystemThemeChange(e: MediaQueryListEvent): void {
  if (!localStorage.getItem('theme')) {
    isDark.value = e.matches
    applyTheme()
  }
}

function toggleTheme(): void {
  isDark.value = !isDark.value
  localStorage.setItem('theme', isDark.value ? 'dark' : 'light')
  applyTheme()
}

function applyTheme(): void {
  const html = document.documentElement
  if (isDark.value) {
    html.classList.add('dark')
  } else {
    html.classList.remove('dark')
  }
}
</script>

<style scoped>
.app-header {
  background-color: var(--bg-secondary);
  box-shadow: 0 2px 4px var(--border-color);
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
  transition: background-color 0.3s, box-shadow 0.3s;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 15px;
}

.theme-toggle {
  transition: transform 0.3s;
}

.theme-toggle:hover {
  transform: scale(1.1);
}

.logo {
  font-size: 20px;
  font-weight: bold;
  color: var(--logo-color);
  transition: color 0.3s;
}

.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 80vh;
}

.app-main {
  padding: 20px;
}

.user-info {
  display: flex;
  align-items: center;
  flex-wrap: nowrap;
  gap: 8px;
}

.user-info span {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

@media (max-width: 600px) {
  .app-header {
    padding: 12px 16px;
  }

  .logo {
    font-size: 18px;
    flex-shrink: 0;
  }

  .user-info {
    gap: 4px;
    min-width: 0;
  }

  .user-info span {
    font-size: 14px;
    max-width: 120px;
  }

  .user-info .el-button {
    font-size: 12px;
    padding: 5px 10px;
  }

  .app-main {
    padding: 12px;
  }

  .login-container {
    height: auto;
    padding: 24px 0;
  }
}
</style>

<style>
:root {
  --bg-primary: #f5f7fa;
  --bg-secondary: #fff;
  --text-primary: #303133;
  --text-secondary: #606266;
  --border-color: rgba(0, 0, 0, 0.1);
  --logo-color: #409EFF;
}

html.dark {
  --bg-primary: #1a1a1a;
  --bg-secondary: #2b2b2b;
  --text-primary: #e5e5e5;
  --text-secondary: #b3b3b3;
  --border-color: rgba(255, 255, 255, 0.1);
  --logo-color: #79bbff;
}
</style>
