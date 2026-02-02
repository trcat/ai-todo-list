# Todo App - Nuxt 4 全栈应用

基于 Nuxt 4 构建的全栈待办事项应用，集成用户认证、数据持久化和 PWA 支持。

## 技术栈

### 前端
- **Nuxt 4** - Vue 全栈框架
- **Vue 3** - 使用 Composition API + `<script setup>`
- **Element Plus** - UI 组件库
- **TypeScript** - 类型安全
- **Vite PWA** - PWA 支持

### 后端
- **Nitro** - Nuxt 内置服务器引擎
- **Prisma** - ORM 数据库工具
- **SQLite** - 数据库
- **JWT (jose)** - 身份认证
- **bcrypt** - 密码加密

## 功能特性

- ✅ 用户注册/登录（自动注册）
- ✅ JWT Token 认证
- ✅ 待办事项 CRUD 操作
- ✅ 优先级标记（高/中/低）
- ✅ 任务描述
- ✅ 任务完成状态
- ✅ 深色/浅色主题切换
- ✅ PWA 支持（离线可用）
- ✅ 响应式设计

## 快速开始

### 1. 安装依赖

```bash
pnpm install
```

### 2. 初始化数据库

```bash
# 生成 Prisma Client
pnpm exec prisma generate

# 创建数据库
pnpm exec prisma db push

# （可选）查看数据库
pnpm exec prisma studio
```

### 3. 启动开发服务器

```bash
pnpm dev
```

访问 http://localhost:3000

## 项目结构

```
hello-vue/
├── app.vue                 # Nuxt 应用入口
├── nuxt.config.ts          # Nuxt 配置
├── pages/
│   └── index.vue           # 首页（主应用界面）
├── components/
│   ├── LoginModal.vue      # 登录弹窗组件
│   └── TodoList.vue        # 待办列表组件
├── server/
│   ├── api/
│   │   ├── auth/
│   │   │   ├── login.post.ts    # 登录/注册 API
│   │   │   └── me.get.ts        # 获取当前用户
│   │   └── todos/
│   │       ├── index.get.ts     # 获取所有待办
│   │       ├── index.post.ts    # 创建待办
│   │       ├── [id].patch.ts    # 更新待办
│   │       └── [id].delete.ts   # 删除待办
│   └── utils/
│       ├── prisma.ts       # Prisma 客户端
│       ├── jwt.ts          # JWT 工具
│       └── password.ts     # 密码加密工具
├── prisma/
│   └── schema.prisma       # 数据库模型
├── assets/
│   └── main.css            # 全局样式
└── public/                 # 静态资源
```

## API 端点

### 认证 API

- `POST /api/auth/login` - 登录/注册
  ```json
  {
    "username": "user",
    "password": "pass"
  }
  ```

- `GET /api/auth/me` - 获取当前用户信息
  - Headers: `Authorization: Bearer <token>`

### 待办事项 API

所有待办事项 API 都需要在 Headers 中携带 JWT Token：
```
Authorization: Bearer <token>
```

- `GET /api/todos` - 获取所有待办事项
- `POST /api/todos` - 创建待办事项
  ```json
  {
    "text": "任务内容",
    "description": "任务描述（可选）",
    "priority": "medium"
  }
  ```
- `PATCH /api/todos/:id` - 更新待办事项
  ```json
  {
    "text": "新内容（可选）",
    "description": "新描述（可选）",
    "completed": true,
    "priority": "high"
  }
  ```
- `DELETE /api/todos/:id` - 删除待办事项

## 数据库模型

### User
- `id` - 用户 ID
- `username` - 用户名（唯一）
- `password` - 密码哈希
- `createdAt` - 创建时间
- `todos` - 关联的待办事项

### Todo
- `id` - 待办事项 ID
- `text` - 任务内容
- `description` - 任务描述
- `completed` - 是否完成
- `priority` - 优先级（low/medium/high）
- `userId` - 所属用户 ID
- `createdAt` - 创建时间
- `updatedAt` - 更新时间

## 环境变量

创建 `.env` 文件：

```env
DATABASE_URL="file:./dev.db"
JWT_SECRET="your-super-secret-jwt-key-change-this-in-production"
```

## 构建部署

```bash
# 构建生产版本
pnpm build

# 预览生产版本
pnpm preview
```

## 开发命令

```bash
# 启动开发服务器
pnpm dev

# 构建生产版本
pnpm build

# 生成静态站点
pnpm generate

# 预览生产版本
pnpm preview

# ESLint 检查
pnpm lint

# Prisma 相关
pnpm exec prisma generate     # 生成客户端
pnpm exec prisma db push      # 同步数据库
pnpm exec prisma studio       # 可视化管理
pnpm exec prisma migrate dev  # 创建迁移
```

## 从旧版本迁移

如果你是从之前的 Vite + Vue 版本迁移过来的：

1. 用户数据会全部重置（之前存储在 localStorage）
2. 现在所有数据都存储在 SQLite 数据库中
3. 用户首次登录时会自动注册账号
4. 每个用户的待办事项完全隔离

## 技术亮点

1. **全栈一体化**：单一代码库同时包含前端和后端
2. **类型安全**：全面使用 TypeScript
3. **现代化 API**：使用 Composition API + `<script setup>`
4. **安全认证**：JWT Token + bcrypt 密码加密
5. **数据持久化**：Prisma ORM + SQLite
6. **PWA 支持**：可安装、离线可用
7. **响应式设计**：完美适配移动端

## License

MIT

---

由 Vue 3 + Vite 项目迁移至 Nuxt 4 全栈应用 🚀

### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).
