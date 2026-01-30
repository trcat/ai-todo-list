<template>
  <div id="app">
    <el-container>
      <el-header class="app-header">
        <div class="logo">Todo App</div>
        <div v-if="currentUser" class="user-info">
          <span>欢迎, {{ currentUser }}</span>
          <el-button type="info" size="small" @click="handleLogout" style="margin-left: 15px;">退出登录</el-button>
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
      currentUser: localStorage.getItem('currentUser') || ''
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
    }
  }
}
</script>

<style>
body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  background-color: #f5f7fa;
}

.app-header {
  background-color: #fff;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
}

.logo {
  font-size: 20px;
  font-weight: bold;
  color: #409EFF;
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
