<template>
  <el-dialog
    :model-value="modelValue"
    @update:model-value="updateVisible"
    title="用户登录"
    width="90%"
    :style="{ maxWidth: '400px' }"
  >
    <el-form @submit.prevent="handleLogin">
      <el-form-item label="用户名">
        <el-input
          v-model="username"
          placeholder="请输入用户名"
          clearable
        />
      </el-form-item>
      <el-form-item label="密码">
        <el-input
          v-model="password"
          type="password"
          placeholder="请输入密码"
          show-password
          clearable
        />
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="updateVisible(false)">取消</el-button>
      <el-button type="primary" @click="handleLogin">登录</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, type Ref } from 'vue'
import { ElMessage } from 'element-plus'

interface Props {
  modelValue: boolean
}

interface Emits {
  (e: 'update:modelValue', value: boolean): void
  (e: 'login', credentials: { username: string; password: string }): void
}

defineProps<Props>()
const emit = defineEmits<Emits>()

const username: Ref<string> = ref('')
const password: Ref<string> = ref('')

function updateVisible(value: boolean): void {
  emit('update:modelValue', value)
}

function handleLogin(): void {
  if (!username.value || !password.value) {
    ElMessage.warning('请输入用户名和密码')
    return
  }
  
  emit('login', {
    username: username.value,
    password: password.value
  })
  
  username.value = ''
  password.value = ''
}
</script>
