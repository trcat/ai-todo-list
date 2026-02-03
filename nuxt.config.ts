// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-01-01',
  future: {
    compatibilityVersion: 4
  },
  devtools: { enabled: true },
  
  modules: [
    '@element-plus/nuxt',
    '@vite-pwa/nuxt'
  ],

  // Element Plus 配置
  elementPlus: {
    icon: 'ElIcon',
    importStyle: 'css',
    themes: ['dark']
  },

  // PWA 配置
  pwa: {
    registerType: 'autoUpdate',
    manifest: {
      name: 'Todo App',
      short_name: 'Todo',
      description: 'A Vue 3 todo application with user authentication',
      theme_color: '#409EFF',
      icons: [
        {
          src: '/pwa-192x192.png',
          sizes: '192x192',
          type: 'image/png'
        },
        {
          src: '/pwa-512x512.png',
          sizes: '512x512',
          type: 'image/png'
        }
      ]
    },
    workbox: {
      navigateFallback: '/',
      globPatterns: ['**/*.{js,css,html,png,svg,ico}'],
      globIgnores: ['**/node_modules/**', '**/.nuxt/**']
    },
    devOptions: {
      enabled: false, // 开发模式下禁用 PWA 以避免文件匹配问题
      type: 'module'
    }
  },

  // CSS 配置
  css: [
    '~/assets/main.css'
  ],

  // App 配置
  app: {
    head: {
      title: 'Todo App',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'A Vue 3 todo application' }
      ],
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }
      ]
    }
  },

  // Vite 配置
  vite: {
    css: {
      preprocessorOptions: {
        scss: {
          additionalData: '@use "~/assets/variables.scss" as *;'
        }
      }
    }
  },

  // Nitro 服务器配置
  nitro: {
    experimental: {
      // 禁用 wasm 优化以避免 crypto.hash 错误
      wasm: false
    },
    // 使用 Node.js 运行时的 crypto 模块
    unenv: {
      inject: {
        crypto: 'node:crypto'
      }
    }
  }
})
