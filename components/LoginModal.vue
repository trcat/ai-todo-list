<template>
  <el-dialog v-model="visible" title="登录" width="300px" class="login-dialog">
    <el-form :model="form" label-width="80px">
      <el-form-item label="用户名">
        <el-input v-model="form.username" placeholder="请输入用户名"></el-input>
      </el-form-item>
      <el-form-item label="密码">
        <el-input v-model="form.password" type="password" placeholder="请输入密码" @keyup.enter="handleLogin"></el-input>
      </el-form-item>
    </el-form>
    <div style="text-align: center; margin-top: 10px; color: var(--el-text-color-secondary); font-size: 12px;">
      没有账号？直接输入用户名密码即可注册
    </div>
    <template #footer>
      <span class="dialog-footer">
        <el-button @click="visible = false">取消</el-button>
        <el-button type="primary" @click="handleLogin">登录</el-button>
      </span>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, computed } from 'vue'
import { ElMessage } from 'element-plus'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:modelValue', 'login'])

const form = ref({
  username: '',
  password: ''
})

const visible = computed({
  get() {
    return props.modelValue
  },
  set(value) {
    emit('update:modelValue', value)
  }
})

function handleLogin() {
  if (form.value.username && form.value.password) {
    emit('login', form.value)
  } else {
    ElMessage.warning('请输入用户名和密码')
  }
}
</script>

<style scoped>
@media (max-width: 600px) {
  :deep(.login-dialog .el-dialog) {
    width: min(420px, 92vw) !important;
    margin: 10vh auto;
  }
}
</style>
