# 🚀 快速开始指南

## 当前状态

✅ **服务器已启动并运行**
- URL: http://localhost:3000
- Nuxt 3.21.0 + Nitro 2.13.1
- 数据库已创建并就绪

## 立即体验

### 1. 打开应用

在浏览器访问：http://localhost:3000

### 2. 登录/注册

- 点击"点击登录"按钮
- 输入任意用户名和密码（例如：`admin` / `123456`）
- 系统会自动创建账号并登录

### 3. 开始使用

- 添加待办事项
- 设置优先级（低/中/高）
- 添加任务描述
- 标记完成状态
- 清除已完成任务

### 4. 测试主题切换

- 点击右上角的 🌙/☀️ 按钮切换深色/浅色模式

## 技术特点

### 与之前的区别

| 功能 | 旧版本 | 新版本 |
|------|--------|--------|
| 数据存储 | localStorage | SQLite 数据库 |
| 用户认证 | 前端模拟 | JWT + 后端验证 |
| API 风格 | Options API | Composition API |
| 后端 | 无 | Nitro Server |
| 数据隔离 | 按用户名分离 | 数据库级别隔离 |

### 保留的功能

✅ 所有 UI 和交互完全一致  
✅ Element Plus 组件库  
✅ 深色/浅色主题  
✅ PWA 支持  
✅ 响应式设计  

## 常用命令

```bash
# 查看数据库内容（在浏览器打开）
pnpm exec prisma studio

# 停止服务器
按 Ctrl+C

# 重新启动
pnpm dev

# 构建生产版本
pnpm build
```

## API 测试

### 使用 curl 测试（可选）

```bash
# 1. 登录获取 Token
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"123456"}'

# 2. 获取待办事项（替换 YOUR_TOKEN）
curl http://localhost:3000/api/todos \
  -H "Authorization: Bearer YOUR_TOKEN"

# 3. 创建待办事项
curl -X POST http://localhost:3000/api/todos \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"text":"测试任务","priority":"high"}'
```

## 文件说明

- **README.md** - 完整项目文档
- **MIGRATION.md** - 详细迁移说明
- **QUICKSTART.md** (本文件) - 快速开始指南

## 遇到问题？

1. **服务器未启动**: 运行 `pnpm dev`
2. **数据库错误**: 运行 `pnpm exec prisma db push`
3. **依赖问题**: 删除 `node_modules` 后运行 `pnpm install`
4. **端口占用**: 修改 `nuxt.config.ts` 中的端口号

## 下一步

- 📖 阅读 [README.md](./README.md) 了解完整功能
- 🔄 查看 [MIGRATION.md](./MIGRATION.md) 了解迁移详情
- 🛠️ 开始自定义和扩展功能

---

**享受使用 Nuxt 4 全栈应用！** 🎉
