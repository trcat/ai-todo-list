# Nuxt 4 部署说明

## ⚠️ 注意事项

由于本项目已从纯前端项目升级为 **Nuxt 4 全栈应用**，原有的 GitHub Pages 静态部署方式**不再适用**。

## 为什么不能部署到 GitHub Pages？

1. **需要服务器端渲染 (SSR)**: Nuxt 4 使用 Nitro 服务器引擎
2. **需要后端 API**: 项目包含数据库和认证功能
3. **需要数据库**: SQLite 数据库需要文件系统支持
4. **GitHub Pages 限制**: 只支持静态文件托管

## 推荐的部署方式

### 方案 1: Vercel（推荐）✨

**最简单的部署方式，零配置！**

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

**数据库迁移：**
```bash
# 使用 Vercel Postgres
pnpm add @vercel/postgres
# 或使用 Planetscale / Supabase
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

| 平台 | 难度 | 成本 | 数据库 | 推荐指数 |
|------|------|------|--------|----------|
| Vercel | ⭐ | 免费/付费 | 需外部 | ⭐⭐⭐⭐⭐ |
| Netlify | ⭐ | 免费/付费 | 需外部 | ⭐⭐⭐⭐ |
| Railway | ⭐⭐ | 免费/付费 | 内置支持 | ⭐⭐⭐⭐⭐ |
| 自建服务器 | ⭐⭐⭐⭐ | VPS费用 | 完全控制 | ⭐⭐⭐ |
| Docker | ⭐⭐⭐ | 容器费用 | 完全控制 | ⭐⭐⭐⭐ |

## 快速决策指南

### 选择 Vercel 如果：
- 🎯 想要最简单的部署体验
- 🎯 可以接受使用外部数据库（PostgreSQL）
- 🎯 需要全球 CDN 和高性能

### 选择 Railway 如果：
- 🎯 需要完整的数据库支持
- 🎯 想要简单的全栈部署
- 🎯 预算有限但需要可靠服务

### 选择自建服务器如果：
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
