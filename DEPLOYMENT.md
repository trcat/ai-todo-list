# Nuxt 4 部署说明

## ⚠️ Deno Deploy 不兼容问题

**如果你在 Deno Deploy 上遇到 500 错误，这是正常的。** 原因：

### 为什么 Deno Deploy 会 500？

1. **Prisma 不支持边缘运行时** - Prisma Client 需要 Node.js 运行时
2. **SQLite 文件系统不可用** - Deno Deploy 是无服务器环境
3. **bcryptjs 依赖 Node.js API** - 某些 Node 模块在边缘环境不可用

### 错误日志通常显示：
```
Error: PrismaClient is unable to run in Deno Deploy
或
Error: Module not found: node:crypto
```

## ✅ 推荐的部署方式

### 方案 1: Vercel（最推荐）✨

**零配置，完美支持 Nuxt 4 + Prisma！**

```bash
# 1. 安装 Vercel CLI
pnpm add -g vercel

# 2. 登录 Vercel
vercel login

# 3. 部署
vercel

# 4. 生产部署
vercel --prod
```

**特点：**
- ✅ 自动识别 Nuxt 项目
- ✅ 支持 SSR
- ✅ 免费额度充足
- ✅ 自动 HTTPS
- ✅ 全球 CDN
- ⚠️ SQLite 会在每次部署时重置（需要切换到 PostgreSQL）

**数据库迁移（必须）：**

Vercel 不支持 SQLite，必须切换到云数据库：

#### 选项 A：Vercel Postgres（最简单）
```bash
# 1. 在 Vercel 项目中添加 Postgres 存储
# 2. 自动设置 DATABASE_URL 环境变量
# 3. 更新 prisma/schema.prisma:
```
```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
```

#### 选项 B：Neon.tech（推荐免费方案）
```bash
# 1. 注册 https://neon.tech（免费 0.5GB）
# 2. 创建项目，复制连接字符串
# 3. 在 Vercel 环境变量中设置 DATABASE_URL
```

#### 选项 C：PlanetScale（MySQL）
```bash
# 1. 注册 https://planetscale.com
# 2. 创建数据库
# 3. 更新 schema.prisma provider 为 "mysql"
```

**部署步骤：**
```bash
# 1. 更新 schema.prisma 数据库提供商
# 2. 推送代码
git add .
git commit -m "feat: 配置生产数据库"
git push

# 3. 在 Vercel 导入项目: https://vercel.com/new
# 4. 设置环境变量:
#    DATABASE_URL=postgresql://...
#    JWT_SECRET=your-secret
# 5. 部署完成后运行: pnpm prisma db push
```

### 方案 2: Netlify

```bash
# 1. 安装 Netlify CLI
pnpm add -g netlify-cli

# 2. 登录
netlify login

# 3. 初始化
netlify init

# 4. 部署
netlify deploy --prod
```

**特点：**
- ✅ 支持 Nuxt SSR
- ✅ 免费计划可用
- ✅ 简单的 CI/CD
- ⚠️ 需要外部数据库

### 方案 3: Railway（推荐用于全栈）🚂

**最适合有数据库的全栈应用！**

1. 访问 https://railway.app
2. 连接 GitHub 仓库
3. 自动检测并部署
4. 配置环境变量

**特点：**
- ✅ 完整的服务器环境
- ✅ 支持 SQLite/PostgreSQL
- ✅ 自动 SSL
- ✅ 简单的环境变量管理
- 💰 有免费额度

**环境变量配置：**
```env
DATABASE_URL=postgresql://...
JWT_SECRET=your-secret-key
NODE_ENV=production
```

### 方案 4: 自建服务器（完全控制）

```bash
# 1. 构建项目
pnpm build

# 2. 启动生产服务器
node .output/server/index.mjs

# 或使用 PM2
pnpm add -g pm2
pm2 start .output/server/index.mjs --name nuxt-todo
```

**Nginx 配置示例：**
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### 方案 5: Docker 部署

```dockerfile
# Dockerfile
FROM node:20-alpine

WORKDIR /app

# 复制依赖文件
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && pnpm install --frozen-lockfile

# 复制源代码
COPY . .

# 生成 Prisma Client
RUN pnpm exec prisma generate

# 构建应用
RUN pnpm build

# 创建数据库
RUN pnpm exec prisma db push

EXPOSE 3000

ENV HOST=0.0.0.0
ENV PORT=3000

CMD ["node", ".output/server/index.mjs"]
```

```yaml
# docker-compose.yml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - ./prisma:/app/prisma
      - db-data:/app/prisma
    environment:
      - DATABASE_URL=file:./dev.db
      - JWT_SECRET=${JWT_SECRET}
volumes:
  db-data:
```

## 静态生成 (SSG) 选项

如果你想回到纯静态部署（**会失去后端功能**），可以：

```bash
# 1. 生成静态站点
pnpm generate

# 2. 部署 .output/public 目录到 GitHub Pages
```

⚠️ **注意**：使用 SSG 会失去：
- 用户认证
- 数据库存储
- 实时数据同步
- 服务端 API

## 推荐配置对比

| 平台 | 难度 | 成本 | Prisma支持 | 推荐指数 |
|------|------|------|-----------|----------|
| Vercel + Neon | ⭐ | 免费 | ✅ 完美 | ⭐⭐⭐⭐⭐ |
| Railway | ⭐⭐ | $5/月 | ✅ 完美 | ⭐⭐⭐⭐⭐ |
| Netlify | ⭐ | 免费 | ✅ 支持 | ⭐⭐⭐⭐ |
| 自建服务器 | ⭐⭐⭐⭐ | VPS | ✅ 完美 | ⭐⭐⭐ |
| Deno Deploy | ⭐ | 免费 | ❌ 不支持 | ⭐ |
| Cloudflare Pages | ⭐⭐⭐ | 免费 | ⚠️ 需改造 | ⭐⭐⭐ |

## 🚫 为什么 Deno Deploy 不行？

### 技术限制

Deno Deploy 是 **边缘运行时**，类似 Cloudflare Workers，有严格限制：

**不支持的功能：**
- ❌ Prisma Client（需要 Node.js 二进制）
- ❌ 文件系统（SQLite 无法使用）
- ❌ 长时间运行进程
- ❌ 部分 Node.js 原生模块

**你看到的 500 错误原因：**
```
PrismaClient is unable to run in Deno Deploy
```

### 如何在 Deno Deploy 使用数据库？

必须完全重写数据层，使用以下方案之一：

#### 方案 1：Deno KV（官方推荐）
```typescript
// 完全重写所有数据库逻辑
const kv = await Deno.openKv()
await kv.set(["users", username], userData)
```

#### 方案 2：Prisma Accelerate（付费）
```bash
# 需要订阅 Prisma 云服务
# 通过 HTTP 代理访问数据库
```

#### 方案 3：外部 REST API
```typescript
// 调用外部托管的数据库 API
await fetch('https://your-db-api.com/users')
```

**结论：** 需要大量重构，不推荐。

## 快速决策指南

### ✅ 选择 Vercel 如果：
- 🎯 想要最简单的部署体验
- 🎯 可以使用 PostgreSQL（Neon.tech 免费）
- 🎯 需要全球 CDN 和高性能
- 🎯 **推荐给本项目！**

### ✅ 选择 Railway 如果：
- 🎯 需要完整的数据库支持（包括 SQLite）
- 🎯 想要一键部署，自动配置
- 🎯 预算有限但需要可靠服务

### ❌ 不要选择 Deno Deploy：
- 🎯 需要 Prisma 数据库
- 🎯 使用 SQLite 或其他文件数据库
- 🎯 依赖 Node.js 特定模块
- 🎯 需要完全控制
- 🎯 有服务器管理经验
- 🎯 需要自定义配置

## 数据库迁移建议

### 从 SQLite 迁移到 PostgreSQL

1. 更新 `prisma/schema.prisma`:
```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
```

2. 更新环境变量:
```env
DATABASE_URL="postgresql://user:password@host:5432/dbname"
```

3. 重新生成并推送:
```bash
pnpm exec prisma generate
pnpm exec prisma db push
```

## 获取帮助

- [Nuxt 部署文档](https://nuxt.com/docs/getting-started/deployment)
- [Vercel 文档](https://vercel.com/docs)
- [Railway 文档](https://docs.railway.app/)
- [Netlify 文档](https://docs.netlify.com/)

---

**建议**: 对于学习和测试，推荐使用 **Vercel** 或 **Railway**。  
**生产环境**: 推荐使用 **Railway** 或自建服务器。
