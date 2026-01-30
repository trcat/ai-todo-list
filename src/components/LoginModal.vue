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
    <template #footer>
      <span class="dialog-footer">
        <el-button @click="visible = false">取消</el-button>
        <el-button type="primary" @click="handleLogin">登录</el-button>
      </span>
    </template>
  </el-dialog>
</template>

<script>
import { ElMessage } from 'element-plus'

export default {
  name: 'LoginModal',
  props: {
    modelValue: {
      type: Boolean,
      default: false
    }
  },
  emits: ['update:modelValue', 'login'],
  data() {
    return {
      form: {
        username: '',
        password: ''
      }
    }
  },
  computed: {
    visible: {
      get() {
        return this.modelValue
      },
      set(value) {
        this.$emit('update:modelValue', value)
      }
    }
  },
  methods: {
    handleLogin() {
      if (this.form.username && this.form.password) {
        this.$emit('login', this.form)
        this.visible = false
        ElMessage.success('登录成功')
      } else {
        ElMessage.warning('请输入用户名和密码')
      }
    }
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
