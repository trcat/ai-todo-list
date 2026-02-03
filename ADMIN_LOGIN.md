# 管理员登录限制功能

## 📋 功能说明

此分支实现了管理员登录限制功能：
- ✅ 移除了自动注册功能
- ✅ 只有已存在的用户可以登录
- ✅ 用户名或密码错误返回 401
- ✅ 提供管理员账号创建脚本

## 🔐 默认管理员账号

**用户名**: `admin`  
**密码**: `admin123`

⚠️ **生产环境请务必修改密码！**

## 🛠️ 创建管理员账号

### 方法 1: 使用 PowerShell 脚本（推荐）

```powershell
.\scripts\create-admin.ps1
```

脚本会提示输入用户名和密码（支持自定义）。

### 方法 2: 使用 npm 脚本

```bash
# 使用默认值 (admin/admin123)
pnpm create-admin

# 使用环境变量自定义
ADMIN_USERNAME=myadmin ADMIN_PASSWORD=mypassword pnpm create-admin
```

### 方法 3: 直接在数据库执行

```sql
-- 在 Prisma Studio 或数据库客户端执行
-- 密码: admin123
INSERT INTO "User" (username, password, "createdAt")
VALUES ('admin', '$2a$10$XN.KnZrF7bFJVqN3DnBvQu1iBrMHR/HtEYOqrb0kW9W5WxLF1gBjK', NOW())
ON CONFLICT (username) DO NOTHING;
```

## 🧪 测试

### 本地测试

```powershell
# 启动开发服务器
pnpm dev

# 在另一个终端运行测试
.\scripts\test-admin-login.ps1
```

### 手动测试

```bash
# 测试正确的管理员账号
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# 测试不存在的用户（应该返回 401）
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"newuser","password":"test123"}'
```

## 📝 代码变更

### 修改的文件

1. **server/api/auth/login.post.ts**
   - 移除自动注册逻辑
   - 用户不存在直接返回 401
   - 统一错误消息为"用户名或密码错误"（安全考虑）

2. **package.json**
   - 添加 `create-admin` 脚本
   - 添加 `tsx` 开发依赖

### 新增的文件

1. **scripts/create-admin.ts** - TypeScript 创建管理员脚本
2. **scripts/create-admin.ps1** - PowerShell 交互式创建脚本
3. **scripts/test-admin-login.ps1** - 登录功能测试脚本
4. **prisma/seed-admin.sql** - SQL 创建管理员语句

## 🚀 部署到 Vercel

```bash
# 1. 提交更改
git add .
git commit -m "feat: restrict login to admin only"

# 2. 推送到 GitHub
git push origin feature/admin-only-login

# 3. 合并到 main 分支（或创建 PR）
git checkout main
git merge feature/admin-only-login
git push origin main

# 4. 在 Vercel 部署后，创建管理员账号
# 方法 A: 本地连接生产数据库
vercel env pull .env.production
DATABASE_URL=<从 .env.production 复制> pnpm create-admin

# 方法 B: 使用 Prisma Studio 直接操作生产数据库
vercel env pull .env.production
DATABASE_URL=<从 .env.production 复制> pnpm prisma studio
# 在 Prisma Studio 中手动创建用户
```

## 🔒 安全建议

1. ✅ 生产环境修改默认密码
2. ✅ 使用强密码（至少 12 位，包含大小写字母、数字、特殊字符）
3. ✅ 不要在代码中硬编码密码
4. ✅ 定期更新管理员密码
5. ✅ 考虑添加登录尝试次数限制
6. ✅ 考虑添加 2FA（双因素认证）

## 📚 后续开放注册功能

当需要开放用户注册时：

1. 创建新的注册接口 `server/api/auth/register.post.ts`
2. 添加邮箱验证
3. 添加验证码功能
4. 区分管理员和普通用户角色
5. 实现权限控制

## ❓ 常见问题

### Q: 忘记管理员密码怎么办？

A: 重新运行创建脚本，会更新现有用户的密码：
```bash
pnpm create-admin
```

### Q: 如何添加更多管理员？

A: 多次运行创建脚本，使用不同的用户名：
```bash
ADMIN_USERNAME=admin2 ADMIN_PASSWORD=password2 pnpm create-admin
```

### Q: 如何查看所有用户？

A: 使用 Prisma Studio：
```bash
pnpm prisma studio
```

或使用数据库客户端查询：
```sql
SELECT id, username, "createdAt" FROM "User";
```
