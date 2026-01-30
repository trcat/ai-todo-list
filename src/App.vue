<template>
  <div id="app">
    <el-container>
      <el-header class="app-header">
        <div class="logo">Todo App</div>
        <div class="header-right">
          <el-tooltip :content="isDark ? '切换到浅色模式' : '切换到深色模式'" placement="bottom">
            <el-button 
              :icon="isDark ? 'Sunny' : 'Moon'" 
              circle 
              @click="toggleTheme"
              class="theme-toggle"
            />
          </el-tooltip>
          <div v-if="currentUser" class="user-info">
            <span>欢迎, {{ currentUser }}</span>
            <el-button type="info" size="small" @click="handleLogout" style="margin-left: 15px;">退出登录</el-button>
          </div>
        </div>
      </el-header>
      
      <el-main class="app-main">
        <div v-if="!currentUser" class="login-container">
          <el-empty description="请先登录以管理你的待办事项">
            <el-button type="primary" size="large" @click="showLogin = true">点击登录</el-button>
          </el-empty>
        </div>

        <TodoList v-else :username="currentUser" />
      </el-main>
    </el-container>

    <LoginModal v-model="showLogin" @login="onLogin" />
  </div>
</template>

<script>
import LoginModal from './components/LoginModal.vue'
import TodoList from './components/TodoList.vue'

export default {
  name: "App",
  components: {
    LoginModal,
    TodoList
  },
  data() {
    return {
      showLogin: false,
      currentUser: localStorage.getItem('currentUser') || '',
      isDark: false
    }
  },
  mounted() {
    this.initTheme()
  },
  beforeUnmount() {
    if (this.mediaQuery) {
      this.mediaQuery.removeEventListener('change', this.handleSystemThemeChange)
    }
  },
  methods: {
    onLogin(user) {
      this.currentUser = user.username
      localStorage.setItem('currentUser', this.currentUser)
      this.showLogin = false
    },
    handleLogout() {
      this.currentUser = ''
      localStorage.removeItem('currentUser')
    },
    initTheme() {
      // 1. 先检查用户是否有手动设置过主题
      const savedTheme = localStorage.getItem('theme')
      if (savedTheme) {
        this.isDark = savedTheme === 'dark'
      } else {
        // 2. 如果没有保存的主题，则检测系统主题偏好
        this.isDark = window.matchMedia('(prefers-color-scheme: dark)').matches
      }
      
      this.applyTheme()
      
      // 3. 监听系统主题变化（仅当用户没有手动设置时）
      this.mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
      this.handleSystemThemeChange = (e) => {
        if (!localStorage.getItem('theme')) {
          this.isDark = e.matches
          this.applyTheme()
        }
      }
      this.mediaQuery.addEventListener('change', this.handleSystemThemeChange)
    },
    toggleTheme() {
      this.isDark = !this.isDark
      localStorage.setItem('theme', this.isDark ? 'dark' : 'light')
      this.applyTheme()
    },
    applyTheme() {
      const html = document.documentElement
      if (this.isDark) {
        html.classList.add('dark')
      } else {
        html.classList.remove('dark')
      }
    }
  }
}
</script>

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

body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  background-color: var(--bg-primary);
  color: var(--text-primary);
  transition: background-color 0.3s, color 0.3s;
}

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
