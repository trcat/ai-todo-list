# Vercel 部署 500 错误排查指南

## 问题现象
- ✅ Vercel 部署成功
- ❌ 登录接口返回 500 错误
- ✅ 本地运行正常

## 原因分析
Vercel 上缺少环境变量配置，导致：
1. **DATABASE_URL 未设置** → Prisma 无法连接数据库
2. **JWT_SECRET 未设置** → JWT 签名失败

---

## 🔧 解决方案

### 步骤 1: 配置环境变量

1. 访问 Vercel Dashboard: https://vercel.com/dashboard
2. 选择你的项目
3. 进入 **Settings** → **Environment Variables**
4. 添加以下变量：

```env
DATABASE_URL=postgresql://user:password@host:5432/database?sslmode=require
JWT_SECRET=your-random-secret-key-at-least-32-chars-long
```

**重要提示：**
- 三个环境都要添加：Production、Preview、Development
- 勾选所有三个选项确保环境变量在所有部署中生效

### 步骤 2: 创建 PostgreSQL 数据库

#### 方案 A: 使用 Neon（推荐，免费）

1. 访问 https://neon.tech
2. 创建免费账号
3. 创建新项目
4. 复制连接字符串（格式如下）：
   ```
   postgresql://user:password@ep-xxx.us-east-2.aws.neon.tech/neondb?sslmode=require
   ```
5. 将此字符串设置为 Vercel 的 `DATABASE_URL`

#### 方案 B: Vercel Postgres Storage

1. 在 Vercel Dashboard
2. 进入 **Storage** → **Create Database**
3. 选择 **Neon Postgres** 或 **Vercel Postgres**
4. 创建后自动设置 `DATABASE_URL` 环境变量

### 步骤 3: 运行数据库迁移

配置好环境变量后，需要初始化数据库表：

```bash
# 方法 1: 本地连接 Vercel 数据库（推荐）
# 1. 安装 Vercel CLI
pnpm add -g vercel

# 2. 链接到你的 Vercel 项目
vercel link

# 3. 拉取环境变量
vercel env pull .env

# 4. 推送数据库 schema
pnpm prisma db push

# 方法 2: 直接在 Vercel 项目设置中运行命令（如果支持）
# 在部署设置中添加 Build Command:
# prisma db push && nuxt build
```

### 步骤 4: 重新部署

1. 在 Vercel Dashboard → **Deployments**
2. 点击右上角 **Redeploy** 按钮
3. 选择 **Redeploy** (不是 Skip Build)

或者推送新提交触发部署：
```bash
git add .
git commit -m "fix: add prisma generate to build"
git push
```

---

## 🔍 验证环境变量

### 方法 1: Vercel CLI
```bash
vercel env ls
```

### 方法 2: 创建测试 API

创建 `server/api/health.get.ts`：
```typescript
export default defineEventHandler(async (event) => {
  return {
    database: !!process.env.DATABASE_URL,
    jwt: !!process.env.JWT_SECRET,
    node_env: process.env.NODE_ENV
  }
})
```

访问：`https://your-app.vercel.app/api/health`

应该返回：
```json
{
  "database": true,
  "jwt": true,
  "node_env": "production"
}
```

---

## 🐛 查看详细错误日志

### 在 Vercel Dashboard：
1. 进入你的项目
2. 点击最新的部署
3. 进入 **Functions** 标签
4. 找到 `api/auth/login` 函数
5. 查看 **Logs** 获取详细错误信息

### 常见错误：

#### 错误 1: Prisma Client 未生成
```
Error: @prisma/client did not initialize yet
```
**解决：** 已在 package.json 中添加 `prisma generate`

#### 错误 2: 数据库连接失败
```
Error: Can't reach database server
```
**解决：** 检查 `DATABASE_URL` 是否正确，确保包含 `?sslmode=require`

#### 错误 3: JWT Secret 未定义
```
Error: Cannot encode undefined
```
**解决：** 设置 `JWT_SECRET` 环境变量

---

## ✅ 检查清单

- [ ] ✅ 在 Vercel 设置了 `DATABASE_URL`
- [ ] ✅ 在 Vercel 设置了 `JWT_SECRET`
- [ ] ✅ 环境变量应用于所有环境（Production/Preview/Development）
- [ ] ✅ 运行了 `prisma db push` 初始化数据库表
- [ ] ✅ 重新部署项目
- [ ] ✅ 查看 Vercel Functions 日志确认错误消息

---

## 🎯 测试登录

配置完成后，测试登录：

```bash
curl -X POST https://your-app.vercel.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test123"}'
```

成功响应：
```json
{
  "token": "eyJhbGc...",
  "user": {
    "id": 1,
    "username": "test"
  }
}
```

---

## 📚 参考资料

- [Vercel Environment Variables](https://vercel.com/docs/environment-variables)
- [Prisma with Vercel](https://www.prisma.io/docs/guides/deployment/deployment-guides/deploying-to-vercel)
- [Nuxt Nitro Presets](https://nitro.unjs.io/deploy/providers/vercel)
