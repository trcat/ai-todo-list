import { createApp } from 'vue'
import App from './App.vue'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'

const app = createApp(App)
app.use(ElementPlus)

for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component)
}

app.mount('#app')

// 注册 Service Worker 以支持 PWA
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/ai-todo-list/service-worker.js').then(
      (registration) => {
        console.log('Service Worker 注册成功:', registration)
      },
      (error) => {
        console.log('Service Worker 注册失败:', error)
      }
    )
  })
}

// 安装提示事件处理
// eslint-disable-next-line no-unused-vars
let deferredPrompt
window.addEventListener('beforeinstallprompt', (e) => {
  e.preventDefault()
  deferredPrompt = e
  // 可在此处显示"安装应用"按钮
  console.log('可安装提示已触发')
})

window.addEventListener('appinstalled', () => {
  console.log('应用已安装到本地')
  deferredPrompt = null
})
